------------------
-- A class to show in the interface some information related with the families.
-- @classmod
-- WindowFamilyInfo

local class  = require 'Thirdparty.pl.class'

local WFI = class.WindowFamilyInfo()

------------------
-- This function is called when a new family is created, and it creates a new window with information related to this family.
-- @function _init
-- @param a_table. A table with values for the window.
WFI._init = function(self, a_table)

    self.title          = a_table.title
    self.width          = a_table.width  or 150
    self.height         = a_table.height or 200
    self.x              = a_table.x      or (10 + 155 * Interface.num_family_windows)
    self.y              = a_table.y      or 500
    self.order          = {}
    self.info           = {}

    self:init_info(self.title)
    return self
end;

------------------
-- This function updates the counter of items of the window
-- @function __new_item
WFI.__new_item = function(self, name)
    self.num_items = self.num_items + 1
    self.order[self.num_items] = name
end

------------------
-- This function populate the window with some info related to the family
-- @function init_info
-- @param family_name String. The name of the family
-- @return Nothing
WFI.init_info = function(self, family_name)
    table.insert(self.order, 'name')
    table.insert(self.order, 'count')
    table.insert(self.order, '__to_purge')
    -- properties = {}
    -- return
end

------------------
-- This function is called to print the family info in the window
-- @function update_family_info
-- @return Nothing
WFI.update_family_info = function(self)
    for i=1, #self.order do
        local attr = Simulation.families[self.title][self.order[i]]
        self.info[self.order[i]] = type(attr) == 'table' and #attr or attr
    end
end

return WFI