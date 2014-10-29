xmlChecker = require '../lib/xmlCheckerModule'

parse = (code) ->
  try
    xmlChecker.parse(code)
  catch error
    return error.name + " at " + error.line + "," + error.column + ": " + error.message
  return ''

result1 = parse('''<?xml version="1.1" ?><Tag>234</Tag>''')
if result1.length == 0
  console.log "first example is fine"
else
  console.log "first example has an error -> " + result1

result2 = parse('''<?xml version="1.1" ?><Tag>234</tag>''')
if result2.length == 0
  console.log "second example is fine"
else
  console.log "second example has an error -> " + result2
