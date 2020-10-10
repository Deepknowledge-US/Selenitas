local color = require "Visual.Colors"

local LuaColor = color.dark_red
local SelenitasColor = color.navy
local AgentColor = color.navy
local CellColor = color.navy
local MobileColor = color.navy
local RelationalColor = color.navy
local SimulationColor = color.green
local ObserverColor = color.green
local InterfaceColor = color.green
local utl_actionsColor = color.navy
local utl_checksColor = color.navy
local utl_famColor = color.navy
local utl_filtersColor = color.navy
local utl_iteratorsColor = color.navy
local utl_listColor = color.navy
local MainColor = color.green
local utl_numbersColor = color.navy
local utl_sfColor = color.navy
local FamilyColor = color.navy
local CollectionColor = color.navy
local PropColor = color.purple

local Selenitas_Syntax = {
	['function'] = LuaColor,
	['end'] = LuaColor,
	['if'] = LuaColor,
	['then'] = LuaColor,
	['local'] = LuaColor,
	['for'] = LuaColor,
	['do'] = LuaColor,
	['not'] = LuaColor,
	['while'] = LuaColor,
	['repeat'] = LuaColor,
	['until'] = LuaColor,
	['break'] = LuaColor,
	['else'] = LuaColor,
	['elseif'] = LuaColor,
	['in'] = LuaColor,
	['and'] = LuaColor,
	['or'] = LuaColor,
	['true'] = LuaColor,
	['false'] = LuaColor,
	['nil'] = LuaColor,
	['return'] = LuaColor,
  ['math.random'] = LuaColor,
  -- Properties
  ['pos'] = PropColor,
  ['heading'] = PropColor,
  ['color'] = PropColor,
  ['scale'] = PropColor,
  ['shape'] = PropColor,
  ['visible'] = PropColor,
  -- Agent
  ['_init'] =  AgentColor,
  ['is_in'] =  AgentColor,
  ['set_param'] =  AgentColor,
  ['link_neighbors'] =  AgentColor,
  ['in_link_neighbors'] =  AgentColor,
  ['out_link_neighbors'] =  AgentColor,
  ['__delete_in_neighs'] =  AgentColor,
  ['__delete_out_neighs'] =  AgentColor,
  ['__delete_links'] =  AgentColor,
  ['__purge'] =  AgentColor,
  ['__tostring'] =  AgentColor,
  -- Cell
  ['_init'] =  CellColor,
  ['xcor'] =  CellColor,
  ['ycor'] =  CellColor,
  ['zcor'] =  CellColor,
  ['region'] =  CellColor,
  ['come_in'] =  CellColor,
  ['come_out'] =  CellColor,
  -- Mobile
  ['_init'] =  MobileColor,
  ['xcor'] =  MobileColor,
  ['ycor'] =  MobileColor,
  ['zcor'] =  MobileColor,
  ['same_pos'] =  MobileColor,
  ['update_cell'] =  MobileColor,
  ['rt'] =  MobileColor,
  ['lt'] =  MobileColor,
  ['face'] =  MobileColor,
  ['fd'] =  MobileColor,
  ['move_to'] =  MobileColor,
  ['dist_euc_to'] =  MobileColor,
  ['dist_manh_to'] =  MobileColor,
  -- Relational
  ['_init'] =  RelationalColor,
  ['ends'] =  RelationalColor,
  ['target'] =  RelationalColor,
  ['source'] =  RelationalColor,
  -- Simulation
  ['Simulation'] =SimulationColor,
  ['_init'] =  SimulationColor,
  ['clear'] =  SimulationColor,
  ['__new_id'] =  SimulationColor,
  ['new_seed'] =  SimulationColor,
  ['get_seed'] =  SimulationColor,
  ['set_seed'] =  SimulationColor,
  ['get_is_running'] =  SimulationColor,
  ['get_time'] =  SimulationColor,
  ['get_delta_time'] =  SimulationColor,
  ['get_max_time'] =  SimulationColor,
  ['get_families'] =  SimulationColor,
  ['get_num_agents'] =  SimulationColor,
  ['set_seed'] =  SimulationColor,
  ['stop'] =  SimulationColor,
  ['start'] =  SimulationColor,
  ['reset'] =  SimulationColor,
  ['number_of_agents'] =  SimulationColor,
  -- Observer
  ['_init'] =  ObserverColor,
  ['set_center'] =  ObserverColor,
  ['set_zoom'] =  ObserverColor,
  ['get_center'] =  ObserverColor,
  ['get_zoom'] =  ObserverColor,
  -- Interface
  ['Interface'] = InterfaceColor,
  ['_init'] =  InterfaceColor,
  ['get_value'] =  InterfaceColor,
  ['create_boolean'] =  InterfaceColor,
  ['create_slider'] =  InterfaceColor,
  ['create_input'] =  InterfaceColor,
  -- utl_actions
  ['array_shuffle'] =  utl_actionsColor,
  ['rt'] =  utl_actionsColor,
  ['lt'] =  utl_actionsColor,
  ['fd'] =  utl_actionsColor,
  ['die'] =  utl_actionsColor,
  ['kill_and_purge'] =  utl_actionsColor,
  -- utl_checks
  ['is_family'] =  utl_checksColor,
  ['is_agent'] =  utl_checksColor,
  ['is_instance'] =  utl_checksColor,
  ['is_in_list'] =  utl_checksColor,
  ['exists'] =  utl_checksColor,
  ['all'] =  utl_checksColor,
  ['is_in'] =  utl_checksColor,
  ['same_rgb'] =  utl_checksColor,
  ['same_rgba'] =  utl_checksColor,
  ['same_pos'] =  utl_checksColor,
  -- utl_fam
  ['declare_FamilyMobile'] =  utl_famColor,
  ['declare_FamilyRel'] =  utl_famColor,
  ['declare_FamilyCell'] =  utl_famColor,
  ['clone_n'] =  utl_famColor,
  ['purge_agents'] =  utl_famColor,
  ['__producer'] =  utl_famColor,
  ['__consumer'] =  utl_famColor,
  -- utl_filters
  ['one_of'] =  utl_filtersColor,
  ['n_of'] =  utl_filtersColor,
  ['up_to_n_of'] =  utl_filtersColor,
  ['first_n'] =  utl_filtersColor,
  ['last_n'] =  utl_filtersColor,
  ['others'] =  utl_filtersColor,
  ['with'] =  utl_filtersColor,
  ['one_of_others'] =  utl_filtersColor,
  ['max_one_of'] =  utl_filtersColor,
  ['max_n_of'] =  utl_filtersColor,
  ['min_n_of'] =  utl_filtersColor,
  ['min_one_of'] =  utl_filtersColor,
  ['with_max'] =  utl_filtersColor,
  ['with_min'] =  utl_filtersColor,
  ['agents_in'] =  utl_filtersColor,
  ['find_families'] =  utl_filtersColor,
  -- utl_iterators
  ['__producer'] =  utl_iteratorsColor,
  ['__consumer'] =  utl_iteratorsColor,
  ['__comparator'] =  utl_iteratorsColor,
  ['__comparator_reverse'] =  utl_iteratorsColor,
  ['shuffled'] =  utl_iteratorsColor,
  ['ordered'] =  utl_iteratorsColor,
  ['sorted'] =  utl_iteratorsColor,
  ['merge_sort_agents'] =  utl_iteratorsColor,
  ['merge_ag'] =  utl_iteratorsColor,
  ['merge_sort_numbers'] =  utl_iteratorsColor,
  ['merge_num'] =  utl_iteratorsColor,
  -- utl_list
  ['fam_to_list'] =  utl_listColor,
  ['list_copy'] =  utl_listColor,
  ['list_remove'] =  utl_listColor,
  ['list_remove_index'] =  utl_listColor,
  -- Love
  ['SETUP'] =  MainColor,
  ['STEP'] =  MainColor,
  -- utl_numbers
  ['round'] =  utl_numbersColor,
  ['random_float'] =  utl_numbersColor,
  ['dist_euc_to'] =  utl_numbersColor,
  -- utl_sf
  ['lines_from'] =  utl_sfColor,
  ['split'] =  utl_sfColor,
  -- Family
  ['_init'] =  FamilyColor,
  ['add_method'] =  FamilyColor,
  ['clone_table'] =  FamilyColor,
  ['add_properties'] =  FamilyColor,
  ['kill'] =  FamilyColor,
  ['__purge_agents'] =  FamilyColor,
  ['kill_and_purge'] =  FamilyColor,
  ['clone_n'] =  FamilyColor,
  ['exists'] =  FamilyColor,
  ['all'] =  FamilyColor,
  ['is_in'] =  FamilyColor,
  ['others'] =  FamilyColor,
  ['one_of_others'] =  FamilyColor,
  ['with'] =  FamilyColor,
  ['one_of'] =  FamilyColor,
  ['n_of'] =  FamilyColor,
  ['up_to_n_of'] =  FamilyColor,
  ['max_one_of'] =  FamilyColor,
  ['max_n_of'] =  FamilyColor,
  ['min_n_of'] =  FamilyColor,
  ['min_one_of'] =  FamilyColor,
  ['with_max'] =  FamilyColor,
  ['with_min'] =  FamilyColor,
  ['get'] =  FamilyColor,
  ['count_all'] =  FamilyColor,
  ['keys'] =  FamilyColor,
  ['clone'] =  FamilyColor,
  ['alives_list'] =  FamilyColor,
  ['__tostring'] =  FamilyColor,
  ['create_grid'] =  FamilyColor,
  ['diffuse'] =  FamilyColor,
  ['cell_of'] =  FamilyColor,
  ['cell_in_pos'] =  FamilyColor,
  ['new'] =  FamilyColor,
  -- Collection
  ['_init'] =  CollectionColor,
  ['add'] =  CollectionColor,
  ['remove'] =  CollectionColor,
}

return Selenitas_Syntax