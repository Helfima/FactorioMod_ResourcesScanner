require "core.defines"
require "core.tableExtends"
require "core.class"
require "core.util"
require "core.Object"

Player = require "models.Player"
Cache = require "models.Cache"
Resources_Manager = require("scripts.resources_manager")

local handler = require("event_handler")

local controller = require("scripts.controller")
handler.add_lib(controller)

handler.add_lib(Resources_Manager)
