_ = require "underscore"
Nodes = require "./nodes"
QueryBuilder = require "./query_builder"
{ underscore } = require("../core").Util.Inflection

class InsertBuilder extends QueryBuilder
  visit_Relations_Table: (table, hashes) ->
    hashes = [hashes] unless _.isArray(hashes)
    table = @getTableNode(table)
    columnNames = getColumnNames(hashes)
    columns = buildColumns(columnNames)
    valueLists = buildValueLists(this, hashes, columnNames)
    new Nodes.Insert(table, columns, valueLists)

  getColumnNames = (hashes) ->
    _.union((_.keys(hash) for hash in hashes)...)

  buildValueLists = (self, hashes, columnNames) ->
    for hash in hashes
      for columnName in columnNames
        self.visit(hash[columnName] ? null)

  buildColumns = (columnNames) ->
    for name in columnNames
      new Nodes.Column(underscore(name))

module.exports = InsertBuilder
