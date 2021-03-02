--[[
    An example of growing and cloning of agents.

    It uses customized methods for families and several standard methods
    (die, clone) and agent properties (alive)
]]

-----------------
-- Interface 
-----------------
Interface:create_slider('N_Termites', 0, 300, 1, 10)
Interface:create_slider('Density', 0, 100, 1, 20)

----------------
-- Setup Function
-----------------

SETUP = function()

    -- clear('all')
    Simulation:reset()

    -- Create a Family of Mobile agents
    declare_FamilyMobile('Termites')

    Termites:add_method('pos_to_torus', function(self, minsize_x, maxsize_x, minsize_y, maxsize_y)
        -- Current position of agent
        local x,y = self:xcor(),self:ycor()
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
        -- Always a method must return the self agent in order to concatenate methods
        return self
    end)
  
  Termites:add_method('wiggle', 
    function(self, angle)
      self:rt(random_float(-angle,angle))
      self:fd(1)
      self:pos_to_torus(-50,50,-50,50)
      return self
    end)
  
  Termites:add_method('move_empty',
    function(self)
      self:move_to(one_of(Cells))
      if Cells:cell_of(self).has_chip then
        self:move_empty()
      else
        return self
      end
    end)
  
  Termites:add_method('search_chip',
    function(self)
      c = Cells:cell_of(self)
      if c.has_chip then
          self.state = 'find_pile'
          self.chip = copy(c.color)
          c.has_chip = false
          c.color = color('black')
          self:move_empty()
      else
          self:wiggle(0.4)
--          self:search_chip()
      end
    end)
 
  Termites:add_method('find_pile',
    function(self)
      c = Cells:cell_of(self)
      if same_rgb(c, self.chip) then
          self.state = 'put_chip'
      else  
          self:move_empty()
          self:wiggle(0.4)
  --        self:find_pile()
      end
    end)
 
  Termites:add_method('put_chip',
    function(self)
      c = Cells:cell_of(self)
      if c.has_chip then
          self:wiggle(math.pi)
    --      self:put_chip()
      else
          c.has_chip = true
          c.color = copy(self.chip)
          self:move_empty()
          self.state = 'search_chip'
      end
    end)
 
 
    -- Populate the Family with termites. Each termite will have the parameters
    -- specified in the table (and some parameters obteined just for be a Mobil instance)

    for i=1,Interface:get_value("N_Termites") do
        Termites:new({
            pos         = {math.random(-40,40),math.random(-40,40)},
            heading     = random_float(0, 2*math.pi),
            color       = color('red'),
            chip        = nil,
            state       = 'search_chip'
        })
    end
    
    declare_FamilyCell('Cells')
    -- Create cells and give a grid structure to them
    Cells:create_grid(100, 100, -50, -50) -- width, height, offset x, offset y
    
    col = {'red', 'green' , 'blue', 'yellow'}
--    col = {'green' , 'blue'}
    
    for _,c in ordered(Cells) do
      c.has_chip = (math.random(100) < Interface:get_value('Density')) 
      c.color   = c.has_chip and color(one_of(col)) or color('black')
    end
    
    action = {
      ['search_chip'] = function(x) x:search_chip() end,
      ['find_pile']   = function(x) x:find_pile() end,
      ['put_chip']    = function(x) x:put_chip() end,
      }
end

-----------------
-- Step Function
-----------------

STEP = function()

    -- Iterate Agents shuffled to move them, grow and reproduce
    for _,t in ordered(Termites) do
      ac = action[t.state]
      ac(t)
    end
end
