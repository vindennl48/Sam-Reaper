--------------------------------------------------------------------------------
-- IMPORTS
--------------------------------------------------------------------------------
-- Scythe import script --
loadfile(reaper.GetExtState("Scythe v3", "libPath") .. "scythe.lua")()

-- Setting up the Reaper imports path so we can call our helper
-- files as if they are modules
local libPath = reaper.GetExtState("SAM_V2", "libPath")
if not libPath or libPath == "" then
  libPath = debug.getinfo(1, 'S').source:sub(2):match('(.*/)')
  reaper.SetExtState("SAM_V2", "libPath", libPath, true)
end
package.path = package.path..";"..libPath.."?.lua"
--------------------------------------------------------------------------------
local REP  = require("helpers.rep")
local SGUI = require("helpers.sgui")
local SAM  = require("helpers.samLibrary")
--------------------------------------------------------------------------------

local sgui = SGUI.new('SAM', true)

sgui:addButtonMenu(
  'main_menu',
  '::SAM V2::',
  {
    name = 'Song Open',
    func = function()
      local packet = SAM:GetSongs()

      if not packet.data.status then
        REP.print('Error getting songs.. Error: ', packet.data.errorMessage)
        return;
      end

      sgui:showLayer('open_song', { listbox = packet.data.result })
    end
  },
  {
    name = 'Song New',
    func = function()
      local name = sgui:getUserInput('New Song Name', 'New Name: ')
      if not name then return end

      name = name:gsub("[ -]", "_")
      name = name:gsub("[^a-zA-Z_]", "")

      SAM:NewSong(name)
    end
  },
  {
    name = 'Song Duplicate',
    func = function()
      local packet = SAM:GetSongs()

      if not packet.data.status then
        REP.print('Error getting songs.. Error: ', packet.data.errorMessage)
        return;
      end

      sgui:showLayer('duplicate_song', { listbox = packet.data.result })
    end
  },
  { name = 'Song Bounce' },
  { name = 'Song Remove' },
  { name = 'Console Open' },
  { name = 'Console New' },
  { name = 'Console Duplicate' },
  { name = 'Console Remove' },
  { name = 'Upload All' }
)

sgui:addChooseMenu(
  'open_song',
  '::Open Song::',

  -- okFunc
  function()
    local name = sgui:getCurrentLayer():val()
    REP.print(name)
    sgui:showPreviousLayer()
  end,

  -- cancelFunc
  function()
    sgui:showPreviousLayer()
  end
)

sgui:addChooseMenu(
  'duplicate_song',
  '::Duplicate Song::',

  -- okFunc
  function()
    local dupName = sgui:getCurrentLayer():val()
    if dupName then
      local newName = sgui:getUserInput('Duplicating '..dupName, 'New Name:')
      if newName then
        newName = newName:gsub(" ", "_")
        REP.print(newName)
      end
    end
    sgui:showPreviousLayer()
  end,

  -- cancelFunc
  function()
    sgui:showPreviousLayer()
  end
)

sgui:run('main_menu')
