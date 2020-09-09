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

// Params: items list
int reduce(lua_State *l) {
    double ret = 0;
    int t = lua_gettop(l);

    lua_pushnil(l);
    while (lua_next(l, t) != 0) {
        // t[i] is on top of stack now
        if (!lua_isnumber(l, lua_gettop(l))) {
            lua_pushstring(l, "Reduce: all items on the table must be numbers");
            lua_error(l);
            lua_pop(l, 1); // pop error string
        }
        ret += lua_tonumber(l, -1);
        lua_pop(l, 1); // pop iteration value
    }

    lua_pushnumber(l, ret);
    return 1;
}

int luaopen_Native_gpu(lua_State *L) {
    luaL_Reg fns[] = {
        {"sum_agent_x_coords", sum_agent_x_coords},
        {"reduce", reduce},
        {NULL, NULL}
    };
    luaL_register(L, "gpu", fns); // function from Lua5.1
    return 1;
}
