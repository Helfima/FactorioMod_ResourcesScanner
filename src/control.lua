require "core.defines"
require "lib.lib_require"
require("views.Views")

local handler = require("event_handler")

handler.add_lib(Dispatcher)

Form.views["RSMapOptionsView"] = MapOptionsView("RSMapOptionsView")

local controller = require("scripts.controller")
handler.add_lib(controller)

Resources_Manager = require("scripts.resources_manager")
handler.add_lib(Resources_Manager)

