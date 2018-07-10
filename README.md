# lua-json-rpc v0.0.1

JSON events for long-lived connections.

```lua
local rpc = require('json-rpc')

-- Inject your JSON module
rpc.JSON = require('json')

-- Encode an event message
local msg = rpc.encode('event', {1, 2, 3})
print(msg) -- '14;event;[1,2,3];'

-- Create a message decoder
local decode = rpc.decoder(function(name, data)
  print(name) -- 'event'
  print(data) -- {1, 2, 3}
end)

-- Decode an event message
decode(msg)

-- Decode an event message across several chunks
local chunks = { msg:sub(1, #msg-4), msg:sub(#msg-3) }
for i, chunk in ipairs(chunks) do
  decode(chunk)
end

-- Decode multiple messages in one chunk
decode(msg .. rpc.encode('foo') .. rpc.encode('bar'))
```

- the event name cannot contain semi-colons or be empty
- the event data is optional

## Other Implementations
- [NodeJS](https://github.com/aleclarson/socket-events)
