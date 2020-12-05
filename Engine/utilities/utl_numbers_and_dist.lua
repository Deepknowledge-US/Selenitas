------------------
-- Utilities to apply actions to agents or families mainly.
-- @module
-- numbers_and_dists

local sin       = math.sin
local cos       = math.cos
local rad       = math.rad

local utl_numbers = {}

------------------
-- It removes from the list the element of a determined position, and permute this element with the last of the list.
-- @function round
-- @param list The list from where remove the index
-- @return List
-- @usage
-- local my_two_decimals_num = round(1.456789, 2)
-- -- => 1.46
function utl_numbers.round(x, n)
    n = math.pow(10, n or 0)
    x = x * n
    if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
    return x / n
end

------------------
-- It returns a random float number in range [a,b)
-- @function random_float
-- @param a Number
-- @param b Number
-- @return Float number
-- @usage
-- local some_float_value = utl_numers.random_float(3,5)
function utl_numbers.random_float(a,b)
    return a + (b-a) * math.random();
end

------------------
-- It returns a value of a random gaussian distribution
-- @function gaussian
-- @param mean Number. The center value
-- @param variance Number. The max deviation value
-- @return Float number
function utl_numbers.gaussian (mean, variance)
    return  math.sqrt(-2 * variance * math.log(math.random())) *
            math.cos(2 * math.pi * math.random()) + mean
end

------------------
-- It returns the euclidean distance beetween two points or agents
-- @function dist_euc_to
-- @param a Agent or vector
-- @param b Agent or vector
-- @return Number, the euclidean distance beetween the two points
-- @usage
-- if dist_euc_to(ag1,ag2) < 1 then
--     print("This two agent should get married")
-- end
-- see Agent.dist_euc_to
function utl_numbers.dist_euc_to(a,b)
    if pcall(function() return a:is_a(Agent) end) then
        return a:dist_euc_to(b)
    elseif pcall(function() return a:is_a(Agent) end) then
        return b:dist_euc_to(a)
    else
        local res = 0
        for i = 1,#a do
            res = res + (a[i] - b[i])^2
        end
        return res
    end
end

return utl_numbers