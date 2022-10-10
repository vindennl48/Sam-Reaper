-- function scriptPath()
--   local str = debug.getinfo(2, 'S').source:sub(2)
--   return str:match('(.*/)')
-- end

function q(text)
  return "\'"..text.."\'"
end

function r(text, ...)
  local args = {...}

  for i, value in ipairs(args) do
    text = text:gsub(i..'#', value)
  end

  return text
end

Files = {
  bash = '/bin/bash -c '
}

function Files._argsJoin(...)
  local args = {self.bash, '"', ..., '"'}
  return table.concat(args, " ")
end

function Files._run(...)
  local command = self._argsJoin(...)
  return reaper.ExecProcess(command, 0):sub(3)
end

function Files.mkdir(path)
  self._run(
    r('[ -d 1# ] || mkdir -p 1#', q(path))
  )
end

function Files.copy(source, destination)
  self._run(
    r('cp 1# 2#', q(source), q(destination))
  )
end

return Files
