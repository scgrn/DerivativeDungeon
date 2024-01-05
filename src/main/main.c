#include <stdlib.h>
#include <locale.h>

#include "lua-5.3.5/src/lua.h"
#include "lua-5.3.5/src/lualib.h"
#include "lua-5.3.5/src/lauxlib.h"

#ifdef WIN32
#include <windows.h>
#include <ncursesw/ncurses.h>
#else
#include "ncurses.h"
#endif

lua_State* luaVM;
bool luaErrorFlag = false;
char* luaErrorMsg;
bool done = false;

void startCurses() {
    setlocale(LC_ALL, "en_US.UTF-8");
#ifdef WIN32
    SetConsoleOutputCP(437);
#endif

    //  initialize ncurses
    initscr();
    noecho();
    cbreak();
    curs_set(0);
    keypad(stdscr, TRUE);
}

void killCurses() {
    endwin();
}

static int luaPrintString(lua_State* luaVM) {
    int x = (int)lua_tonumber(luaVM, 1);
    int y = (int)lua_tonumber(luaVM, 2);
    const char *str = lua_tostring(luaVM, 3);

    mvprintw(y, x, str);

    return 0;
}

static int luaPrintChar(lua_State* luaVM) {
    int x = (int)lua_tonumber(luaVM, 1);
    int y = (int)lua_tonumber(luaVM, 2);
    int c = (int)lua_tonumber(luaVM, 3);
    mvaddch(x, y, (char)c);
    
    return 0;
}

static int luaRectangle(lua_State* luaVM) {
    int x1 = (int)lua_tonumber(luaVM, 1);
    int y1 = (int)lua_tonumber(luaVM, 2);
    int x2 = (int)lua_tonumber(luaVM, 3);
    int y2 = (int)lua_tonumber(luaVM, 4);

    mvhline(y1, x1, 0, x2 - x1);
    mvhline(y2, x1, 0, x2 - x1);
    mvvline(y1, x1, 0, y2 - y1);
    mvvline(y1, x2, 0, y2 - y1);
    mvaddch(y1, x1, ACS_ULCORNER);
    mvaddch(y2, x1, ACS_LLCORNER);
    mvaddch(y1, x2, ACS_URCORNER);
    mvaddch(y2, x2, ACS_LRCORNER);

    return 0;
}

int luaGetch(lua_State* luaVM) {
    int ch = getch();
    lua_pushnumber(luaVM, ch);

    return 1;
}

int luaDelay(lua_State* luaVM) {
    int ms = (int)lua_tonumber(luaVM, 1);
    usleep(ms * 100);

    return 0;
}

int luaQuit(lua_State* luaVM) {
    done = true;

    return 0;
}

static int traceback(lua_State *luaVM) {
    killCurses();
    
    if (!lua_isstring(luaVM, 1)) { /* 'message' not a string? */
        return 1;  /* keep it intact */
    }
    lua_getglobal(luaVM, "debug");
    if (!lua_istable(luaVM, -1)) {
        lua_pop(luaVM, 1);
        return 1;
    }
    lua_getfield(luaVM, -1, "traceback");
    if (!lua_isfunction(luaVM, -1)) {
        lua_pop(luaVM, 2);
        return 1;
    }
    lua_pushvalue(luaVM, 1);  /* pass error message */
    lua_pushinteger(luaVM, 2);  /* skip this function and traceback */
    lua_call(luaVM, 2, 1);  /* call debug.traceback */

    return 1;
}

void execute(const char* command) {
    if (!luaErrorFlag) {
        lua_pushcfunction(luaVM, traceback);
        if (luaL_loadstring(luaVM, command) || lua_pcall(luaVM, 0, LUA_MULTRET, lua_gettop(luaVM) - 1)) {
            luaErrorMsg = lua_tostring(luaVM, -1);
            lua_pop(luaVM, 2);

            killCurses();
            printf("Lua error from calling execute(): %s\n", luaErrorMsg);

            luaErrorFlag = true;
        }
        lua_pop(luaVM, 1); // remove debug.traceback from the stack
    }
}

static int luaLoadScript(lua_State* luaVM) {
    const char *filename = lua_tostring(luaVM, 1);

    FILE *f = fopen(filename, "rb+");
    if (f) {
        fseek(f, 0L, SEEK_END);
        long filesize = ftell(f); // get file size
        fseek(f, 0L ,SEEK_SET); //go back to the beginning
        char* buffer = malloc(filesize); // allocate the read buf
        fread(buffer, 1, filesize, f);
        fclose(f);

        int error = luaL_loadbuffer(luaVM, (const char*)buffer, filesize, filename);
        if (error) {
            const char* errorMsg = lua_tostring(luaVM, -1);
            lua_pop(luaVM, 1);

            killCurses();
            printf("Lua error from loading script: %s\n", luaErrorMsg);
       }

        lua_pushvalue(luaVM, -1);
        error = lua_pcall(luaVM, 0, 0, 0);
        if (error) {
            luaErrorMsg = lua_tostring(luaVM, -1);
            lua_pop(luaVM, 1);

            killCurses();
            printf("Lua error from executing script on load: %s\n", luaErrorMsg);
        }

        free(buffer);
    } else {
        killCurses();
        printf("Lua error from file load: %s\n", filename);
    }

    return 1;
}

int main(int argc, char* argv[]) {
    startCurses();
    
    //  initialize lua
    luaVM = luaL_newstate();
    if (!luaVM) {
        endwin();
        printf("Error initializing Lua VM");

        exit(1);
    }

    luaL_openlibs(luaVM);
    lua_register(luaVM, "printString", luaPrintString);
    lua_register(luaVM, "printChar", luaPrintChar);
    lua_register(luaVM, "rectangle", luaRectangle);
    lua_register(luaVM, "getch", luaGetch);
    lua_register(luaVM, "delay", luaDelay);
    lua_register(luaVM, "quit", luaQuit);
    lua_register(luaVM, "loadScript", luaLoadScript);

    execute("loadScript('../script/main.lua')");
    if (!luaErrorFlag) {
        execute("init()");
    }

    //  main loop
    while (!done) {
        erase();
        if (luaErrorFlag) {
            mvprintw(0, 0, luaErrorMsg);
            refresh();
            getch();
            luaErrorFlag = false;
            execute("loadScript('../script/main.lua')");
            execute("init()");
        } else {
            execute("update()");

            refresh();
        }
    }

    //  shutdown lua
    if (luaVM) {
        lua_close(luaVM);
        luaVM = 0;
    }

    killCurses();
    
    printf("└───\n");
    printf("╚═══\n");
    
    return 0;
}

