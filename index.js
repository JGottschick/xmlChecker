checker = require('./lib/xmlCheckerModule.js');
prettifier = require('./lib/xmlPrettifierModule.js');
json = require('./lib/xml2jsonModule.js');

exports.check = checker.parse
exports.prettify = prettifier.parse
exports.json = json.parse
