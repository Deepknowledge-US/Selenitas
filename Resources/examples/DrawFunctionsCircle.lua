--[[
    Some experient with vibration waves
]]

-----------------
-- Interface 
-----------------
-- Number of points to approximates the waves
Interface:create_slider('Resolution', 0, 1000, 10, 1000)
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
  A  = 10
  Ph = 0

-----------------
-- Setup Function
-----------------

SETUP = function()

    -- Reset Simulation
    Simulation:reset()

    -- Family for Control Points of the graph
    declare_FamilyMobile('Points')
    
    -- Distance between points in the X axis
    local a_inc = 4*math.pi / (Interface:get_value("Resolution"))
    local angle = 0
    
    -- Create the points in the X axis
    -- yinc will be used to move the point from one function position to another
    local Num_Points = Interface:get_value("Resolution")
    for i=1,Num_Points do
      Points:new({
            ['radius']  = 10,
            ['angle']   = angle,
            ['pos']     = {10 * math.cos(angle), 10 * math.sin(angle)},
            ['rinc']    = 0,
            ['id']      = i,
            ['visible'] = false
      })
      angle = angle + a_inc
    end
    
    -- Relational family to draw the line segments of the curves
    declare_FamilyRel('Segments')
    
    -- Create a segment between 2 consecutive points
    for i=1,Num_Points do
      nx = (i % Num_Points) + 1
      local p1 = one_of(Points:with(function(p) return p.id == i end))
      local p2 = one_of(Points:with(function(p) return p.id == nx end))
      Segments:new({
        ['source'] = p1,
        ['target'] = p2,
        ['color'] = {1, 0, 0, 1},
        ['visible'] = true
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
    A = A + 2*(math.random() - .5) 
    Ph = Ph + 2* math.random(0,1) - 1
    -- Compute the new values for points and the yinc value to transform 
    -- one position into the other
    for _,p in ordered(Points) do
      nr = math.abs(A + 5*f(Ph * p.angle))
      p.rinc = (nr - p.radius)/cycle
    end
  end

  -- In every step approximate the points to their correct position
  for _,p in ordered(Points) do
    p.radius = p.radius + p.rinc
    p.pos = {p.radius * math.cos(p.angle), p.radius * math.sin(p.angle)}
  end

end
