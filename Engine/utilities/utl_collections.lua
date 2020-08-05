local Collection_Cell = require 'Engine.classes.class_collection_cell'
local Cell     = require 'Engine.classes.class_cell'

local utl_coll = {}

---------------------------------------------



--[[
    This function create a new collection of patches. The size of the grid is determined by x and y 
    TODO: 3rd dimension
]]
function utl_coll.create_patches(x,y,z)
    local cells  = Collection_Cell()

    for i=1,x do
        for j = 1,y do
            local link_id = i .. ',' .. j
            cells:add( Cell({ ['id'] = link_id, ['xcor'] = i, ['ycor'] = j })  )
        end
    end
    cells:shuffle()
    return cells
end



-- It Applies a function to all elements. Works with collections or with tables.
function utl_coll.ask(elements, funct)
    if elements.order then
        for _,v in ipairs(elements.order)do
            funct( elements.agents[v] )
        end
    else
        for _,v in pairs(elements)do
            funct(v)
        end
    end
end

-- Removes an element in a collection
function utl_coll.die(agent, Agents)
    Agents:kill(agent)
end

-- This function encapsulates a call to the function clone_n_act in the collection given as parameter
function utl_coll.clone_n_act(n,agent,collection, funct)
    return collection:clone_n_act(n,agent,funct)
end

return utl_coll