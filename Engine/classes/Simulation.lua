------------------
-- A class to control some parameters related with the simulation as created families, number of agents or the time.
-- @classmod
-- Simulation

local class  = require 'Thirdparty.pl.class'

local Simulation = class.Simulation()

------------------
-- TODO
-- @function _init
-- @param obj A table with some basic parameters of the Controller.
-- @return A Controller instance.
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
-- This function is used to erase a Family of the system.
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
-- -- TODO
Simulation.__new_id = function(self)
    self.num_agents = self.num_agents + 1
    return self.num_agents
end;

------------------
-- TODO
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
-- TODO
-- @function get_seed
-- @return
-- @usage
-- -- TODO
Simulation.get_seed = function(self)
    return self.seed
end

------------------
-- TODO
-- @function get_is_running
-- @return
-- @usage
-- -- TODO
Simulation.get_is_running = function(self)
    return self.seed
end

------------------
-- TODO
-- @function get_time
-- @return
-- @usage
-- -- TODO
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
-- TODO
-- @function get_max_time
-- @return
-- @usage
-- -- TODO
Simulation.get_max_time = function(self)
    return self.max_time
end

------------------
-- TODO
-- @function get_families
-- @return
-- @usage
-- -- TODO
Simulation.get_families = function(self)
    return self.families
end

------------------
-- TODO
-- @function get_num_agents
-- @return
-- @usage
-- -- TODO
Simulation.get_num_agents = function(self)
    return self.num_agents
end

--=========--
-- Setters --
--=========--

------------------
-- This sets a seed to be used in random operations.
-- @function set_seed
-- @param num Number, the seed we want to use
-- @return Nothing.
-- @usage
-- -- TODO
Simulation.set_seed = function(self,num)
    self.seed = num
    math.randomseed = self.seed
end;

------------------
-- TODO
-- @function stop
-- @return Nothing.
-- @usage
-- -- TODO
Simulation.stop = function(self)
    self.is_running = false
end;

------------------
-- TODO
-- @function start
-- @return Nothing.
-- @usage
-- -- TODO
Simulation.start = function(self)
    self.is_running = true
end;

------------------
-- TODO
-- @function reset
-- @return Nothing.
-- @usage
-- -- TODO
Simulation.reset = function(self)
    self.is_running     = false
    self.time           = 0
    self.delta_time     = 1
    self.max_time       = 100
    self.families       = {}
    self.num_agents     = 0
end;

------------------
-- TODO
-- @function reset
-- @return Nothing.
-- @usage
-- -- TODO
Simulation.number_of_agents = function(self)
    local cells,mobils,rels = 0,0,0
    for k,v in next, self.families do
        if v:is_a(FamilyMobil) then
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