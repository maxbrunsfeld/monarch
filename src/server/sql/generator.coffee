_ = require "underscore"
Nodes = require "./nodes"
Types = require "./types"
{ visit, Inflection } = require("../core").Util
{ underscore } = Inflection

class Generator
  toSql: (query) ->
    @literals = []
    @literalIndex = 0
    sql = @visit(query)
    [sql, @literals]

  # private
  visit: visit

  visit_Nodes_Insert: (node) ->
    _.compact([
      @insertClauseSql(node)
      @columnsClauseSql(node)
      @valuesClauseSql(node)
      'RETURNING "id"'
    ]).join(' ')

  visit_Nodes_Select: (node) ->
    _.compact([
      @selectClauseSql(node),
      @fromClauseSql(node),
      @whereClauseSql(node),
      @orderByClauseSql(node),
      @limitClauseSql(node),
      @offsetClauseSql(node)
    ]).join(' ')

  visit_Nodes_Update: (node) ->
    _.compact([
      @updateClauseSql(node)
      @assignmentsClauseSql(node)
      @whereClauseSql(node)
    ]).join(' ')

  visit_Nodes_Delete: (node) ->
    _.compact([
      @deleteClauseSql(node)
      @whereClauseSql(node)
    ]).join(' ')

  visit_Nodes_Subquery: (node) ->
    "( #{@visit(node.query)} ) as #{@quoteIdentifier(node.name)}"

  visit_Nodes_Table: (node) ->
    @quoteIdentifier(node.name)

  visit_Nodes_Join: (node) ->
    [
      @visit_Nodes_Binary(node, "INNER JOIN")
      "ON"
      @visit(node.condition)
    ].join(' ')

  visit_Nodes_Column: (node) ->
    @quoteIdentifier(node.name)

  visit_Nodes_SelectColumn: (node, needsAlias) ->
    sourceTrace = node.traceSourceTable()
    sourceTable = sourceTrace.pop()
    outerTable = sourceTrace.shift()
    if outerTable
      @qualifyColumnName(
        outerTable.name,
        @aliasColumnName(sourceTable.name, node.name))
    else
      sourceName = @qualifyColumnName(sourceTable.name, node.name)
      if needsAlias
        "#{sourceName} as #{@aliasColumnName(sourceTable.name, node.name)}"
      else
        sourceName

  visit_Nodes_OrderExpression: (node) ->
    "#{@visit(node.column)} #{node.directionString}"

  visit_Nodes_Binary: (node, operator) ->
    [
      @parenthesizeIfNeeded(node.left)
      operator,
      @parenthesizeIfNeeded(node.right)
    ].join(' ')

  visit_Nodes_And: (node) -> @visit_Nodes_Binary(node, 'AND')
  visit_Nodes_Assignment: (node) -> @visit_Nodes_Binary(node, '=')
  visit_Nodes_Equals: (node) -> @visit_Nodes_Binary(node, '=')
  visit_Nodes_Union: (node) -> @visit_Nodes_Binary(node, 'UNION')
  visit_Nodes_Difference: (node) -> @visit_Nodes_Binary(node, 'EXCEPT')

  visit_Nodes_DropTable: (node) ->
    "DROP TABLE IF EXISTS #{node.tableName};"

  visit_Nodes_CreateTable: (node) ->
    "#{@createTableClauseSql(node)} ( #{@columnTypesClauseSql(node)} );"

  visit_Nodes_Literal: (node) ->
    @addLiteral(node.value)

  selectClauseSql: (node) ->
    "SELECT " + @visitList(node.columns(), true)

  fromClauseSql: (node) ->
    "FROM " + @visit(node.table())

  whereClauseSql: (node) ->
    "WHERE #{@visit(node.condition())}" if node.condition()

  limitClauseSql: (node) ->
    "LIMIT " + @addLiteral(node.limit()) if node.limit()

  offsetClauseSql: (node) ->
    "OFFSET " + @addLiteral(node.offset()) if node.offset()

  orderByClauseSql: (node) ->
    return if _.isEmpty(node.orderExpressions())
    "ORDER BY " + @visitList(node.orderExpressions())

  insertClauseSql: (node) ->
    "INSERT INTO " + @visit(node.table)

  columnsClauseSql: (node) ->
    "( #{@visitList(node.columns)} )"

  valuesClauseSql: (node) ->
    "VALUES " + ("( #{@visitList(list)} )" for list in node.valueLists).join(', ')

  updateClauseSql: (node) ->
    "UPDATE " + @visit(node.table())

  assignmentsClauseSql: (node) ->
    "SET " + @visitList(node.assignments())

  deleteClauseSql: (node) ->
    "DELETE FROM " + @visit(node.table())

  createTableClauseSql: (node) ->
    "CREATE TABLE " + node.tableName

  columnTypesClauseSql: (node) ->
    expressions = for name, type of node.columnDefinitions
      "#{underscore(name)} #{@databaseType(type)}"
    expressions.join(', ')

  qualifyColumnName: (tableName, columnName) ->
    "#{@quoteIdentifier(tableName)}.#{@quoteIdentifier(columnName)}"

  aliasColumnName: (tableName, columnName) ->
    "#{tableName}__#{columnName}"

  databaseType: (type) ->
    Types[type] || throw new Error("Unknown column type '#{type}'")

  parenthesizeIfNeeded: (node) ->
    if @needsParens(node)
      "( #{@visit(node)} )"
    else
      @visit(node)

  needsParens: (node) ->
    switch node.constructor
      when Nodes.Join, Nodes.Select
        true
      else
        false

  addLiteral: (value) ->
    @literalIndex += 1
    @literals.push(value)
    "$#{@literalIndex}"

  visitList: (list, args...) ->
    (@visit(item, args...) for item in list).join(', ')

  quoteIdentifier: (string) ->
    '"' + string + '"'

module.exports = Generator
