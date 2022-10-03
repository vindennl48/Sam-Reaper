--------------------------------------------------------------------------------
-- IMPORTS
--------------------------------------------------------------------------------
-- Local imports --
function scriptPath()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end
local json = require(scriptPath()..'json')
local SAM  = require(scriptPath()..'samLibrary')

-- Scythe import --
local libPath = reaper.GetExtState("Scythe v3", "libPath")
if not libPath or libPath == "" then
  local m = ""
  m =    "Couldn't load the Scythe library. Please install 'Scythe library v3'"
  m = m.." from ReaPack, then run 'Script: Scythe_Set v3 library path.lua'"
  m = m.." in your Action List."

  reaper.MB(message)
  return
end
loadfile(libPath .. "scythe.lua")()
local GUI = require("gui.core")
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Windows && Layers
--------------------------------------------------------------------------------
local window_main = GUI.createWindow({
  name = "SAM V2",
  -- w = 640,
  -- h = 480,
  dock = 257,
})

local window_main_layers = table.pack( GUI.createLayers(
  { name = "main" }
  -- { name = "Layer2" },
  -- { name = "Layer3" },
  -- { name = "Layer4" }
))

window_main:addLayers(table.unpack(window_main_layers))
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Main Layer
--------------------------------------------------------------------------------
SAM.countY.pos = 0

window_main_layers[1]:addElements( GUI.createElements(
  {
    name    = 'title',
    type    = 'Label',
    caption = ':: SAM V2 ::',
    x       = 10,
    y       = SAM:CountY(40),
  },
  {
    name    = "btn_new",
    type    = "Button",
    caption = "New",
    x       = 10,
    y       = SAM:CountY(30),
    func    = function()
      -- local ret, retvals_csv = reaper.GetUserInputs( "New Song", 1,"New song name", "" )
      local ret, name = reaper.GetUserInputs( "New Song", 1,"New song name", "" )
      if not ret then return end

      -- Create the new song in the database
      SAM:NewSong(name)
    end
  },
  {
    name    = "btn_duplicate",
    type    = "Button",
    caption = "Duplicate",
    x       = 10,
    y       = SAM:CountY(30),
    func    = function()
    end
  },
  {
    name    = "btn_open",
    type    = "Button",
    caption = "Open",
    x       = 10,
    y       = SAM:CountY(40),
  },
  {
    name    = "btn_bounce",
    type    = "Button",
    caption = "Bounce",
    x       = 10,
    y       = SAM:CountY(30),
  },
  {
    name    = "btn_upload",
    type    = "Button",
    caption = "Upload",
    x       = 10,
    y       = SAM:CountY(30),
  },
  {
    name    = "btn_remove",
    type    = "Button",
    caption = "Remove",
    x       = 10,
    y       = SAM:CountY(40),
  }
))
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


window_main:open()
GUI.Main()
