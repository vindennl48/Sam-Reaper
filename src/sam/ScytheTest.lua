function scriptPath(...)
  local parent = debug.getinfo(2, 'S').source:sub(2):match('(.*/)')
  for i, arg in ipairs({...}) do
    parent = parent .. arg .. "/"
  end
  return parent:sub(1,-2)
end

local json = require(scriptPath('helpers', 'json'))

-- ::Working code to get json from console::
local command = "\"." .. scriptPath() .. "console\" -l"
--   -- reaper.ShowConsoleMsg(command)
local result = reaper.ExecProcess(command, 0):sub(3)
--   -- reaper.ShowConsoleMsg(result)
local json_result = json.decode(result)
local options = {}

for i, song in ipairs(json_result["data"]) do
  table.insert(options, song)
end


local libPath = reaper.GetExtState("Scythe v3", "libPath")
if not libPath or libPath == "" then
    reaper.MB("Couldn't load the Scythe library. Please install 'Scythe library v3' from ReaPack, then run 'Script: Scythe_Set v3 library path.lua' in your Action List.", "Whoops!", 0)
    return
end

loadfile(libPath .. "scythe.lua")()

local GUI = require("gui.core")

local window = GUI.createWindow({
  name = "SAM V2",
  w = 250,
  h = 250,
})

local layer = GUI.createLayer({
  name = "My Layer"
})

local button = GUI.createElement({
  name = "My Button",
  type = "Button",
  x = 32,
  y = 150,
  caption = "Download"
})

local checklist = GUI.createElement({
  name = "My Checklist",
  type = "Checklist",
  x = 16,
  y = 16,
  caption = "Song Select",
  options = options
})

button.func = function() reaper.ShowMessageBox("Downloading songs..", "SAM", 0) end

layer:addElements(button)
layer:addElements(checklist)
window:addLayers(layer)

window:open()
GUI.Main()
