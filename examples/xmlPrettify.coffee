xmlPrettifier = require '../lib/xmlPrettifierModule'

parse = (code) ->
  result = ''
  try
    result = xmlPrettifier.parse(code)
  catch error
    console.log error.name + " at " + error.line + "," + error.column + ": " + error.message
  return result

console.log "example 1 ->\n\n" + parse('''<?xml version="1.1" ?><Tag>234</Tag>''')

console.log "example 2 ->\n\n" + parse('''
<?xml version="1.1" ?><Tag1 a1="abc"
a2="def">
<!--
  I am
  an embedded
  comment
--><tag2>t1
    t2
    t3
    </tag2></Tag1>
''')
