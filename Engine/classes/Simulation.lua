------------------
-- A class to control some parameters related with the simulation as created families, number of agents or the time.
-- @classmod
-- Simulation

local class  = require 'Thirdparty.pl.class'

local Simulation = class.Simulation()

------------------
-- This function is called to create a new instance. A new instance of this class is created everytime the system starts.
-- @function _init
-- @return A Simulation instance.
-- @usage
-- Simulation = Simulation()
Simulation._init = function(self)
    self.seed           = os.time()
    self.is_running     = false
    self.time           = 0
    self.delta_time     = 1
    self.max_time       = 100
    self.families       = {}
    self.num_agents     = 0

    math.randomseed(self.seed)

    return self
end;

------------------
-- This function is used to erase a Family (or more than one) of the system.
-- @function clear
-- @param ... Variable number of string inputs, the names of the families we want to delete. If the string 'all' is passed as first parameter, all the families will be deleted.
-- @return Nothing.
-- @usage
-- Simulation.clear()
Simulation.clear = function(self, ...)

    local args = {...}

    self.time = 0

    if string.lower(args[1]) == 'all' then
        for k,v in next, self.families do
            for _,ag in ordered(v)do
                ag = nil
            end

            self.families[k] = nil
        end
        Simulation.families   = {}
        Simulation.num_agents = 0
    else
        for i,v in next, args do
            self.families[v] = nil
        end
    end
end

------------------
-- This function controls the ids of the agents, when a new agent is created, an unique id is given to it, this function generates new ids. This function is called by families when adding new agents.
-- @function __new_id
-- @return Number, a unique id.
-- @usage
-- -- The use of this function is not recomended. The system uses it to generate the agents' id
Simulation.__new_id = function(self)
    self.num_agents = self.num_agents + 1
    return self.num_agents
end;

------------------
-- This function set a new seed to be used when random methods are called.
-- @function new_seed
-- @return
-- @usage
-- -- TODO
Simulation.new_seed = function(self)
    self.seed = os.clock()
    math.randomseed(self.seed)

    return self.seed
end

--=========--
-- Getters --
--=========--

------------------
-- A function to get the current used seed.
-- @function get_seed
-- @return Number. The seed we are using
-- @usage
-- print(Simulation:get_seed())
-- @see new_seed
-- @see set_seed
Simulation.get_seed = function(self)
    return self.seed
end

------------------
-- A function to know if the simulation is running
-- @function get_is_running
-- @return Boolean.
-- @usage
-- if Simulation:get_is_running() then ...
Simulation.get_is_running = function(self)
    return self.seed
end

------------------
-- A function to know the current time of the system
-- @function get_time
-- @return Number
-- @usage
-- if Simulation:get_time() > 100 then ...
Simulation.get_time = function(self)
    return self.time
end

------------------
-- TODO
-- @function get_delta_time
-- @return
-- @usage
-- -- TODO
Simulation.get_delta_time = function(self)
    return self.delta_time
end

------------------
-- A limit of time for the simulation
-- @function get_max_time
-- @return Number. The maximum number of iterations. There will be no max if we set this value to 0.
-- @usage
-- if Simulation:get_time() > Simulation:get_max_time() then Simulation:stop() end
Simulation.get_max_time = function(self)
    return self.max_time
end

------------------
-- A method to acces to the families of the simulation.
-- @function get_families
-- @return Table. All the families created in the system.
-- @usage
-- for _,fam in pairs(Simulation:get_families()) do
--     print(fam.count)
-- end
Simulation.get_families = function(self)
    return self.families
end

------------------
-- This function return the number of agents of the system.
-- @function get_num_agents
-- @return Number. The agents in the system
-- @usage
-- print(Simulation:get_num_agents())
Simulation.get_num_agents = function(self)
    return self.num_agents
end

--=========--
-- Setters --
--=========--

------------------
-- This sets a seed to be used in random operations.
-- @function set_seed
-- @param num Number, the seed we want to use.
-- @return Nothing.
-- @usage
-- Simulation:set_seed(123456789)
Simulation.set_seed = function(self,num)
    self.seed = num
    math.randomseed = self.seed
end;

------------------
-- This function set the value of 'is_running' to false.
-- @function stop
-- @return Nothing.
-- @usage
-- if Simulation:get_num_agents() == 0 then
--     Simulation:stop()
-- end
Simulation.stop = function(self)
    self.is_running = false
end;

------------------
-- This function set the value of 'is_running' to true.
-- @function start
-- @return Nothing.
-- @usage
-- Simulation:start()
Simulation.start = function(self)
    self.is_running = true
end;

------------------
-- This function reset ALL the parameters (families included) to its original values
-- @function reset
-- @return Nothing.
-- @usage
-- Simulation:reset()
Simulation.reset = function(self)
    self.is_running     = false
    self.time           = 0
    self.delta_time     = 1
    self.max_time       = 100
    self.families       = {}
    self.num_agents     = 0
end;

------------------
-- This function returns the number of agents by its family class
-- @function number_of_agents
-- @return Number, Number, Number. Cells, Mobils and Relational number of agents.
-- @usage
-- local N_cells, N_mobiles, N_rels = Simulation:number_of_agents()
Simulation.number_of_agents = function(self)
    local cells,mobils,rels = 0,0,0
    for k,v in next, self.families do
        if v:is_a(FamilyMobile) then
            mobils = mobils + v.count
        elseif v:is_a(FamilyCell) then
            cells = cells + v.count

        else
            rels = rels + v.count
        end
    end
    return cells,mobils,rels
end



return Simulation