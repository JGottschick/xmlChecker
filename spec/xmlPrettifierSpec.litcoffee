
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
			console.log __code.replace(/\t/g, '↦') if __debug
			__test true, __code
			__done()

And the tests...

		describe 'The XML header', ->

			it 'should print a minimal xml header in one line', (done) ->
				compile done, '''
					<?xml
					version="1.1"
					?>
				''', (ok, result) ->
					expect(ok).toBe true
					expect(result).toBe '<?xml version="1.1" ?>\n'

			it 'should print a full xml header in one line', (done) ->
				compile done, '''
					<?xml
					version="1.1"

					encoding="utf-8"         standalone="yes"
					?>
				''', (ok, result) ->
					expect(ok).toBe true
					expect(result).toBe '<?xml version="1.1" encoding="utf-8" standalone="yes" ?>\n'

			it 'should print processing instructions', (done) ->
				compile done, '''
					<?xml
					version="1.1"
					?>

					<?pi huhuhuhuh huhu

					?>
				''', (ok, result) ->
					expect(ok).toBe true
					expect(result).toBe '<?xml version="1.1" ?>\n<?pi huhuhuhuh huhu ?>\n'

			it 'should print comments', (done) ->
				compile done, '''
					<?xml
					version="1.1"
					?>
					<!--
						line 1
						line 2
					-->
					<?pi huhuhuhuh huhu

					?>
				''', (ok, result) ->
					expect(ok).toBe true
					expect(result).toBe '<?xml version="1.1" ?>\n<!--\n\tline 1\n\tline 2\n-->\n<?pi huhuhuhuh huhu ?>\n'

		describe 'The XML content', ->

			it 'should print a single closed tag', (done) ->
				compile done, '''
					<?xml version="1.1" ?><tag/>
				''', (ok, result) ->
					expect(ok).toBe true
					expect(result).toBe '<?xml version="1.1" ?>\n<tag />\n'

			it 'should print a single empty tag', (done) ->
				compile done, '''
					<?xml version="1.1" ?><Tag>       </Tag   >
				''', (ok, result) ->
					expect(ok).toBe true
					expect(result).toBe '<?xml version="1.1" ?>\n<Tag >\n</Tag >\n'
