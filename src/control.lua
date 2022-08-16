require "core.defines"
require "lib.lib_require"

Resources_Manager = require("scripts.resources_manager")

local handler = require("event_handler")

local controller = require("scripts.controller")
handler.add_lib(controller)

handler.add_lib(Resources_Manager)
