xml2json = require '../lib/xml2jsonModule'

parse = (code) ->
  result = ''
  try
    result = xml2json.parse(code)
  catch error
    console.log error.name + " at " + error.line + "," + error.column + ": " + error.message
  return result

console.log "example ->\n\n" + JSON.stringify(parse('''
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
'''))
