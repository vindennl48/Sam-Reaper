COUNT = {}

function COUNT.new(startVar)
  startVar = startVar or 0
  result = {
    n = startVar
  }

  function result:add(var)
    local old = self.n
    self.n = self.n + var
    return old
  end

  function result:sub(var)
    local old = self.n
    self.n = self.n - var
    return old
  end

  function result:set(var)
    self.n = var
    return self.n
  end

  function result:get()
    return self.n
  end

  return result
end


return COUNT
