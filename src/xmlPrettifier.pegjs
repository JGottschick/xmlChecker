//
// xmlPrettifier.pegjs
//

//
// # XML Prettifier
//
// This grammar for XML validates the syntax of a single XML file and
// prints the XML file in a pretty format.
//

/////////////////////////////////////////////////////
//
// ## This section defines the utilities functions
//

//
// utility function to check defined namespaces supporting a stack of defined namespaces
//
{
	var indention = 0;

	indentInc = function() {
		indention += 1
	}

	indentDec = function() {
		indention -= 1
	}

	indent = function() {
	  var _i, _results;
	  _results = [];
	  for (x = _i = 1; _i <= indention; x = ++_i) {
	    _results.push("  ");
	  }
	  return _results.join('');
	};
}

////////////////////////////////////////////////////
//

Start
	= content:(prolog:Prolog pi:( _ c:Comment { return c } / _ pi:PI { return pi } )* e:( _ e:Element { return e } )? { return (prolog ? prolog : '') + (pi && pi.length > 0 ? '\n' + pi.join('\n') : '') + (e ? '\n' + e : '') })? comments:( _ c:Comment  { return c })* _
		{
			return (content ? content + '\n' : '') + (comments && comments.length > 0 ? '\n' + comments.join('\n') : '');
		}

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

// A string must be pairwise surrounded by quote characters. A string
// could contain any characters except the surrounding character. A string
// must be written within a line.
//
STRING "string"
	= '"' string:[^"\n\r]* '"' { return string.join(""); }
	/ "'" string:[^'\n\r]* "'" { return string.join(""); }

QUOTEDSTRING "string"
	= '"' string:[^"\n\r]* '"' { return '"' + string.join("") + '"'; }
	/ "'" string:[^'\n\r]* "'" { return "'" + string.join("") + "'"; }

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
		{ return first + last.join("") }

QualifiedIdentifier "qualified identifier"
	= prefix:Identifier ':' id:Identifier { return prefix + ":" + id }
	/ id:Identifier { return id }

////////////////////////////////////////////////////
//
// ## This section defines the valid tags
//
StartTag
	= '<' qid:QualifiedIdentifier attributes:Attribute* _ '>'
		{
			return '<' + qid + (attributes && attributes.length > 0 ? ' ' + attributes.join(' ') : '') + ' >'
		}

EndTag
	= '</' qid:QualifiedIdentifier _ '>'
		{
			return '</' + qid + ' >'
		}

ClosedTag
	= '<' qid:QualifiedIdentifier attributes:Attribute* _ '/>'
		{
			return '<' + qid + (attributes && attributes.length > 0 ? ' ' + attributes.join(' ') : '') + ' />'
		}

////////////////////////////////////////////////////
//
// ## This section defines an element
//
Element
	= _ startTag:StartTag
		& {
			indentInc();
			return true
		}
		_ contents:( content:ElementContent _ { return content })*
		& {
			indentDec();
			return true
		}
		_ endTag:EndTag
		{
			return indent() + startTag + '\n' + (contents && contents.length > 0 ? contents.join('\n') + '\n' : '') + indent() + endTag
		}
	/ _ tag:ClosedTag
		{
			return indent() + tag
		}

ElementContent
	= Cdata
	/ Comment
	/ Element
	/ ElementValue

ElementValue
	= chars:([^<\n\r]+) { return indent() + chars.join('').trim() }

////////////////////////////////////////////////////
//
// ## This section defines an attribute
//
Attribute
	= _ qid:QualifiedIdentifier value:( _ '=' _ value:AttributeValue { return value } )?
		{
			return qid + (value ? '=' + value : '')
		}

AttributeValue "attribute value"
	= QUOTEDSTRING

////////////////////////////////////////////////////
//
// ## This section defines special tags
//

//
// Processing Instruction
//
PI
	= '<?' id:Identifier __ content:PIContent
		{
			return '<?' + id + ' ' + content
		}

PIContent
	= '?>'
	/ __ tail:PIContent { return ' ' + tail }
	/ head:. tail:PIContent { return head + tail }

//
// The prolog of the xml file
//
Prolog
	= '<?xml'i
		_ version:XmlVersion _
		encoding:( encoding:Encoding _ { return encoding } )?
		standalone:( standalone:Standalone _ { return standalone } )?
		'?>'
		{
			return '<?xml ' + version + ( encoding ? ' ' + encoding : '' ) + ( standalone  ? ' ' + standalone : '' ) + ' ?>'
		}

XmlVersion
	= 'version'i _ '=' _ version:STRING
		{
			return 'version="' + version + '"'
		}

Encoding
	= 'encoding'i _ '=' _ encoding:STRING
		{ return 'encoding="' + encoding + '"' }

Standalone
	= 'standalone'i _ '=' _ value:STRING
	{
		var _ref;

		if ((_ref = value.toLowerCase()) !== "yes" && _ref !== "no") {
		  return expected("that standalone is 'yes' or 'no'")
		} else {
			return 'standalone="' + value + '"'
		}
	}

//
// CDATA section
//
Cdata "CDATA"
	= '<![CDATA[' content:CdataContent { return indent() + '<![CDATA[' + content }

CdataContent
	= ']]>'
	/ head:. tail:CdataContent { return head + tail }

//
// XML comments
//
Comment "comment"
	= '<!--' content:CommentContent { return indent() + '<!--' + content.split('\n').join('\n' + indent()) }

CommentContent
	= '-->'
	/ head:. tail:CommentContent { return head + tail }
