#!/bin/sh
pegjs xmlChecker.pegjs ../lib/xmlCheckerModule.js
pegjs -e XmlChecker xmlChecker.pegjs ../lib/xmlChecker.js
