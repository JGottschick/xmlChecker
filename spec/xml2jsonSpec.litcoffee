
## xml2json tests

Author: Jan Gottschick

To test the xml2json ...

Importing the Jasmine test framework addons to describe the specifications by
examples.

    require 'jasmine-matchers'
    require 'jasmine-given'

    xml2json = require '../lib/xml2jsonModule'

    compile = (__done, __expr, __test, __debug = false) ->
      try
        __code = xml2json.parse(__expr)
      catch error
        console.log error.name + " at " + error.line + "," + error.column + ": " + error.message if __debug
        __test false, ''
        __done()
        return
      __test true, __code
      __done()

And the tests...

    describe 'The XML elements', ->

      it 'should code a closed tag', (done) ->
        compile done, '''
          <?xml version="1.1" ?><tag/>
        ''', (ok, result) ->
          expect(ok).toBe true
          expect(JSON.stringify(result)).toBe JSON.stringify([{tag:[]}])

      it 'should code an empty tag', (done) ->
        compile done, '''
          <?xml version="1.1" ?><tag></tag>
        ''', (ok, result) ->
          expect(ok).toBe true
          expect(JSON.stringify(result)).toBe JSON.stringify([{tag:[]}])

      it 'should code embedded tags', (done) ->
        compile done, '''
          <?xml version="1.1" ?><tag><tag1/><tag2/></tag>
        ''', (ok, result) ->
          expect(ok).toBe true
          expect(JSON.stringify(result)).toBe JSON.stringify([{tag:[{tag1:[]},{tag2:[]}]}])

      it 'should code tag values', (done) ->
        compile done, '''
          <?xml version="1.1" ?><tag>123
          456</tag>
        ''', (ok, result) ->
          expect(ok).toBe true
          expect(JSON.stringify(result)).toBe JSON.stringify([{tag:[{'#text':'123'},{'#text':'456'}]}])

    describe 'The XML attributes', ->

      it 'should code an single attribute', (done) ->
        compile done, '''
          <?xml version="1.1" ?><tag a="1"></tag>
        ''', (ok, result) ->
          expect(ok).toBe true
          expect(JSON.stringify(result)).toBe JSON.stringify([{tag:[{'@a':"1"}]}])

      it 'should code an empty attribute', (done) ->
        compile done, '''
          <?xml version="1.1" ?><tag a></tag>
        ''', (ok, result) ->
          expect(ok).toBe true
          expect(JSON.stringify(result)).toBe JSON.stringify([{tag:[{'@a':null}]}])

      it 'should code multiple attributes', (done) ->
        compile done, '''
          <?xml version="1.1" ?><tag a1="1" a2="2"></tag>
        ''', (ok, result) ->
          expect(ok).toBe true
          expect(JSON.stringify(result)).toBe JSON.stringify([{tag:[{'@a1':"1"},{'@a2':"2"}]}])

    describe 'The XML namespaces', ->

      it 'should be define a namespace', (done) ->
        compile done, '''
          <?xml version="1.1" ?><tag a="1" xmlns:url="http://www.domain.de"></tag>
        ''', (ok, result) ->
          expect(ok).toBe true
          expect(JSON.stringify(result)).toBe JSON.stringify([{tag:[{'@a':"1"},{"@__xmlns__url":"http://www.domain.de"}]}])

      it 'should be used in a namespace of a tag', (done) ->
        compile done, '''
          <?xml version="1.1" ?><tag a="1" xmlns:url="http://www.domain.de"><url:tag/></tag>
        ''', (ok, result) ->
          expect(ok).toBe true
          expect(JSON.stringify(result)).toBe JSON.stringify([{tag:[{'@a':"1"},{"@__xmlns__url":"http://www.domain.de"},{"__http%3A%2F%2Fwww.domain.de__tag":[]}]}])

      it 'should be used in a namespace of an attribute', (done) ->
        compile done, '''
          <?xml version="1.1" ?><tag a="1" xmlns:url="http://www.domain.de"><tag1 url:a1/></tag>
        ''', (ok, result) ->
          expect(ok).toBe true
          expect(JSON.stringify(result)).toBe JSON.stringify([{tag:[{'@a':"1"},{"@__xmlns__url":"http://www.domain.de"},{"tag1":[{"@__http%3A%2F%2Fwww.domain.de__a1":null}]}]}])

    describe 'The XML comments', ->

      it 'should comment the header', (done) ->
        compile done, '''
          <?xml version="1.1" ?><!-- my comment --><tag/>
        ''', (ok, result) ->
          expect(ok).toBe true
          expect(JSON.stringify(result)).toBe JSON.stringify([{"#comment":" my comment "},{tag:[]}])

      it 'should comment tags', (done) ->
        compile done, '''
          <?xml version="1.1" ?><tag><!-- my comment --></tag>
        ''', (ok, result) ->
          expect(ok).toBe true
          expect(JSON.stringify(result)).toBe JSON.stringify([{tag:[{"#comment":" my comment "}]}])
