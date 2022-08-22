defines = defines or {}
defines.events = defines.events or {}

defines.mod = {}

defines.mod.events = {}
defines.mod.events.on_gui_action = "on_gui_action"
defines.mod.events.on_gui_queue = "on_gui_queue"
defines.mod.events.on_gui_event = "on_gui_event"
defines.mod.events.on_gui_open = "on_gui_open"
defines.mod.events.on_gui_update = "on_gui_update"
defines.mod.events.on_gui_close = "on_gui_close"
defines.mod.events.on_gui_error = "on_gui_error"
defines.mod.events.on_gui_message = "on_gui_message"

defines.mod.events.pattern = "([^=]*)=?([^=]*)=?([^=]*)=?([^=]*)=?([^=]*)=?([^=]*)=?([^=]*)"

defines.mod.events.clickable_type = {}
defines.mod.events.clickable_type["button"] = true
defines.mod.events.clickable_type["sprite-button"] = true
defines.mod.events.clickable_type["choose-elem-button"] = true

defines.mod.styles = {}
defines.mod.styles.mod_gui_button = "frame_button"
defines.mod.styles.frame = "frame"
defines.mod.styles.inside_deep_frame = "inside_deep_frame"
defines.mod.styles.frame_inner_outer = "inner_frame_in_outer_frame"
defines.mod.styles.frame_invisible ="invisible_frame"
defines.mod.styles.frame_action_button ="frame_action_button"
defines.mod.styles.inner = "inside_shallow_frame_with_padding"
defines.mod.styles.inner_tab = "inside_deep_frame_for_tabs"
defines.mod.styles.label = "heading_2_label"

defines.mod.views = {}
defines.mod.views.locate = {}
defines.mod.views.locate.top="top"
defines.mod.views.locate.left="left"
defines.mod.views.locate.center="center"
defines.mod.views.locate.goal="goal"
defines.mod.views.locate.screen="screen"

defines.mod.tags = {}
defines.mod.tags.color = {}
defines.mod.tags.color.close = "[/color]"
defines.mod.tags.color.white = "[color=255,255,255]"
defines.mod.tags.color.gray = "[color=229,229,229]"
defines.mod.tags.color.yellow = "[color=255,222,61]"
defines.mod.tags.color.red = "[color=255,0,0]"
defines.mod.tags.color.red_light = "[color=255,50,50]"
defines.mod.tags.color.green = "[color=0,127,14]"
defines.mod.tags.color.green_light = "[color=50,200,50]"
defines.mod.tags.color.blue = "[color=66,141,255]"
defines.mod.tags.color.blue_light = "[color=100,200,255]"
defines.mod.tags.color.gold = "[color=255,230,192]"
defines.mod.tags.color.orange = "[color=255,106,0]"
defines.mod.tags.color.black = "[color=0,0,0]"

defines.mod.tags.font = {}
defines.mod.tags.font.close = "[/font]"
defines.mod.tags.font.default_bold = "[font=default-bold]"
defines.mod.tags.font.default_semibold = "[font=default-semibold]"
defines.mod.tags.font.default_large_bold = "[font=default-large-bold]"

defines.mod.cardinal = {}
defines.mod.cardinal.unknown = 0
defines.mod.cardinal.north = 1
defines.mod.cardinal.east = 2
defines.mod.cardinal.south = 4
defines.mod.cardinal.west = 8
