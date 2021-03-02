--[[
    Some experient with vibration waves
]]

-----------------
-- Interface 
-----------------
-- Number of points to approximates the waves
Interface:create_slider('Resolution', 0, 5000, 10, 1000)
-- Cycle length to change the curve
Interface:create_slider('Cycle',0,100,1,20)

----------------------
-- Global Variables --
----------------------

-- Dominion of the curves [0,Interval]
local Interval  = 30

-- Table of base functions to draw
functions = {
  math.sin,
  math.cos,
  function(x) return math.sin(x)^2 end,
  function(x) return math.cos(x)^2 end,
  function(x) return math.sin(x)*math.cos(x) end
  }

-- Coefficients for curves
  A  = 5
  Ph = 1

-----------------
-- Setup Function
-----------------

SETUP = function()

    -- Reset Simulation
    Simulation:reset()

    -- Family for Control Points of the graph
    declare_FamilyMobile('Points')
    
    -- Distance between points in the X axis
    local Num_Points = Interface:get_value("Resolution")
    local xinc = Interval / (Num_Points-1)
    local xpos = 0
    
    -- Create the points in the X axis
    -- yinc will be used to move the point from one function position to another
    
    for i=1,Num_Points do
      Points:new({
            pos     = {xpos,0},
            yinc    = 0,
            id      = i,
--            heading = math.pi/2,
            visible = false
      })
      xpos = xpos + xinc
    end
    
    -- Relational family to draw the line segments of the curves
    declare_FamilyRel('Segments')
    
    -- Create a segment between 2 consecutive points
    for i=1,Num_Points-1 do
      local p1 = one_of(Points:with(function(p) return p.id == i end))
      local p2 = one_of(Points:with(function(p) return p.id == i+1 end))
      Segments:new({
        source  = p1,
        target  = p2,
        color   = {1, 0, 0, 1},
        visible = true
      })
    end
end

-----------------
-- Step Function
-----------------

STEP = function()

  local cycle = Interface:get_value('Cycle')

  -- Change the function every "cycle" steps
  if Simulation:get_time() % cycle == 0 then
    -- Take a function from options
    local f = one_of(functions)
    -- Change amplitude and phase (this will enrich the available functions)
    A = A + (math.random() - .5)
    Ph = Ph + (math.random() - .5)
    -- Compute the new values for points and the yinc value to transform 
    -- one position into the other
    for _,p in ordered(Points) do
      npos = A * f(Ph * p.pos[1])
      p.yinc = (npos - p.pos[2])/cycle
    end
  end

  -- In every step approximate the points to their correct position
  for _,p in ordered(Points) do
--    p:fd(p.yinc)
    p.pos[2] = p.pos[2] + p.yinc
  end

end
