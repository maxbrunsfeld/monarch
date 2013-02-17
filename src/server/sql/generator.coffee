_ = require "underscore"
Nodes = require "./nodes"
{ Visitor } = require("../core").Util

class Generator
  toSql: (query) ->
    @literals = []
    @literalIndex = 0
    sql = @visit(query)
    [sql, @literals]

  # private
  visit: Visitor.visit

  visit_Insert: (node) ->
    _.compact([
      @insertClauseSql(node)
      @columnsClauseSql(node)
      @valuesClauseSql(node)
      'RETURNING "id"'
    ]).join(' ')

  visit_Select: (node) ->
    _.compact([
      @selectClauseSql(node),
      @fromClauseSql(node),
      @whereClauseSql(node),
      @orderByClauseSql(node),
      @limitClauseSql(node),
      @offsetClauseSql(node)
    ]).join(' ')

  visit_Update: (node) ->
    _.compact([
      @updateClauseSql(node)
      @assignmentsClauseSql(node)
      @whereClauseSql(node)
    ]).join(' ')

  visit_Delete: (node) ->
    _.compact([
      @deleteClauseSql(node)
      @whereClauseSql(node)
    ]).join(' ')

  visit_Subquery: (node) ->
    "( #{@visit(node.query)} ) as #{@quoteIdentifier(node.name)}"

  visit_Table: (node) ->
    @quoteIdentifier(node.tableName)

  visit_Join: (node) ->
    [
      @visit_Binary(node, "INNER JOIN")
      "ON"
      @visit(node.condition)
    ].join(' ')

  visit_InsertColumn: (node) ->
    @quoteIdentifier(node.name)

  visit_Column: (node, applyAlias) ->
    { tableName, columnName, innerTableName } = node.resolveName()
    if innerTableName
      @qualifyColumnName(
        tableName,
        @aliasColumnName(innerTableName, columnName))
    else
      sourceName = @qualifyColumnName(tableName, columnName)
      if applyAlias
        "#{sourceName} as #{@aliasColumnName(tableName, columnName)}"
      else
        sourceName

  visit_OrderExpression: (node) ->
    "#{@visit(node.column)} #{node.directionString}"

  visit_Binary: (node, operator) ->
    [
      @parenthesizeIfNeeded(node.left)
      operator,
      @parenthesizeIfNeeded(node.right)
    ].join(' ')

  visit_And: (node) -> @visit_Binary(node, 'AND')
  visit_Assignment: (node) -> @visit_Binary(node, '=')
  visit_Equals: (node) -> @visit_Binary(node, '=')
  visit_Union: (node) -> @visit_Binary(node, 'UNION')
  visit_Difference: (node) -> @visit_Binary(node, 'EXCEPT')

  visit_Literal: (node) ->
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

  qualifyColumnName: (tableName, columnName) ->
    "#{@quoteIdentifier(tableName)}.#{@quoteIdentifier(columnName)}"

  aliasColumnName: (tableName, columnName) ->
    "#{tableName}__#{columnName}"

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
