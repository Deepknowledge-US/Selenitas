--[[
    Infamous Ants model
]]

---------------
-- Interface --
---------------

-- Number of Ants
Interface:create_slider('population', 0, 200, 1, 125)
-- Diffusion rate of chemicals in the world
Interface:create_slider('diffusion-rate',0,99,1,50)
-- Evaporation rate of chemicals
Interface:create_slider('evaporation-rate',0,99,1,10)
-- All visible or only the active ants (carrying food or following chemical paths)
Interface:create_boolean('view_all', true)

---------------
-- Globals   --
---------------

-- Colors of nest and food sources
cn = color('dark_violet')
c1 = shade_of(color('blue'),0.7)
c2 = shade_of(color('blue'),0)
c3 = shade_of(color('blue'),-0.7)
--------------------
-- Agents Methods --
--------------------
new_methods = function()
  
  -- Wiggle move (bounded in the world)
  Ants:add_method('wiggle',
    function(self)
      local turn = random_float(-math.pi/8,math.pi/8)
      self:rt(turn):fd(1)
      if math.abs(self.pos[1]) > sw/2 or math.abs(self.pos[2]) > sw/2 then
        self:fd(-1):rt(2*math.pi*math.random())
      end
      return self
    end)

  -- Trick to return to nest when carrying food
  -- the ant deposit chemical while going to the nest
  Ants:add_method('return_to_nest',
    function(self)
      c = Ground:cell_of(self)
      if c.nest then
        self:rt(math.pi)
        self.search = true
        self.color = color('red') 
        self.visible = false or Interface:get_value('view_all')
      else
        c.chemical = c.chemical + 60
        self:face(c.neighbors:max_one_of(function(x) return x.nest_scent end))
      end
      return self
    end)
  
  -- Look for food while moving
  -- If the ant finds chemical, the it will follow the path
  -- Otherwise, it will move around
  -- its state changes when it finds food (to go to the nest)
  Ants:add_method('look_for_food',
    function(self)
      c = Ground:cell_of(self)
      if c.food > 0 then
        c.food = c.food - 1
        self.color = color('blue')
        self.visible = true or Interface:get_value('view_all')
        self:rt(math.pi)
        self.search = false
      else
        if c.chemical >= 0.1 and c.chemical < 2 then
          self.color = color('pink')
          self.visible = true or Interface:get_value('view_all')
          an = self:uphill_chemical()
          self:lt(an)
        else
          self.color = color('red')
          self.visible = false or Interface:get_value('view_all')
        end
      end
      return self
    end)
  
  -- Recolor one gorund cell to show the chemicals
  Ground:add_method('recolor',
    function(self)
      if self.nest then self.color = cn 
      elseif self.food_source_number == 1 and self.food > 0 then self.color = c1
      elseif self.food_source_number == 2 and self.food > 0 then self.color = c2
      elseif self.food_source_number == 3 and self.food > 0 then self.color = c3
      else self.color = shade_of(color('green'),-.8+3*self.chemical)
      end
      return self
    end)
  
  -- Returns the direction (among 0,pi/4,-pi/4) where the chemical is maximal
  Ants:add_method('uphill_chemical',
    function(self)
      scent_ahead = self:chemical_at_angle(0)
      scent_right = self:chemical_at_angle(math.pi/4)
      scent_left  = self:chemical_at_angle(-math.pi/4)
      if (scent_right > scent_ahead) or (scent_left > scent_ahead) then
        if scent_right > scent_left then return math.pi/4 else return -math.pi/4 end
      else 
        return 0
    end
  end)
  
  -- Returns the amount of chemical in the ground cell in front of the ant
  -- and angle right turn
  Ants:add_method('chemical_at_angle',
    function(self,angle)
      c = Ground:cell_of(self)
      nang = self.heading + angle
      ncx = c.pos[1]+math.cos(nang)
      ncy = c.pos[2]+math.sin(nang)
      if math.abs(ncx) > sw/2 or math.abs(ncy) > sw/2 then return 0 end
      nc = Ground:cell_of({ncx,ncy})
      return nc.chemical
    end)
  
end
  
-----------------
-- Setup Model --
-----------------

SETUP = function()

    -- We reset everything
    Simulation:reset()

    -- Declare Families and new methods
    declare_FamilyCell('Ground')
    declare_FamilyMobile('Ants')
    new_methods()
    
    -- world size
    sw = 70
    -- Ground creation
    Ground:create_grid(sw,sw,-sw/2,-sw/2) -- width, height, offset x, offset y

    -- Ground construction: nest, food sources, and chemicals
    for _,c in ordered(Ground) do
      -- No chemicals in the beginning
      c.chemical = 0
      c.food = 0
      -- Mark the nest
      c.nest = c:dist_euc_to({0,0}) < 5
      if c.nest then c.color = color('dark_violet') end
      c.nest_scent = (55 - c:dist_euc_to({0,0}))/55
      -- Mark the 3 food sources
      c.food_source_number = 0
      if c:dist_euc_to({0.3*sw,0}) < 5 then 
        c.food_source_number = 1 
        c.color = c1
      end
      if c:dist_euc_to({-0.3*sw,-0.3*sw}) < 5 then 
        c.food_source_number = 2 
        c.color = c2
      end
      if c:dist_euc_to({-0.4*sw,0.4*sw}) < 5 then 
        c.food_source_number = 3 
        c.color = c3
      end
      -- Assign random food to food sources
      if c.food_source_number > 0 then c.food =   one_of({1,2}) end
      c:recolor()
    end
        
    -- Create Ants. At the beginning, all of them are in the nest
    n_ants = Interface:get_value('population')
    for i = 1, n_ants do
        Ants:new({
            shape = "triangle",
            id    = i,
            pos  = {0,0},
            color = color('red'),
            scale = 1,
            heading = math.random(2*math.pi),
            search  = true,
            visible = false or Interface:get_value('view_all')
        })
    end
    

end
-----------------
-- Step Function
-----------------

STEP = function()
  
  -- Current values from interface
  dif = Interface:get_value('diffusion-rate')/100
  ev = (100 - Interface:get_value('evaporation-rate')) / 100
  
  -- Update ants
  for _,a in shuffled(Ants) do
    -- The ants start moving gradually
    if Simulation:get_time() > a.id then
      -- Ant cycle is simple: look for food -> return_to nest -> look for food ...
      if a.search then
        a:look_for_food()
      else
        a:return_to_nest()
      end
      a:wiggle()
    end
  end
  -- Diffuse chemicals in the ground
  Ground:diffuse("chemical", dif,1)
  for _,c in ordered(Ground) do
    c.chemical = c.chemical * ev
    c:recolor()
  end
  
end