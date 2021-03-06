//
// xmlchecker.pegjs
//

//
// # XML Grammar
//
// This grammar for XML validates only the syntax of a single XML file. The
// grammar doesn't validate against a xsd schema. It can be used for online
// syntax checking, e.g. while editing a XML file.
//

/////////////////////////////////////////////////////
//
// ## This section defines the utilities functions
//

//
// utility function to check defined namespaces supporting a stack of defined nameespaces
//
{
	knownNamespaces = [];

	isKnownNamespace = function(ns) {
	  var x, _i, _len;
	  for (_i = 0, _len = knownNamespaces.length; _i < _len; _i++) {
	    x = knownNamespaces[_i];
	    if (x == ns) {
	      return true;
	    }
	  }
	  return false;
	};
}

////////////////////////////////////////////////////
//

Start
	= (Prolog ( _ Comment / _ PI )* ( _ Element )? )? ( _ Comment )* _

////////////////////////////////////////////////////
//
// ## This section defines white spaces
//

// The white spaces must be parsed explicite. The White spaces include
// the space and tab character as well as new line CR and LF characters.
// The white spaces mainly separate keywords, identifiers and numbers.
// The white spaces subsumes also new line character and followup empty
// lines.
//
WSEOL
	= WS
	/ EOL

WS
	= [\t\v\f \u00A0\uFEFF]
  / [\u0020\u00A0\u1680\u180E\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200A\u202F\u205F\u3000]

__ "white space character"
	= WSEOL+

_ "white space character"
	= WSEOL*

EOL
	= "\n"
  / "\r\n"
  / "\r"
  / "\u2028" // line separator
  / "\u2029" // paragraph separator

// A string must be pairwise surrounded by *"* or *'* characters. A string
// could contain any characters except the surrounding character. A string
// must be written within a line.
//
STRING "string"
	= '"' string:[^"\n\r]* '"' { return string.join(""); }
	/ "'" string:[^'\n\r]* "'" { return string.join(""); }

////////////////////////////////////////////////////
//
// ## This section defines the valid identifier names
//
NameStartChar
	= [A-Z] / "_" / [a-z] / [\u00C0-\u00D6] / [\u00D8-\u00F6]
	/ [\u00F8-\u02FF] / [\u0370-\u037D] / [\u037F-\u1FFF] / [\u200C-\u200D]
	/ [\u2070-\u218F] / [\u2C00-\u2FEF] / [\u3001-\uD7FF] / [\uF900-\uFDCF] / [\uFDF0-\uFFFD]

NameChar
	= NameStartChar / "-" / "." / [0-9] / [\u00B7] / [\u0300-\u036F] / [\u203F-\u2040]

Identifier
	= first:NameStartChar last:NameChar*
		{ return first + last.join(""); }

QualifiedIdentifier "qualified identifier"
	= prefix:Identifier ':' id:Identifier { return { full: prefix + ":" + id, prefix:prefix, id:id }; }
	/ id:Identifier { return { full:id, id:id }; }

////////////////////////////////////////////////////
//
// ## This section defines the valid tags
//
StartTag
	= '<' qid:QualifiedIdentifier namespaces:Attribute* _ '>'
		{ return { qid:qid, namespaces:namespaces }; }

EndTag
	= '</' qid:QualifiedIdentifier _ '>' { return qid; }

ClosedTag
	= '<' qid:QualifiedIdentifier namespaces:Attribute* _ '/>'
		{ return { qid:qid, namespaces:namespaces }; }

////////////////////////////////////////////////////
//
// ## This section defines an element
//

//
// - checks if the start and end tag have the same identifier
// - checks if the namespace prefixes are defined
//
Element
	= _ tagInfos:StartTag
		& {
			var prefix;
			knownNamespaces.push(tagInfos.namespaces);
			prefix = tagInfos.qid.prefix;
			if (prefix && !isKnownNamespace(prefix)) {
				error("unknown namespace prefix '" + prefix + "'")
			}
			return true
		}
		_ ( ElementContent _ )*
		& {
			knownNamespaces.pop();
			return true
		}
		_ qid:EndTag
		{
			return (tagInfos.qid.full !== qid.full ? expected("that start and end tag must be identical") : void 0);
		}
	/ _ tagInfos:ClosedTag
		{
			var prefix;
			knownNamespaces.push(tagInfos.namespaces);
			prefix = tagInfos.qid.prefix;
			if (prefix && !isKnownNamespace(prefix)) {
				knownNamespaces.pop();
				error("that all namespace prefixes are defined '" + prefix + "'");
			}
			knownNamespaces.pop();
			return void 0
		}

ElementContent
	= Cdata
	/ Comment
	/ Element
	/ ElementValue

ElementValue
	= [^<\n\r]+

////////////////////////////////////////////////////
//
// ## This section defines an attribute
//
Attribute
	= _ qid:QualifiedIdentifier ( _ '=' _ AttributeValue )?
		{
			if (qid.prefix === "xmlns") {
			  return qid.id;
			}
			return void 0;
		}

AttributeValue "attribute value"
	= STRING

////////////////////////////////////////////////////
//
// ## This section defines special tags
//

//
// Processing Instruction
//
PI
	= '<?' id:Identifier __ PIContent
		{
			return (
				id.toLowerCase() === 'xml' ? expected("that processing instruction should not 'xml'") : void 0
		);
		}

PIContent
	= '?>'
	/ . PIContent

//
// The prolog of the xml file
//
Prolog
	= '<?xml'i
		_ XmlVersion _
		( Encoding _ )?
		( Standalone _ )?
		'?>'

XmlVersion
	= 'version'i _ '=' _ version:STRING
		{
			if (version !== "1.0" && version !== "1.1") {
				expected("that version must be '1.0' or '1.1'");
			}
			return void 0
		}

Encoding
	= 'encoding'i _ '=' _ STRING

Standalone
	= 'standalone'i _ '=' _ value:STRING
	{
		var _ref;

		if ((_ref = value.toLowerCase()) !== "yes" && _ref !== "no") {
		  return expected("that encoding is 'yes' or 'no'");
		}
	}

//
// CDATA section
//
Cdata "CDATA"
	= '<![CDATA[' CdataContent

CdataContent
	= ']]>'
	/ . CdataContent

//
// XML comments
//
Comment "comment"
	= '<!--' CommentContent

CommentContent
	= '-->'
	/ . CommentContent
