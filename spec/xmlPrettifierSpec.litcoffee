
## xmlPrettifier tests

Author: Jan Gottschick

To test the xmlPrettifier ...

Importing the Jasmine test framework addons to describe the specifications by
examples.

		require 'jasmine-matchers'
		require 'jasmine-given'

		xmlPrettifier = require '../lib/xmlPrettifierModule'

		compile = (__done, __expr, __test, __debug = false) ->
			try
				__code = xmlPrettifier.parse(__expr)
			catch error
				console.log error.name + " at " + error.line + "," + error.column + ": " + error.message if __debug
				__test false, ''
				__done()
				return
			__test true, __code
			__done()

And the tests...

		describe 'A XML file', ->

			it 'should print a nice, minimal header in one line', (done) ->
				compile done, '''
					<?xml
					version="1.1"
					?>
				''', (ok, result) ->
					expect(ok).toBe true
					expect(result).toBe '<?XML version="1.1" ?>'
				, true
