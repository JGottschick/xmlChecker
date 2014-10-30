//
// xml2json.pegjs
//

//
// # XML to JSON
//
// This grammar for XML parses a XML string and
// outputs a corresponding JSON data structure.
//


//
// ## JSON conventions for XML content
//
// * each XML element is a dictionary entry containing an array with attributes, elements, text values and comments
// * element names are directly taken over including the full namespace
// * namespaces are prefixing the name of an element or attribute and are URL-encoded enclosed by two underlines
// * each XML attribute is a dictionary entry conating an array of values
// * attribute names are prefixed using a "@" and includes the full nampespace
// * the text value entries have the special name "#text"
// * the cdata value entries have the special name "#cdata"
// * comment entries have the special name "#comment"
//

/////////////////////////////////////////////////////
//
// ## This section defines the utilities functions
//

//
// utility function to check defined namespaces supporting a stack of defined namespaces
//
{
	var namespaces = {};
	var savedNamespaces = {};
	var scopes = [];
	function clone(obj) {
		if(obj == null || typeof(obj) != 'object')
			return obj;
		var temp = new obj.constructor();
		for(var key in obj)
			temp[key] = clone(obj[key]);
		return temp;
	}

	function removeEmpty(l) {
		var x, _i, _len, _results;
		_results = [];
		for (_i = 0, _len = l.length; _i < _len; _i++) {
			x = l[_i];
			if (x) {
				_results.push(x);
			}
		}
		return _results;
	};
}

////////////////////////////////////////////////////
//

Start
	= content:(Prolog comments:( _ c:Comment { return c } / _ PI { return null } )* e:( _ e:Element { return e } )? { return (e ? removeEmpty(comments).concat([e]) : removeEmpty(comments)) })? comments:Comment* _
		{
			return (content ? content.concat(comments) : comments);
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
	= prefix:Identifier ':' id:Identifier { return { prefix: prefix, id: id } }
	/ id:Identifier { return { id: id } }

////////////////////////////////////////////////////
//
// ## This section defines the valid tags
//
StartTag
	= '<' qid:QualifiedIdentifier
		& {
			savedNamespaces = clone(namespaces);
			return true
		}
		attributes:Attribute* _ '>'
		& {
			scopes.push(savedNamespaces);
			return true
		}
		{
			return { qid:(qid.prefix ? '__' + encodeURIComponent(namespaces[qid.prefix]).replace(/__/g, '%5F%5F') + '__' + qid.id : qid.id), attributes:attributes }
		}

EndTag
	= '</' QualifiedIdentifier _ '>'
		& {
			namespaces = scopes.pop();
			return true
		}

ClosedTag
	= '<' qid:QualifiedIdentifier
		& {
				savedNamespaces = clone(namespaces);
				return true
			}
		attributes:Attribute* _ '/>'
		& {
				namespaces = savedNamespaces;
				return true
			}
		{
			return { qid:(qid.prefix ? '__' + encodeURIComponent(namespaces[qid.prefix]).replace(/__/g, '%5F%5F') + '__' + qid.id : qid.id), attributes:attributes }
		}

////////////////////////////////////////////////////
//
// ## This section defines an element
//
Element
	= _ tag:StartTag
		_ contents:( content:ElementContent _ { return content })*
		_ EndTag
		{
			var result = {};
			result[tag.qid] = tag.attributes.concat(contents);
			return result
		}
	/ _ tag:ClosedTag
		{
			var result = {};
			result[tag.qid] = tag.attributes;
			return result
		}

ElementContent
	= Cdata
	/ Comment
	/ Element
	/ ElementValue

ElementValue
	= chars:([^<\n\r]+)
	{
		return { '#text': chars.join('').trim() }
	}

////////////////////////////////////////////////////
//
// ## This section defines an attribute
//
Attribute
	= _ qid:QualifiedIdentifier value:( _ '=' _ value:AttributeValue { return value } )?
		{
			if (qid.prefix != null && qid.prefix === 'xmlns' && value) {
				namespaces[qid.id] = value
				var result = {};
				result['@' + (qid.prefix ? '__xmlns__' + qid.id : qid.id)] = value;
				return result
			} else {
				var result = {};
				result['@' + (qid.prefix ? '__' + encodeURIComponent(namespaces[qid.prefix]).replace(/__/g, '%5F%5F') + '__' + qid.id : qid.id)] = value;
				return result
			}
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
	= '<?' Identifier __ PIContent

PIContent
	= '?>'
	/ __ PIContent
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
	= 'version'i _ '=' _ STRING

Encoding
	= 'encoding'i _ '=' _ STRING

Standalone
	= 'standalone'i _ '=' _ STRING

//
// CDATA section
//
Cdata "CDATA"
	= '<![CDATA[' CdataContent
		{
			return { '#cdata': content }
		}

CdataContent
	= ']]>'
	/ head:. tail:CdataContent { return head + tail }

//
// XML comments
//
Comment "comment"
	= '<!--' content:CommentContent
		{
			return { '#comment': content }
		}

CommentContent
	= '-->' { return '' }
	/ head:. tail:CommentContent { return head + tail }
