function scriptPath()
  local str = debug.getinfo(2, 'S').source:sub(2)
  return str:match('(.*/)')
end
local json  = require(scriptPath() .. 'json')
local Files = require(scriptPath() .. 'Files')
--------------------------------------------------------------------------------

-- Main SAM Class
SAM = {
  command = '".'..scriptPath()..'console"',
  args    = {
    getSongs      = '-l',
    getSong       = '-s',
    newSong       = '-n',
    getDawHomeDir = '-w'
  },
  countY = {
    count = 0,
    pos   = 0
  }
}

-- Get a list of all song names in the database
function SAM:GetSongs()
  return self:_run(self.args.getSongs)
end

-- Get all data associated with a song name
function SAM:GetSong(name)
  return self:_run(self.args.getSong, name)
end

-- Create a new song
function SAM:NewSong(name)
  local packet = self:_run(self.args.newSong, name)

  if not packet.data.status then
    self:Print('Error: ', packet.data.errorMessage)
    return
  end

  packet = self:GetDawHomeDir()
  if not packet.data.status then
    self:Print('Error: ', packet.data.errorMessage)
    return
  end

  local workingDir = packet.data.result
  local template   = workingDir..'template/template.RPP'
  local projectDir = workingDir..name.."/"
  local project    = projectDir..name..".RPP"

  Files:Mkdir(projectDir)
  Files:Copy(template, project)

  -- Create new tab and open new song project
  reaper.Main_OnCommand(40859, 0) -- open new tab
  reaper.Main_openProject(project)
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

function SAM:CountY(count)
  count             = count or self.countY.count
  self.countY.count = count
  self.countY.pos   = self.countY.count + self.countY.pos
  return self.countY.pos
end

-- Mainly used for debugging.  Will show a popup with the requested message
function SAM:Print(message,ret)
  message = message or ""
  ret     = ret or '\n'

  if type(message) == 'table' then
    reaper.ShowConsoleMsg(json.encode(message)..ret)
  else
    reaper.ShowConsoleMsg(message..ret)
  end
end

function SAM:_argsJoin(...)
  local args = {self.command, ...}
  return table.concat(args, " ")
end

function SAM:_run(...)
  local command = self:_argsJoin(...)
  local result  = reaper.ExecProcess(command, 0):sub(3)
  -- self:Print(result) -- for debugging
  return json.decode(result)
end

-- Returns to allow us to import into another Lua script
return SAM
