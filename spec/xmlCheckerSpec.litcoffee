
## xmlChecker tests

Author: Jan Gottschick

To test the xmlChecker ...

Importing the Jasmine test framework addons to describe the specifications by
examples.

		require 'jasmine-matchers'
		require 'jasmine-given'

		require '../lib/xmlCheckerModule'

		compile = (__done, __expr, __test, __debug = false) ->
			console.log '===\n' + __expr.replace(/[\t]/g, "→ ").replace(/[\xA0]/g, "◻︎") + '\n===' if __debug
			try
				__code = parse(__expr)
			catch error
				console.log error.name + " at " + error.line + "," + error.column + ": " + error.message if __debug
				# console.trace()
				__test false, ''
				__done()
				return
			console.log '---\n' + __code.replace(/[\t]/g, "→ ") + '\n---' if __debug
			__test true, __code
			__done()

And the tests...

		describe 'P23R Selection @ connector for nested queries using chaining', ->

			it 'should return a range of values from a query', (done) ->
				compileQuery done, '''
				 
					result {
						[
							for x in P23R:range(1,3)
							return x
						]
					}
				''', (ok, result) ->
					expect(ok).toBe true
					expect(result).toContain '<result>1 2 3</result>'
				,'query'
