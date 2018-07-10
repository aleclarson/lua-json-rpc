local rpc = {}

rpc.encode = function(name, data)
  local json = data and rpc.JSON.encode(data)
  local length = 1 + #name + (json and 1 + #json or 0)
  return length ..';'.. name ..';'.. (json and json ..';' or '')
end

rpc.decoder = function(handler)
  local buf, len, name = '', 0, ''
  return function(chunk)
    local i, size = 1, #chunk

    ::parse::
    while i <= size do

      -- Parse the event length.
      if len == 0 then
        local sep = chunk:sub(i):find(';')
        if sep == nil then
          buf = buf .. chunk:sub(i)
          return
        end

        -- The length is known.
        len = tonumber(buf .. chunk:sub(i, i + sep - 2))
        buf = ''

        -- Continue past the length.
        i = i + sep
      end

      -- Parse the event name.
      if name == '' then
        local sep = chunk:sub(i):find(';')
        if sep == nil then
          buf = buf .. chunk:sub(i)
          return
        end

        -- The event name is known.
        name = buf .. chunk:sub(i, i + sep - 2)
        buf = ''

        -- Continue past the event name.
        i = i + sep
        len = len - #name - 1

        -- There may be no event data.
        if len == 0 then
          handler(name)
          name = ''
          goto parse
        end
      end

      -- The chunk may not have all the data.
      local left = 1 + (size - i)
      if len > left then
        buf = buf .. chunk:sub(i)
        len = len - left
        return
      end

      handler(name, rpc.JSON.decode(buf .. chunk:sub(i, i + len - 2)))
      i = i + len

      -- Reset the state.
      buf = ''
      len = 0
      name = ''
    end
  end
end

return rpc
