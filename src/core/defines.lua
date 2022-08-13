require "core.defines_builded"

defines = defines or {}
defines.events = defines.events or {}

defines.mod = {}
defines.mod.tag = "rs"
defines.mod.mod_name = "ResourcesScanner"

defines.mod.command = {}
defines.mod.command.name="rs"
defines.mod.command.header="Resource Scanner Command"
defines.mod.command.action = {}
defines.mod.command.action.menu="menu"
defines.mod.command.action.reset_ui="reset_ui"

defines.mod.default = {}
defines.mod.default.filter = "all"
defines.mod.default.limit = "0"

defines.mod.action = {}
defines.mod.action.main = "RSMapOptionsView=OPEN"

defines.mod.styles = {}
defines.mod.styles.frame = "inner_frame_in_outer_frame"
defines.mod.styles.inner = "inside_shallow_frame_with_padding"
defines.mod.styles.label = "heading_2_label"

defines.mod.views = {}
defines.mod.views.locate = {}
defines.mod.views.locate.top="top"
defines.mod.views.locate.left="left"
defines.mod.views.locate.center="center"
defines.mod.views.locate.goal="goal"
defines.mod.views.locate.screen="screen"

defines.mod.views.options = {}
defines.mod.views.options.name = "rs-view-options"
defines.mod.views.options.location = defines.mod.views.locate.center