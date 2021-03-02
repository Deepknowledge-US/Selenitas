--[[
    An example of growing and cloning of agents.
]]

-----------------
-- Interface 
-----------------
Interface:create_slider('N_Termites', 0, 300, 1, 10)
Interface:create_slider('Size_World',1,100,1,30)
Interface:create_slider('Density', 0, 100, 1, 20)

----------------
-- Setup Function
-----------------

SETUP = function()

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

    sw = Interface:get_value('Size_World')

    col = {'red', 'green' , 'blue', 'yellow'}
--    col = {'green' , 'blue'}

    declare_FamilyCell('Cells')
    -- Create cells and give a grid structure to them
    Cells:create_grid(sw, sw, -sw/2, -sw/2) -- width, height, offset x, offset y
    
    for _,c in ordered(Cells) do
      c.is_chip = (math.random(100) < Interface:get_value('Density')) 
      c.color   = c.is_chip and color(one_of(col)) or color('black')
    end

    -- Populate the Family with 3 agents. Each agent will have the parameters
    -- specified in the table (and some parameters obteined just for be a Mobil instance)

    for i=1,Interface:get_value("N_Termites") do
        Termites:new({
            pos         = copy(Cells:one_of().pos),
            heading     = random_float(0, 2*math.pi),
            color       = color(one_of(col)),
            state       = "search"
        })
    end
    
    
end

-----------------
-- Step Function
-----------------

STEP = function()
    -- Iterate Agents shuffled to move them, grow and reproduce
    for _,t in shuffled(Termites) do
      c = Cells:cell_of(t) 
      if t.state == "search" then
        if c.is_chip and same_rgb(c,t) then
          t.state = "find"
          c.is_chip = false
          c.color = color('black')
          t:rt(random_float(-0.4,0.4))
          t:fd(5)
          t:pos_to_torus(-sw/2,sw/2,-sw/2,sw/2)
        else
          t:rt(random_float(-0.4,0.4))
          t:fd(1)
          t:pos_to_torus(-sw/2,sw/2,-sw/2,sw/2)
        end
      end
      if t.state == "find" then
        if not same_rgb(c,t) then
          t:rt(random_float(-0.4,0.4))
          t:fd(1)
          t:pos_to_torus(-sw/2,sw/2,-sw/2,sw/2)
        else
          t.state = "put"
        end
      end
      if t.state == "put" then
        while Cells:cell_of(t).is_chip do
          t:rt(random_float(-math.pi,math.pi))
          t:fd(1)
          t:pos_to_torus(-sw/2,sw/2,-sw/2,sw/2)
        end
        c = Cells:cell_of(t)
        c.is_chip = true
        c.color = copy(t.color)
        t:move_to(one_of(Cells:with(function(c) return not c.is_chip end)))
        t.state = "search"
      end
    end
    
end
