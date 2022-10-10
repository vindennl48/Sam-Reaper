--------------------------------------------------------------------------------
-- IMPORTS
--------------------------------------------------------------------------------
-- Local imports --
function scriptPath(...)
  local parent = debug.getinfo(2, 'S').source:sub(2):match('(.*/)')
  for i, arg in ipairs({...}) do
    parent = parent .. arg .. "/"
  end
  return parent:sub(1,-2)
end
local COUNT = require(scriptPath('helpers', 'counter'))
local SAM   = require(scriptPath('helpers', 'samLibrary'))
local REP   = require(scriptPath('helpers', 'rep'))

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
local GUI  = require("gui.core")
local Font = require('public.font')
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Main Window
--------------------------------------------------------------------------------
local window = GUI.createWindow({
  name = "SAM V2",
  -- w = 640,
  -- h = 480,
  dock = 257,
})

-- window layer numbers
local wln = {
  body_main           = 1,
  body_duplicate_song = 2,
  header_notify       = 3,
}

local window_layers = table.pack( GUI.createLayers(
  { name = "body_main" },
  { name = "body_duplicate_song" },
  { name = "header_notify" }
))

window:addLayers(table.unpack(window_layers))

local lastLayer = 'body_main'

local X = COUNT:New()
local Y = COUNT:New()
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Helper Functions
--------------------------------------------------------------------------------
function showLayer(layerName)
  for i, layer in ipairs(window_layers) do
    if not layer.hidden then
      lastLayer = layer.name
    end
    layer:hide()
  end

  window_layers[wln[layerName]]:show()
end
showLayer('body_main')
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- header_notify
--------------------------------------------------------------------------------
X:Set(10)
Y:Set(10)

window_layers[wln.header_notify]:addElements( GUI.createElements(
  {
    name    = 'title',
    type    = 'Label',
    caption = 'Error Window',
    x       = X:Add(100),
    y       = Y:Get(),
  },
  {
    name    = "btn_close",
    type    = "Button",
    caption = "X",
    x       = X:Get(),
    y       = Y:Get(),
    w       = 20,
    h       = 20,
    func    = function()
      showLayer(lastLayer)
    end
  }
))
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- body_main
--------------------------------------------------------------------------------
X:Set(10)
Y:Set(60)

window_layers[wln.body_main]:addElements( GUI.createElements(
  {
    name    = 'title',
    type    = 'Label',
    caption = ':: SAM V2 ::',
    x       = X:Get(),
    y       = Y:Add(30),
  },
  {
    name    = "btn_new",
    type    = "Button",
    caption = "New",
    x       = X:Get(),
    y       = Y:Add(30),
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
    x       = X:Get(),
    y       = Y:Add(30),
    func    = function()
      showLayer('body_duplicate_song')
      -- Hide main screen and show song select screen
      -- Once a song is selected:
      --   - If the song is downloaded, copy the files
      --   - If the song is not downloaded, download the song and extract into new
      --     name
      -- Switch to song details screen
    end
  },
  {
    name    = "btn_open",
    type    = "Button",
    caption = "Open",
    x       = X:Get(),
    y       = Y:Add(30),
    func    = function()
      -- Hide main screen and show song select screen
      -- Once song selected:
      --   - If song is already downloaded, check if upts up-to-date
      --     - if it is, open the song
      --     - if it isnt, download update and then open
      --   - If song is not downloaded, download and then open
      -- Switch to song details screen
    end
  },
  {
    name    = "btn_bounce",
    type    = "Button",
    caption = "Bounce",
    x       = X:Get(),
    y       = Y:Add(30),
  },
  {
    name    = "btn_upload",
    type    = "Button",
    caption = "Upload",
    x       = X:Get(),
    y       = Y:Add(30),
  },
  {
    name    = "btn_remove",
    type    = "Button",
    caption = "Remove",
    x       = X:Get(),
    y       = Y:Add(30),
  }
))
--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
-- body_main
--------------------------------------------------------------------------------
X:Set(10)
Y:Set(10)

Font:addFonts({ LB = { 'monospace', 20, '' } })

window_layers[wln.body_duplicate_song]:addElements( GUI.createElements(
  {
    name    = 'title',
    type    = 'Label',
    caption = '::Duplicate Song::',
    x       = X:Get(),
    y       = Y:Add(30),
  },
  {
    name     = 'lb_duplicate_song',
    type     = 'Listbox',
    textFont = 1,
    list     = 'Petrichor,Sono,Chrono,Hammer,Petrichor,Sono,Chrono,Hammer,Petrichor,Sono,Chrono,Hammer,Petrichor,Sono,Chrono,Hammer,',
    pad      = 10,
    x        = X:Get(),
    y        = Y:Add(310),
    w        = 300,
    h        = 300,
  },
  {
    name    = 'btn_ok',
    type    = 'Button',
    caption = 'OK',
    x       = X:Add(225),
    y       = Y:Get(),
    w       = 75,
    func    = function()
      local lb = window_layers[wln.body_duplicate_song]:findElementByName('lb_duplicate_song')
      REP:Print(lb:val())
    end
  },
  {
    name    = 'btn_cancel',
    type    = 'Button',
    caption = 'Cancel',
    x       = X:Get(),
    y       = Y:Get(),
    w       = 75,
    func    = function()
      showLayer(lastLayer)
    end
  }
))
--------------------------------------------------------------------------------

window:open()
GUI.Main()
