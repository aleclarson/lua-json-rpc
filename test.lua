tap = require('tap')
test = tap.test()

test:plan(4)

rpc = require('json-rpc')
rpc.JSON = require('json')

-- Test event encoding
messages = {
  rpc.encode('foo'),
  rpc.encode('bar', {1,2,3}),
}
test:ok(messages[1] == '4;foo;', 'encode works without data')
test:ok(messages[2] == '12;bar;[1,2,3];', 'encode works with data')

events = {}
decode = rpc.decoder(function(name, data)
  table.insert(events, {name, data})
end)

-- Test event split into multiple chunks
chunks = {'4', ';fo', 'o;1', '2;bar;[', '1,2,3', '];'}
assert(table.concat(messages, '') == table.concat(chunks, ''))

for i, chunk in ipairs(chunks) do
  decode(chunk)
end
test:is_deeply(events, {
  {'foo', nil},
  {'bar', {1,2,3}},
}, 'decode multiple chunks as one event')

-- Test multiple events in one chunk
events = {}
decode(rpc.encode('a', 'test') .. rpc.encode('b', {hello='world'}))

test:is_deeply(events, {
  {'a', 'test'},
  {'b', {hello='world'}},
}, 'decode one chunk as multiple events')
