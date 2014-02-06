xmlChecker
==========

Validating the syntax of a xml text

xmlChecker.js is [_PEG.js_](http://pegjs.majda.cz/) grammar to validate a file against the xml syntax.
xmlChecker.js doesn't validate the file against a XSD schema. xmlChecker.js can used to check a file on the
fly, e.g. while editing the file in a web browser at development time.

## Features

* check the basic syntax according to the specification at [_w3c_](http://www.w3.org/TR/xml
* check if start and end tag matches
* check if namespace prefixes are declared
* easy integrateable in JavaScript code on client (web browser) and server side (node.js)
* easy extendable

## Getting started

Just include the xmlChecker.js in your client code

	<script src="/js/xmlChecker.js"/>

or import the module in node.js

	var xmlChecker;
	xmlChecker = require('../lib/xmlCheckerModule.js');

and use it

	try
		xmlChecker.parse(source)
	catch error
		alert("XML Parser: " + error.name + " at " + error.line + "," + error.column + ": " + error.message);

## Installation

Just to use the library copy the file _xmlChecker.js_ to your preferred location.

To modify the grammar you need to install _PEG.js_ by

	npm install pegjs

and compile it, e.g. using

	./pegjs.sh

