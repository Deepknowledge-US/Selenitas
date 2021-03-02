--[[
    Slime model
]]

---------------
-- Interface --
---------------

-- Number of Ants
Interface:create_slider('population', 0, 1500, 1, 400)
-- Diffusion rate of chemicals in the world
Interface:create_slider('sniff_threshold',0.000001,5.0,0.1,1)
-- Evaporation rate of chemicals
Interface:create_slider('sniff_angle',0,180,1,45)


--------------------
-- Agents Methods --
--------------------
new_methods = function()
  
  -- Adapt position to torus
  Slimes:add_method('pos_to_torus', 
    function(self, minsize_x, maxsize_x, minsize_y, maxsize_y)
      local x,y = self:xcor(),self:ycor()
      if x >= maxsize_x then self.pos[1] =  minsize_x
        elseif x <= minsize_x then self.pos[1] = maxsize_x 
      end
      if y >= maxsize_y then self.pos[2] =  minsize_y
        elseif y <= minsize_y then self.pos[2] = maxsize_y
      end
      return self
    end)
  
  -- Wiggle move (bounded in the world)
  Slimes:add_method('wiggle',
    function(self)
      local turn = random_float(-math.pi/6,math.pi/6)
      self:rt(turn):fd(1)
      return self
    end)

  -- Recolor one gorund cell to show the chemicals
  Medium:add_method('recolor',
    function(self)
      self.color = shade_of(color('green'),-.9+self.chemical/2)
      return self
    end)
  
  -- Returns the direction (among 0,pi/4,-pi/4) where the chemical is maximal
  Slimes:add_method('turn_toward_chemical',
    function(self)
      sa = Interface:get_value('sniff_angle')*math.pi/180
      ahead = self:chemical_at_angle(0)
      right = self:chemical_at_angle(-sa)
      left  = self:chemical_at_angle(sa)
      if (right > ahead) and (right > left) then
        self:rt(sa)
        if left >= ahead then
          self:lt(sa)
        end
      end
      self:fd(1)
      return self
    end)

  -- Returns the amount of chemical in the ground cell in front of the ant
  -- and angle right turn
  Slimes:add_method('chemical_at_angle',
    function(self,angle)
      c = Medium:cell_of(self)
      nang = self.heading + angle
      ncx = self.pos[1]+math.cos(nang)
      ncy = self.pos[2]+math.sin(nang)
      if math.abs(ncx) > sw/2 or math.abs(ncy) > sw/2 then return 0 end
      nc = Medium:cell_of({ncx,ncy})
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
    declare_FamilyCell('Medium')
    declare_FamilyMobile('Slimes')
    new_methods()
    
    -- world size
    sw = 80
    -- Medium creation
    Medium:create_grid(80,80,-40,-40) -- width, height, offset x, offset y

    -- Ground construction: nest, food sources, and chemicals
    for _,c in ordered(Medium) do
      -- No chemicals in the beginning
      c.chemical = 0
      c:recolor()
    end
        
    -- Create Ants. At the beginning, all of them are in the nest
    n_cells = Interface:get_value('population')
    for i = 1, n_cells do
        Slimes:new({
            shape = "triangle",
            color = color('red'), 
            scale = 1,
            heading = math.random(2*math.pi)
        })
    end
    for _,a in ordered(Slimes) do
      a:move_to(one_of(Medium))
    end
end
-----------------
-- Step Function
-----------------

STEP = function()
    
  -- Update slimes
  for _,a in shuffled(Slimes) do
    c = Medium:cell_of(a)
    if c.chemical > Interface:get_value('sniff_threshold') then
      a:turn_toward_chemical()
    else
      a:wiggle()
    end
    a:pos_to_torus(-39,39,-39,39)
    c = Medium:cell_of(a)
    c.chemical = c.chemical + 2
  end
  -- Diffuse chemicals in the ground
  Medium:diffuse("chemical", .9,1)
  for _,c in ordered(Medium) do
    c.chemical = c.chemical * 0.9
    c:recolor()
  end
  
end 