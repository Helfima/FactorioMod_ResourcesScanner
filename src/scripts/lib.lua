local module = require("scripts.resources_manager")
local lib = {}

lib.on_init = module.on_init
lib.on_load = module.on_load
lib.on_configuration_changed = module.on_configuration_changed
lib.add_commands = module.add_commands
lib.on_nth_tick = module.on_nth_tick

lib.events =
{
    [defines.events.on_lua_shortcut] = module.on_lua_shortcut,
    [defines.events.on_console_command] = module.on_console_command,
    [defines.events.on_resource_depleted] = module.on_resource_depleted,
    [defines.events.on_sector_scanned] = module.on_sector_scanned
}

return lib