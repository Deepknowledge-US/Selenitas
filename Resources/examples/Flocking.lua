--[[
    An example of growing and cloning of agents.

    It uses customized methods for families and several standard methods
    (die, clone) and agent properties (alive)
]]

-- 2D vectors extradted from here: https://github.com/themousery/vector.lua
local vector = require("vector.vector")

-----------------
-- Interface 
-----------------
Interface:create_slider('population', 1, 1000, 1, 300)
Interface:create_slider('vision', 0.0000001, 10.0, .5, 5.0)
Interface:create_slider('minimum-separation', 0.0000001, 10.0, .25, 3)
Interface:create_slider('align', 0.0000001, 2, .1, 1)
Interface:create_slider('cohesion', 0.0000001, 2, .1, 1)
Interface:create_slider('separation', 0.0000001, 2, .1, 1)

----------------------
-- Auxiliary Functions
----------------------


Boids_methods = function()
    -- New method for Agents family: relocate agents as they are living in a torus
    Boids:add_method('pos_to_torus', function(self, minsize_x, maxsize_x, minsize_y, maxsize_y)
        local x,y = self:xcor(),self:ycor()
        if x >= maxsize_x then self.pos[1] =  minsize_x
          elseif x <= minsize_x then self.pos[1] = maxsize_x 
        end
        if y >= maxsize_y then self.pos[2] =  minsize_y
          elseif y <= minsize_y then self.pos[2] = maxsize_y
        end
        return self
    end)
  
    Boids:add_method('update_flockmates', function(self, dis)
      self.flockmates = Boids:others(self):with(function(b) return self:dist_euc2_to(b) <= dis^2 end)
      return self
    end)
  
    Boids:add_method('flock_info', function(self)
      -- Average velocity
      vel = vector(0,0)
      -- Center of Mass
      cen = vector(0,0)
      -- Separation force
      sep = vector(0,0)
      
      N = self.flockmates.count
      
      for _,b in ordered(self.flockmates) do
        vel = vel + b.vvel
        cen = cen + b.vpos
        d = self:dist_euc2_to(b)
        if d < Interface:get_value('minimum-separation') then
          sep = sep + (self.vpos - b.vpos) / d
        end
      end
      vel = vel/N
      cen = cen/N
      sep = sep/N
      return vel, cen, sep
    end)
end

-----------------
-- Setup Function
-----------------

SETUP = function()

    -- clear('all')
    Simulation:reset()

    -- Create a Family of Mobile agents
    declare_FamilyMobile('Boids')

    -- Add new methods to Agents
    Boids_methods()

    -- Populate the Family with 3 agents. Each agent will have the parameters
    -- specified in the table (and some parameters obteined just for be a Mobil instance)

    for i=1,Interface:get_value("population") do
        Boids:new({
            pos         = {0,0},
            vpos        = vector(math.random(-50,50),math.random(-50,50)),
            vvel        = vector(4*math.random()-2,4*math.random()-2),
            vacc        = vector(0,0),
            color       = color('yellow'),
            flockmates  = nil
        })
    end
    for _,b in ordered(Boids) do
      b.pos = b.vpos:array()
    end
end

-----------------
-- Step Function
-----------------

STEP = function()

    -- Iterate Agents shuffled to move them, grow and reproduce
    for _,b in ordered(Boids) do
      b:update_flockmates(Interface:get_value('vision'))
      vflock, cflock, sflock = b:flock_info()
      
      align = vflock
      align = align:setmag(2)
      align = align - b.vvel
      align = align:limit(1)
      align = align * Interface:get_value('align')
      
      
      cohesion = cflock - b.vpos
      cohesion = cohesion:setmag(2)
      cohesion = cohesion - b.vvel
      cohesion = cohesion:limit(1)
      cohesion = cohesion * Interface:get_value('cohesion')
      
      separation = sflock
      separation = separation:setmag(2)
      separation = separation - b.vvel
      separation = separation:limit(1)
      separation = separation * Interface:get_value('separation')
      
      b.vacc = align + cohesion + separation
      b.vvel = b.vvel + b.vacc
      b.vvel = b.vvel:limit(2)
 
      b.vpos = b.vpos+ b.vvel
      b.heading = b.vvel:heading()
      b.pos = b.vpos:array()
      b:pos_to_torus(-50,50,-50,50)
      b.vpos = vector(b.pos[1], b.pos[2])
    end
         
    

end
