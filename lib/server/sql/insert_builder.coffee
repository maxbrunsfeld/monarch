_ = require "underscore"
Visitor = require("../core").Util.Visitor
Nodes = require "./nodes"
{ underscore } = require("../core").Util.Inflection

module.exports = class InsertBuilder
  visit: Visitor.visit

  visit_Relations_Table: (table, hashes) ->
    hashes = [hashes] unless _.isArray(hashes)
    columnNames = _.keys(hashes[0])
    valueLists = for hash in hashes
      hash[columnName] for columnName in columnNames

    new Nodes.Insert(
      @buildTable(table)
      @buildColumns(columnNames),
      @visitValueLists(valueLists))

  buildTable: (table) ->
    new Nodes.Table(table.resourceName())

  buildColumns: (columnNames) ->
    for name in columnNames
      new Nodes.InsertColumn(underscore(name))

  visitValueLists: (valueLists) ->
    for list in valueLists
      @visit(value) for value in list

  visit_String: (e) ->
    new Nodes.StringLiteral(e)

  visit_Boolean: (e) ->
    new Nodes.Literal(e)

  visit_Number: (e) ->
    new Nodes.Literal(e)

