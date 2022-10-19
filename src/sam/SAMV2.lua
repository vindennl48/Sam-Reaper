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
-- local SAM  = require("helpers.samLibrary")
--------------------------------------------------------------------------------

local sgui = SGUI.new('SAM', true)

sgui:addButtonMenu(
  'main_menu',
  '::SAM V2::',
  { type = 'label', name = 'Song' },
  {
    name = 'Open',
    func = function()
      local packet = REP.callApi('dbjson', 'get', {type = "songs"})

      if not packet.status then
        REP.print('Error getting songs.. Error: ', packet.errorMessage)
        return;
      end

      sgui:showLayer('open_song', { listbox = packet.result })
    end
  },
  {
    name = 'New',
    func = function()
      local name = sgui:getUserInput('New Song Name', 'New Name: ')
      if not name then return end

      name = name:gsub("[ -]", "_")
      name = name:gsub("[^a-zA-Z_]", "")

      local packet = REP.callApi('dbjson', 'new', {type = "song", name = name})

      if not packet.status then
        REP.print('Error adding song to database.. Error: ', packet.errorMessage)
        return;
      end

      packet = REP.callApi('files', 'new', {type = "song", name = name, daw  = 'reaper'})

      if not packet.status then
        REP.print('Error creating files for new song.. Error: ', packet.errorMessage)
        -- need to do some cleanup
        REP.callApi('dbjson', 'remove', {type = "song", name = name})
        return;
      end

      REP.openNewTab()
      REP.openProject(packet.result)
    end
  },
  {
    name = 'Duplicate',
    func = function()
      local packet = REP.callApi('dbjson', 'get', {type = "songs"})

      if not packet.status then
        REP.print('Error getting songs.. Error: ', packet.errorMessage)
        return;
      end

      sgui:showLayer('duplicate_song', { listbox = packet.result })
    end
  },
  { name = 'Bounce' },
  {
    name = 'Remove',
    func = function()
      local packet = REP.callApi('dbjson', 'get', {type = "songs"})

      if not packet.status then
        REP.print('Error getting songs.. Error: ', packet.errorMessage)
        return;
      end

      sgui:showLayer('remove_song', { listbox = packet.result })
    end
  },
  { type = 'spacer' },
  { type = 'label', name = 'Console' },
  { name = 'Open' },
  { name = 'New' },
  { name = 'Duplicate' },
  { name = 'Remove' },
  { type = 'spacer' },
  { type = 'label', name = 'General' },
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

sgui:addChooseMenu(
  'remove_song',
  '::Remove Song::',

  -- okFunc
  function()
    local name = sgui:getCurrentLayer():val()
    local packet = REP.callApi('dbjson', 'remove', {type = "song", name = name})

    if not packet.status then
      REP.print('Error removing song from database.. Error: ', packet.errorMessage)
      sgui:showPreviousLayer()
      return
    end

    packet = REP.callApi('files', 'remove', {type = "song", name = name, daw = 'reaper'})

    if not packet.status then
      REP.print('Error removing song files but was removed from database.. Error: ', packet.errorMessage)
    end

    sgui:showPreviousLayer()
  end,

  -- cancelFunc
  function()
    sgui:showPreviousLayer()
  end
)


sgui:run('main_menu')
