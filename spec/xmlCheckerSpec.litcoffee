
## xmlChecker tests

Author: Jan Gottschick

To test the xmlChecker ...

Importing the Jasmine test framework addons to describe the specifications by
examples.

		require 'jasmine-matchers'
		require 'jasmine-given'

		xmlChecker = require '../lib/xmlCheckerModule'

		compile = (__done, __expr, __test, __debug = false) ->
			try
				__code = xmlChecker.parse(__expr)
			catch error
				console.log error.name + " at " + error.line + "," + error.column + ": " + error.message if __debug
				__test false, ''
				__done()
				return
			__test true, __code
			__done()

And the tests...

		describe 'The XML header', ->

			it 'should accept a minimal header', (done) ->
				compile done, '''
					<?xml
					  version="1.1" ?>
				''', (ok, result) ->
					expect(ok).toBe true

			it 'should accept a full xml header', (done) ->
				compile done, '''
					<?xml
					version="1.1"

					encoding="utf-8"         standalone="yes"
					?>
				''', (ok, result) ->
					expect(ok).toBe true

			it 'should reject a wrong version', (done) ->
				compile done, '''
					<?xml version="1.3" ?>
				''', (ok, result) ->
					expect(ok).toBe false

			it 'should reject a standalone value', (done) ->
				compile done, '''
					<?xml version="1.3" standalone="blabla" ?>
				''', (ok, result) ->
					expect(ok).toBe false

			it 'should accept processing instructions', (done) ->
				compile done, '''
					<?xml
					version="1.1"
					?>

					<?pi huhuhuhuh huhu

					?>
				''', (ok, result) ->
					expect(ok).toBe true

			it 'should reject processing instructions for xml', (done) ->
				compile done, '''
					<?xml
					version="1.1"
					?>

					<?xml huhuhuhuh huhu

					?>
				''', (ok, result) ->
					expect(ok).toBe false

			it 'should accept comments', (done) ->
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

		describe 'The XML element content', ->

			it 'should accept a single closed tag', (done) ->
				compile done, '''
					<?xml version="1.1" ?><tag/>
				''', (ok, result) ->
					expect(ok).toBe true

			it 'should accept a single empty tag', (done) ->
				compile done, '''
					<?xml version="1.1" ?><Tag>       </Tag   >
				''', (ok, result) ->
					expect(ok).toBe true

			it 'should reject a tag with non matching tag names', (done) ->
				compile done, '''
					<?xml version="1.1" ?><Tag>       </tag   >
				''', (ok, result) ->
					expect(ok).toBe false

			it 'should accept a single tag with content', (done) ->
				compile done, '''
					<?xml version="1.1" ?><Tag>     234  </Tag   >
				''', (ok, result) ->
					expect(ok).toBe true

			it 'should accept a single tag with cdata value', (done) ->
				compile done, '''
					<?xml version="1.1" ?><Tag>    <![CDATA[ dusfhufhu785475uirhruhf98usf hzuii <]]> </Tag   >
				''', (ok, result) ->
					expect(ok).toBe true

			it 'should accept a single tag with mixed value', (done) ->
				compile done, '''
					<?xml version="1.1" ?><Tag>   234 abc  <![CDATA[ dusfhufhu785475uirhruhf98usf hzuii <]]> </Tag   >
				''', (ok, result) ->
					expect(ok).toBe true

			it 'should accept a single tag with nested tags', (done) ->
				compile done, '''
					<?xml version="1.1" ?><Tag1>    <tag2> abc
					</tag2> </Tag1   >
				''', (ok, result) ->
					expect(ok).toBe true

			it 'should accept namespaces', (done) ->
				compile done, '''
					<?xml version="1.1" ?>
					<tag1 xmlns:ns1="huh">
						<ns1:tag2>
						</ns1:tag2>
					</tag1>
				''', (ok, result) ->
					expect(ok).toBe true
				,true

			it 'should accept nested namespaces', (done) ->
				compile done, '''
					<?xml version="1.1" ?>
					<tag1 xmlns:ns1="huh">
						<ns1:tag2 xmlns:ns2="buh">
							<ns2:tag3 />
						</ns1:tag2>
					</tag1>
				''', (ok, result) ->
					expect(ok).toBe true
				,true

			it 'should reject unknown namespaces', (done) ->
				compile done, '''
					<?xml version="1.1" ?>
					<tag1 xmlns:ns1="huh">
						<ns3:tag3></ns3:tag3 />
					</tag1>
				''', (ok, result) ->
					expect(ok).toBe false

			it 'should reject unknown namespaces in closed tags', (done) ->
				compile done, '''
					<?xml version="1.1" ?>
					<tag1 xmlns:ns1="huh">
						<ns2:tag2/>
					</tag1>
				''', (ok, result) ->
					expect(ok).toBe false

		describe 'The XML attribute', ->

			it 'should accept an attribute with empty content', (done) ->
				compile done, '''
					<?xml version="1.1" ?><Tag a/>
				''', (ok, result) ->
					expect(ok).toBe true

			it 'should accept an attribute with content', (done) ->
				compile done, '''
					<?xml version="1.1" ?><Tag a="2  d"/>
				''', (ok, result) ->
					expect(ok).toBe true

			it 'should accept multiple attributes', (done) ->
				compile done, '''
					<?xml version="1.1" ?><Tag a1="2"

					a2="  d"/>
				''', (ok, result) ->
					expect(ok).toBe true

		describe 'The XML comments', ->

			it 'should accept embedded comments', (done) ->
				compile done, '''
					<?xml version="1.1" ?><Tag><!-- I am
					an embedded
							comment --></Tag>
				''', (ok, result) ->
					expect(ok).toBe true
