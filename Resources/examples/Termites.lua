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

    -- Populate the Family with 3 agents. Each agent will have the parameters
    -- specified in the table (and some parameters obteined just for be a Mobil instance)

    sw = Interface:get_value('Size_World')
    for i=1,Interface:get_value("N_Termites") do
        Termites:new({
            pos         = {math.random(-(sw/2-5),(sw/2-5)),math.random(-(sw/2-5),(sw/2-5))},
            heading     = random_float(0, 2*math.pi),
            color       = color('red'),
            state       = "search"
        })
    end
    
    declare_FamilyCell('Cells')
    -- Create cells and give a grid structure to them
    Cells:create_grid(sw, sw, -sw/2, -sw/2) -- width, height, offset x, offset y
    
    for _,c in ordered(Cells) do
      c.is_chip = (math.random(100) < Interface:get_value('Density')) 
      c.color   = c.is_chip and color('yellow') or color('black')
    end
end

-----------------
-- Step Function
-----------------

STEP = function()
    -- Iterate Agents shuffled to move them, grow and reproduce
    for _,termite in shuffled(Termites) do
      if termite.state == "search" then
        if Cells:cell_of(termite).is_chip then
          termite.state = "find"
          Cells:cell_of(termite).is_chip = false
          Cells:cell_of(termite).color = color('black')
          termite:rt(random_float(-0.4,0.4))
          termite:fd(5)
          termite:pos_to_torus(-sw/2,sw/2,-sw/2,sw/2)
        else
          termite:rt(random_float(-0.4,0.4))
          termite:fd(1)
          termite:pos_to_torus(-sw/2,sw/2,-sw/2,sw/2)
        end
      end
      if termite.state == "find" then
        if not Cells:cell_of(termite).is_chip then
          termite:rt(random_float(-0.4,0.4))
          termite:fd(1)
          termite:pos_to_torus(-sw/2,sw/2,-sw/2,sw/2)
        else
          termite.state = "put"
        end
      end
      if termite.state == "put" then
        while Cells:cell_of(termite).is_chip do
          termite:rt(random_float(-math.pi,math.pi))
          termite:fd(1)
          termite:pos_to_torus(-sw/2,sw/2,-sw/2,sw/2)
        end
        Cells:cell_of(termite).is_chip = true
        Cells:cell_of(termite).color = color('yellow')
        termite:move_to(one_of(Cells:with(function(c) return not c.is_chip end)))
        termite.state = "search"
      end
    end
    
end
