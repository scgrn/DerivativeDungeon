cmake_minimum_required(VERSION 3.10.2)

project(DerivativeDungeon
    LANGUAGES C
    VERSION 1.0.0
)
set(CMAKE_VERBOSE_MAKEFILE OFF)

set(CMAKE_C_COMPILER "gcc")
set(CMAKE_C_STANDARD 11) 
set(CMAKE_C_STANDARD_REQUIRED OFF)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/bin)

set(VENDOR_DIR "${PROJECT_SOURCE_DIR}/src/vendor")

# collect third party sources
aux_source_directory("${VENDOR_DIR}/lua-5.3.5/src" LUA_SOURCE)

# remove unused source files
list(REMOVE_ITEM LUA_SOURCE "${VENDOR_DIR}/lua-5.3.5/src/lua.c")
list(REMOVE_ITEM LUA_SOURCE "${VENDOR_DIR}/lua-5.3.5/src/luac.c")

add_executable(${PROJECT_NAME}
    "${PROJECT_SOURCE_DIR}/src/main/main.c"
    "${PROJECT_SOURCE_DIR}/src/main/random.c"
    "${LUA_SOURCE}"
)

target_compile_options(${PROJECT_NAME} PRIVATE -finput-charset=UTF-8 -DNCURSES_WIDECHAR -DLUA_USE_POSIX)

target_include_directories(${PROJECT_NAME}
    PUBLIC "${PROJECT_SOURCE_DIR}/src/main"

    # TODO: fix this
    PUBLIC "/msys64/mingw64/include/ncurses"
    PUBLIC "/mingw64/opt/include"
    
    PUBLIC "${VENDOR_DIR}"
    PUBLIC "${VENDOR_DIR}/lua-5.3.5/src"
)

#target_link_options(${PROJECT_NAME} PRIVATE -static-libgcc -DNCURSES_STATIC)
target_link_options(${PROJECT_NAME} PRIVATE -DNCURSES_STATIC)

target_link_directories(${PROJECT_NAME}
    PUBLIC "/mingw64/opt/lib"
)

target_link_libraries(${PROJECT_NAME}
    ncursesw
    m
)
