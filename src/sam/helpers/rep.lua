local libPath = reaper.GetExtState("SAM_V2", "libPath")
local json    = require('helpers.json')
--------------------------------------------------------------------------------

function q(text)
  return "\'"..text.."\'"
end

function r(text, ...)
  local args = {...}

  for i, value in ipairs(args) do
    text = text:gsub('#'..i, value)
  end

  return text
end

REP = {}
REP.q = q
REP.r = r

function REP.run(...)
  local command = table.concat({r('".#1console"', libPath), ...}, " ")
  local result  = reaper.ExecProcess(command, 0):sub(3)
  -- REP.print(result) -- for debugging
  return json.decode(result)
end

function REP.callApi(node, apiCall, args)
  args = args or nil
  if args then
    return REP.run("-c", node, apiCall, q(json.encode(args)))
  end
  return REP.run("-c", node, apiCall)
end

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

-- -- Used for creating even spacing between GUI elements
-- function REP.addTo(var, distance)
--   local old = var
--   var = var + distance
--   return old, var
-- end

return REP
