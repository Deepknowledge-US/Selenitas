#include <stdio.h>
#include "luajit.h"
#include "lauxlib.h"


// Test function
// Params: agents table
int sum_agent_x_coords(lua_State *l) {
    int ret = 0;
    int table_idx = lua_gettop(l);

    lua_pushnil(l); // needed for lua_next
    while (lua_next(l, table_idx) != 0) {
        // Top of stack: Agent table
        lua_getfield(l, -1, "pos");
        // Top of stack: Pos table
        lua_rawgeti(l, -1, 1);
        // Top of stack: pos[1] (x coord)
        ret += lua_tonumber(l, -1);
        // pop pushes from this iteration
        lua_pop(l, 3);
    }

    lua_pushnumber(l, ret);
    return 1;
}

// This is printed just after the application is closed
int hello_world(lua_State *l) {
    printf("Hello world!\n");
    return 0;
}

int luaopen_Native_gpu(lua_State *L) {
    luaL_Reg fns[] = {
        {"sum_agent_x_coords", sum_agent_x_coords},
        {"hello_world", hello_world},
        {NULL, NULL}
    };
    luaL_register(L, "gpu", fns); // function from Lua5.1
    return 1;
}
