local Cell     = require 'Engine.classes.Cell'

local utl_coll = {}

---------------------------------------------



--[[
    This function create a new collection of patches. The size of the grid is determined by x and y 
    TODO: 3rd dimension
]]
function utl_coll.create_patches(x,y,z)
    local cells  = FamilyCell()

    for i=1,x do
        for j = 1,y do
            cells:add( Cell({ ['pos'] = {i,j} })  )
        end
    end
    cells:shuffle()
    return cells
end



-- -- It Applies a function to all elements. Works with collections or with tables.
-- function utl_coll.ask(elements, funct)
--     for _,v in ipairs(elements.order)do
--         funct( elements.agents[v] )
--     end
-- end

-- It Applies a function to all elements. Works with collections or with tables.
function utl_coll.ask(elements, funct)
    if elements:is_a(Agent) then
        funct(elements)
    else
        for _,v in ipairs(elements.order)do
            funct( elements.agents[v] )
        end
    end

    
    -- if elements.order then
    --     for _,v in ipairs(elements.order)do
    --         funct( elements.agents[v] )
    --     end
    -- else
    --     for _,v in pairs(elements)do
    --         funct(v)
    --     end
    -- end
end

-- Removes an element in a collection
function utl_coll.die(agent, Agents)
    if Agents ~= nil then
        Agents:kill(agent)
    else
        --TODO: si no se pasa colección, buscar al agente en todas las colecciones
    end
end

-- This function encapsulates a call to the function clone_n_act in the collection given as parameter
function utl_coll.clone_n_act(n,agent,family, funct)
    return family:clone_n_act(n,agent,funct)
end

return utl_coll