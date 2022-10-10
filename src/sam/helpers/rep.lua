function scriptPath(...)
  local parent = debug.getinfo(2, 'S').source:sub(2):match('(.*/)')
  for i, arg in ipairs({...}) do
    parent = parent .. arg .. "/"
  end
  return parent:sub(1,-2)
end
local json  = require(scriptPath('json'))
--------------------------------------------------------------------------------

REP = {}

function REP.openNewTab()
  reaper.Main_OnCommand(40859, 0) -- open new tab
end

function REP.openProject(path)
  reaper.Main_openProject(path)
end

function REP.print(message,ret)
  message = message or ""
  ret     = ret or '\n'

  if type(message) == 'table' then
    reaper.ShowConsoleMsg(json.encode(message)..ret)
  else
    reaper.ShowConsoleMsg(message..ret)
  end
end

-- Used for creating even spacing between GUI elements
function REP.addTo(var, distance)
  local old = var
  var = var + distance
  return old, var
end

return REP
