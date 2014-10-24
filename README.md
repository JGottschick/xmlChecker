xmlChecker
==========

Validating the syntax of a xml text

*xmlChecker.js* is [_PEG.js_](http://pegjs.majda.cz/) grammar to validate a string against the XML syntax.
*xmlChecker.js* doesn't validate the string against a XSD schema.
*xmlChecker.js* can used to check a file on the fly, e.g. while editing the file in a web browser
at development time.

*xmlPrettify.js* converts a string in the XML format to a prettified version of the string in XML.

*xml2json.js* converts a string in the xml format to a json data structure using the same grammar
as the *xmlChecker.js* .

## Features

* check the basic syntax according to the specification at [_w3c_](http://www.w3.org/TR/xml
* check if start and end tag matches
* check if namespace prefixes are declared
* easy integrateable in JavaScript code on client (*xmlChecker.js* for web browser) and server side (*xmlCheckerModule.js* for *node.js*)
* easy extendable
* converting xml strings to JSON data structures

## JSON conventions for XML content

* each XML element is a dictionary entry containing an array with attributes, elements, text values and comments
* element names are directly taken over including the full namespace
* each XML attribute is a dictionary entry conating an array of values
* attribute names are prefixed using a "@" and includes the full nampespace
* namespaces are prefixing the name of an element or attribute and are URL-encoded enclosed by "__"
* the text value enries have the special name "#text"
* comment entries have the special name "#comment"

## Getting started

Just include the *xmlChecker.js* in your client code

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
