#include <stdio.h>
#include "luajit.h"
#include "lauxlib.h"

int hello_world(lua_State *L) {
    printf("Hello, world!");
    return 0;
}

int luaopen_gpu(lua_State *L) {
    luaL_Reg fns[] = {
        {"hello_world", hello_world},
        {NULL, NULL}
    };
    luaL_register(L, "gpu", fns); // function from Lua5.1
    return 1;
}
