--- Icon builder use svg and inkscape
--- build=false skip to not rebuild Icon
--- paths = {{background},{foreground}}
--- -> put a list of path or polygon
--- -> for path {d="...",transform="rotate(-45.001 2.5 2.5)"} transform is optionnal
--- -> for polygon {p="...",transform="scale(0.5)"} transform is optionnal
--- at the end file you can change some parameter
--- -> for rebuild all change this at true: local force_build = false
--- -> for locate inkscape change: local inkscape = "E:\\Autre\\inkscape\\bin\\inkscape"
local sprites = {
    {
        name="jewel",
        size=64,
        count=4,
        colors = {
            black=true,
            white=true
        },
        paths={{
            
        },{
            {transform="scale(0.174)", d="M90.9,31.2L74,13.3c-0.8-0.8-1.8-1.3-2.9-1.3H20.9c-1.1,0-2.2,0.5-2.9,1.3l-16.9,18c-1.5,1.6-1.4,4,0.1,5.6l42,42c0.8,0.8,1.8,1.2,2.8,1.2s2.1-0.4,2.8-1.2l42-42C92.4,35.3,92.4,32.8,90.9,31.2z M27.4,37l7.4,21.6L13.2,37H27.4z M49.4,20l6.4,10H36.2l6.4-10H49.4z M46,70.3l0-0.2L34.8,37h22.4L46,70.1L46,70.3z M64.6,37h14.3L57.2,58.6L64.6,37zM79.2,30H64l-6.4-10h11.7L79.2,30z M22.6,20h11.7L28,30H12.8L22.6,20z"}
        }},
        build=true
    },
}

-------------------------------------------------------------------------------
--- builder functions
local function create_path(svg, path, color)
    if path.p ~= nil then
        if path.transform ~= nil then
            table.insert(svg, string.format("<polygon style=\"fill:%s\" transform=\"%s\" points=\"%s\"/>", color, path.transform, path.p))
        else
            table.insert(svg, string.format("<polygon style=\"fill:%s\" points=\"%s\"/>", color, path.p))
        end
    else
        if path.transform ~= nil then
            table.insert(svg, string.format("<path style=\"fill:%s\" transform=\"%s\" d=\"%s\"/>", color, path.transform, path.d))
        else
            table.insert(svg, string.format("<path style=\"fill:%s\" d=\"%s\"/>", color, path.d))
        end
    end
end

local function create_svg(sprite, background_color, foreground_color)
    local height = sprite.size
    local width = 0
    local transforms = {}
    for i = 1, sprite.count, 1 do
        local x = width
        local scale = 2 * ( sprite.size / 16 ) / ( 2 ^ i )
        local transform = string.format("translate(%s 0) scale(%s)", x, scale)
        table.insert(transforms, transform)
        width = width + 2 * sprite.size / ( 2 ^ i )
    end
    local svg = {}
    table.insert(svg, string.format("<svg viewBox=\"0 0 %s %s\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:svg=\"http://www.w3.org/2000/svg\">", width, height))
    table.insert(svg, "<g>")

    for _, transform in pairs(transforms) do
        table.insert(svg, string.format("<g transform=\"%s\">", transform))
        local background_paths = sprite.paths[1]
        local foreground_paths = sprite.paths[2]
        for _, path in pairs(background_paths) do
            create_path(svg, path, background_color)
        end
        for _, path in pairs(foreground_paths) do
            create_path(svg, path, foreground_color)
        end
        table.insert(svg, "</g>")
    end

    table.insert(svg, "</g>")
    table.insert(svg, "</svg>")
    local text = table.concat(svg,"")
    return text
end

local function write_file(filename, content)
    local file = io.open(filename, "w+")
    file:write(content)
    file:close();
end

local function inkscape_command(inkscape, filename)
    local cmd = string.format("%s --export-type=\"png\" \"%s\"", inkscape, filename)
    os.execute(cmd)
end
-------------------------------------------------------------------------------
local force_build = false
local inkscape = "E:\\Autre\\inkscape\\bin\\inkscape"
local info = debug.getinfo(1)
local current_file=string.gsub(info.source, "/", "\\")
current_file=string.gsub(current_file, "@", "")
local current_dir = string.gsub(current_file, "^(.+\\)[^\\]+$", "%1");
local colors = {
    black = {"#FFFFFF", "#000000"},
    white = {"#000000", "#FFFFFF"},
    red = {"#000000", "#FF0000"},
    blue = {"#000000", "#6CCEED"},
    yellow = {"#000000", "#FCDC3B"}
}
-------------------------------------------------------------------------------
--- Image builder
local total = 0
for index, sprite in pairs(sprites) do
    total = total + 1
end
for index, sprite in pairs(sprites) do
    if force_build or sprite.build then
        print(string.format("Process %s (%s/%s)", sprite.name, index, total))
        for color_name, is_valid in pairs(sprite.colors) do
            if is_valid then
                local color = colors[color_name]
                local content = create_svg(sprite, color[1], color[2])
                local path = string.format("%sicons\\%s_%s.svg", current_dir, sprite.name, color_name)
                write_file(path, content)
                inkscape_command(inkscape, path)
                os.remove(path)
            end
        end
    end
end

-------------------------------------------------------------------------------
--- Defines builder
--- Put this result in defines.lua file
print("===== defines.lua =====")
local defines_builded = {}
table.insert(defines_builded, "defines.sprites = {}")
for _, sprite in pairs(sprites) do
    local array = string.format("defines.sprites.%s = {}", sprite.name)
    table.insert(defines_builded, array)
    for color_name, is_valid in pairs(sprite.colors) do
        if is_valid then
            local value = string.format("defines.sprites.%s.%s = \"%s_%s\"", sprite.name, color_name, sprite.name, color_name)
            table.insert(defines_builded, value)
        end
    end
end
local path = string.format("%s..\\core\\defines_builded.lua", current_dir)
local defines_content = table.concat(defines_builded,"\n")
write_file(path, defines_content)
-------------------------------------------------------------------------------
--- Defines builder
--- Put this result in sprites.lua file
print("===== sprites.lua =====")
local sprites_builded = {}
table.insert(sprites_builded, "local mipmaps = {")
for _, sprite in pairs(sprites) do
    for color_name, is_valid in pairs(sprite.colors) do
        if is_valid then
            table.insert(sprites_builded, string.format("{name=\"%s_%s\", size=%s, count=%s},", sprite.name, color_name, sprite.size, sprite.count))
        end
    end
end
table.insert(sprites_builded, "}")
table.insert(sprites_builded, "return mipmaps")
local path = string.format("%s..\\prototypes\\sprites_builded.lua", current_dir)
local sprites_content = table.concat(sprites_builded,"\n")
write_file(path, sprites_content)
