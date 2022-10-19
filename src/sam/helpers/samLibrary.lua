--------------------------------------------------------------------------------
-- IMPORTS
--------------------------------------------------------------------------------
local libPath = reaper.GetExtState("SAM_V2", "libPath")
local json    = require('helpers.json')
local REP     = require('helpers.rep')
--------------------------------------------------------------------------------

-- Main SAM Class
SAM = {
  command = '".'..libPath..'console"',
  args    = {
    getSongs      = '-l',
    getSong       = '-s',
    newSong       = '-n',
    getDawHomeDir = '-w',
    call          = '-c'
  }
}

-- Get a list of all song names in the database
function SAM:GetSongs()
  -- local packet = self:_run(self.args.getSongs)
  local packet = self:_run(self.args.call, 'dbjson', 'get')
  if not packet.status then
    REP.print('Error: ', packet.error_message)
  end
  return packet
end

-- Get all data associated with a song name
function SAM:GetSong(name)
  return self:_run(self.args.getSong, name)
end

-- Create a new song
function SAM:NewSong(name)
  local packet = self:_run(self.args.newSong, name, 'reaper')

  if not packet.data.status then
    REP.print('Error: ', packet.data.errorMessage)
    return
  end

--  packet = self:GetDawHomeDir()
--  if not packet.data.status then
--    REP.print('Error: ', packet.data.errorMessage)
--    return
--  end
--
--  local workingDir = packet.data.result
--  local template   = workingDir..'template/template.RPP'
--  local projectDir = workingDir..name.."/"
--  local project    = projectDir..name..".RPP"
--
--  Files:Mkdir(projectDir)
--  Files:Copy(template, project)

  self:OpenSongByPath(packet.data.result)
--  -- Create new tab and open new song project
--  reaper.Main_OnCommand(40859, 0) -- open new tab
--  reaper.Main_openProject(project)
end

-- name: name of song with *.RPP at the end
-- path: optional, complete path to *.RPP file
function SAM:OpenSongByPath(path)
  -- local project = path or nil

--  if project == nil then
--    packet = self:GetDawHomeDir()
--    if not packet.data.status then
--      REP.print('Error: ', packet.data.errorMessage)
--      return
--    end
--
--    local workingDir = packet.data.result
--    local projectDir = workingDir..name.."/"
--    project          = projectDir..name..".RPP"
--  end

  -- Create new tab and open new song project
  REP.openNewTab()
  REP.openProject(path)
end

-- Create a copy of a song
function SAM:DuplicateSong(name, newName)
end

-- Remove song. If already in remotedb, archive song
function SAM:RemoveSong(name)
end

function SAM:GetDawHomeDir()
  return self:_run(self.args.getDawHomeDir, 'reaper')
end

function SAM:_argsJoin(...)
  local args = {self.command, ...}
  return table.concat(args, " ")
end

function SAM:_run(...)
  local command = self:_argsJoin(...)
  local result  = reaper.ExecProcess(command, 0):sub(3)
  -- REP.print(result) -- for debugging
  return json.decode(result)
end

-- Returns to allow us to import into another Lua script
return SAM
