require "core.defines"
require "core.tableExtends"
require "core.class"
require "core.util"
require "core.Object"

Player = require "models.Player"
Cache = require "models.Cache"

local handler = require("event_handler")

local controller = require("scripts.controller")
handler.add_lib(controller)

local resources_manager = require("scripts.resources_manager")
handler.add_lib(resources_manager)
