{ visit } = require("../../core").Util

files = [
  "and"
  "assignment"
  "column"
  "delete"
  "difference"
  "equals"
  "insert"
  "insert_column"
  "join"
  "literal"
  "order_expression"
  "select"
  "subquery"
  "table"
  "union"
  "update"
]

{ camelize, capitalize } = require("../../core").Util.Inflection
for file in files
  klass = require "./#{file}"
  klassName = capitalize(camelize(file))
  module.exports[klassName] = klass

visit.setupAll(module.exports, "Nodes")
