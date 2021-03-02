--[[
    Combined use of cells and Mobile Agents
]]

------------
-- Interface
------------

-- Number of Mobile Agents
Interface:create_slider('initial-number-sheeps', 0, 250, 1, 100)
Interface:create_slider('initial-number-wolves',0,250,1,50)
Interface:create_slider('grass-regrowth-time',0,100,1,30)
Interface:create_slider('sheep-gain-from-food',0.0,50.0,1.0,4.0)
Interface:create_slider('wolf-gain-from-food',0.0,100.0,1.0,20.0)
Interface:create_slider('sheep-reproduce',1.0,20.0,1.0,4.0)
Interface:create_slider('wolf-reproduce',0.0,20.0,1.0,5.0)

brown = {157/255, 110/255, 72/255, 1}
-----------------
-- Setup Function
-----------------

SETUP = function()

    -- We reset everything
    Simulation:reset()

    -- Create a Family of Structural Agents
    declare_FamilyCell('Grass')
    sw = 50
    Grass:create_grid(sw,sw,-sw/2,-sw/2) -- width, height, offset x, offset y

    -- Set color of the cells
    for _,c in ordered(Grass) do
      local choose = math.random(2)
      if choose == 1 then
        c.color   = color('green')    -- Green color
        c.grass   = true
        c.countdown = Interface:get_value('grass-regrowth-time')
      else
        c.color   = copy(brown)
        c.grass   = false
        c.countdown = math.random(Interface:get_value('grass-regrowth-time'))
      end
    end

    -- Create Sheeps
    declare_FamilyMobile('Sheeps')
    n_sheeps = Interface:get_value('initial-number-sheeps')
    food = Interface:get_value('sheep-gain-from-food')
    for i = 1, n_sheeps do
        Sheeps:new({
            shape = "circle",
            pos  = copy(one_of(Grass).pos),
            color = color('white'),
            scale = 1,
            heading = math.random(2*math.pi),
            energy = math.random(2*food)
        })
    end

    -- Create Wolves
    declare_FamilyMobile('Wolves')
    n_wolves = Interface:get_value('initial-number-wolves')
    food = Interface:get_value('wolf-gain-from-food')
    for i = 1, n_wolves do
        Wolves:new({
            shape = "circle",
            pos  = copy(one_of(Grass).pos),
            color = color('black'),
            scale = 1,
            heading = math.random(2*math.pi),
            energy = math.random(2*food)
        })
    end
    
    declare_FamilyMobile('Controls')
    c_wolves = Controls:new({
        shape = "circle",
        pos   = {40,20},
        color = color('grey'),
        label = Wolves.count,
        show_label = true,
        scale = Wolves.count / 10
      })
    c_sheeps = Controls:new({
        shape = "circle",
        pos   = {40,0},
        color = color('white'),
        label = Sheeps.count,
        label_color = color('black'),
        show_label = true,
        scale = Sheeps.count / 10
      })
    c_grass = Controls:new({
        shape = "circle",
        pos   = {40,-20},
        color = color('green'),
        label = Grass:with(function(c) return c.grass end).count,
        show_label = true,
        scale = Grass:with(function(c) return c.grass end).count / 100
        })

    Sheeps:add_method('eat_grass', 
      function(self)
        local c = Grass:cell_of(self)
        if c.grass then
          self.energy = self.energy + Interface:get_value('sheep-gain-from-food')
          c.color = copy(brown)
          c.grass = false
        end
        return self
      end)
    
    Sheeps:add_method('reproduce_sheep',
      function(self)
        if math.random(100) < Interface:get_value('sheep-reproduce') then
          self.energy = self.energy / 2
          Sheeps:clone_n(1, self, function(s) s:rt(math.random(2*math.pi)):fd(1) end)
        end
        return self
      end)
  
    Wolves:add_method('reproduce_wolf',
      function(self)
        if math.random(100) < Interface:get_value('wolf-reproduce') then
          self.energy = self.energy / 2
          Wolves:clone_n(1, self, function(w) w:rt(math.random(2*math.pi)):fd(1) end)
        end
        return self
      end)
    
    Wolves:add_method('eat_sheep',
      function(self)
        local preys = Sheeps:with(function(s) return s:dist_euc2_to(self) < 1 end)
        if preys.count > 0 then
          local prey = one_of(preys)
          self.energy = self.energy + Interface:get_value('wolf-gain-from-food')
          kill_and_purge(prey)
        end
        return self
      end)
    
    Grass:add_method('grow_grass',
      function(self)
        if not self.grass then
          if self.countdown <= 0 then
            self.countdown = Interface:get_value('grass-regrowth-time')
            self.color = color('green')
            self.grass = true
          else
            self.countdown = self.countdown - 1
          end
        end
        return self
      end)

end

-----------------
-- Step Function
-----------------

move = function(self)
  local turn = random_float(-math.pi/6,math.pi/6)
  self:rt(turn):fd(1)
  pos_to_torus(self,-25,25,-25,25)
end

pos_to_torus = function(self, minsize_x, maxsize_x, minsize_y, maxsize_y)
        -- Current position of agent
        local x,y = self.pos[1],self.pos[2]
        -- Change coordinates to restrict inside the torus
        if x > maxsize_x then
            self.pos[1] =  minsize_x + (x - maxsize_x)
        elseif x < minsize_x then
            self.pos[1] = maxsize_x - (minsize_x - x)
        end
        if y > maxsize_y then
            self.pos[2] =  minsize_y + (y - maxsize_y)
        elseif y < minsize_y then
            self.pos[2] = maxsize_y - (minsize_y - y)
        end
        -- A method must return the self agent in order to concatenate methods
        return self
      end

STEP = function()
  
  local wc = Wolves.count
  local sc = Sheeps.count
  c_wolves.label = wc
  c_wolves.scale = wc/10
  c_sheeps.label = sc
  c_sheeps.scale = sc/10
  c_grass.label = Grass:with(function(c) return c.grass end).count
  c_grass.scale = c_grass.label/100
  if wc == 0 or sc == 0 then
    Simulation:stop()
  end
  
  for _,s in shuffled(Sheeps) do
    move(s)
    s.energy = s.energy - 1
    s:eat_grass()
    if s.energy < 0 then 
      kill_and_purge(s)
    else
      s:reproduce_sheep()
    end
  end
  
  for _,w in shuffled(Wolves) do
    move(w)
    w.energy = w.energy - 1
    w:eat_sheep()
    if w.energy < 0 then 
      kill_and_purge(w)
    else
      w:reproduce_wolf()
    end
  end
  
  for _,c in ordered(Grass) do
    c:grow_grass()
  end
  
 

end
