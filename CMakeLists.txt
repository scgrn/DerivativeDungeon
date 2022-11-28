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
aux_source_directory("${VENDOR_DIR}/zlib-1.2.11" ZLIB_SOURCE)

# remove unused source files
list(REMOVE_ITEM LUA_SOURCE "${VENDOR_DIR}/lua-5.3.5/src/lua.c")
list(REMOVE_ITEM LUA_SOURCE "${VENDOR_DIR}/lua-5.3.5/src/luac.c")

add_executable(${PROJECT_NAME}
	"${PROJECT_SOURCE_DIR}/src/main/main.c"
	"${LUA_SOURCE}"
	"${ZLIB_SOURCE}"
)

target_include_directories(${PROJECT_NAME}
	PUBLIC "${PROJECT_SOURCE_DIR}/src/main"
	
	# TODO: fix this
	PUBLIC "/msys64/mingw64/include/ncurses"
	
	PUBLIC "${VENDOR_DIR}"

	PUBLIC "${VENDOR_DIR}/lua-5.3.5/src"
	PUBLIC "${VENDOR_DIR}/zlib-1.2.11"
)

#target_link_options(${PROJECT_NAME} PRIVATE -static-libgcc)

target_link_libraries(${PROJECT_NAME}
	ncurses
	m
)
