require "lib.core.class"
require "lib.core.Format"
require "lib.core.logging"
require "lib.core.Object"
require "lib.core.tableExtends"
require "lib.core.util"
require "lib.gui.Gui"

Cache = require "lib.data.Cache"
User = require "lib.data.User"

Area = require "lib.models.Area"
Chunk = require "lib.models.Chunk"
EntityPrototype = require "lib.models.EntityPrototype"
Player = require "lib.models.Player"
Resource = require "lib.models.Resource"

require "lib.controllers.Dispatcher"
require "lib.views.Form"
require "lib.views.AdminPanel"

Form.views["LibAdmin"] = AdminPanel("LibAdmin")
