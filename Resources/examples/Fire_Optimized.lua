--[[
    Classical Fire Model
]]

------------
-- Interface
------------

-- Initial proportion of alive cells

Interface:create_slider('World_Size', 0, 500, 1, 100)
Interface:create_slider('Density', 0, 100, 1, 50)

---------------------
-- Auxiliar Functions
---------------------

local function pred_is_tree(t)
    return t.is_tree
end

local function pred_is_burning(t)
    return t.is_burning
end


-----------------
-- Setup Function
-----------------

SETUP = function()

    Simulation:reset()

    -- Create a Family of Structural Agents
    declare_FamilyCell('Trees')

    -- Create cells and give a grid structure to them
    local ws = Interface:get_value('World_Size')
    Trees:create_grid(ws, ws, -ws/2, -ws/2) -- width, height, offset x, offset y


    -- Set (and color) the alive cells folowwing Density in the interface
    for _,t in ordered(Trees) do
        t.is_tree = (math.random(100) < Interface:get_value('Density')) 
        t.color   = t.is_tree and color('green') or color('black')
    end
        
    local start_fire = one_of(Trees:with(pred_is_tree))
    start_fire.color = color('red')
    
    burning = Collection()
    burning:add(start_fire)
end

-----------------
-- Step Function
-----------------

STEP = function()
  
  if burning.count > 0 then
    for _,t in ordered(burning) do
      for _,t2 in ordered(t.neighbors:with(pred_is_tree)) do
        t2.color = color('red')
        burning:add(t2)
      end
      burning:remove(t)
      t.color = color('grey')
      t.is_tree = false
    end
  else
    Simulation:stop()
  end
end


