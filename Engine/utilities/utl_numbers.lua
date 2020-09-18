------------------
-- Utilities to apply actions to agents or families mainly.
-- @module
-- actions

local sin       = math.sin
local cos       = math.cos
local rad       = math.rad

local utl_numbers = {}

function utl_numbers.round(x, n)
    n = math.pow(10, n or 0)
    x = x * n
    if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
    return x / n
end

function utl_numbers.random_float(a,b)
    return a + (b-a) * math.random();
end

return utl_numbers