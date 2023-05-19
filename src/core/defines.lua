defines = defines or {}

defines.events = defines.events or {}

defines.mod = defines.mod or {}

defines.mod.tag = "rs"
defines.mod.mod_name = "ResourcesScanner"

defines.mod.command = {}
defines.mod.command.name="rs"
defines.mod.command.header="Resource Scanner Command"

defines.mod.default = {}
defines.mod.default.filter = "all"
defines.mod.default.limit = 10000

defines.constant = {}
defines.constant.settings_mod = {
    scan_step_by_tick = {
        type = "int-setting",
        setting_type = "runtime-global",
        localised_name = {"rs_user_settings.scan_step_by_tick"},
        localised_description = {"rs_user_settings.scan_step_by_tick_desc"},
        default_value = 10,
        minimum_value = 1,
        maximum_value = 10,
        order = "a1"
    },
}