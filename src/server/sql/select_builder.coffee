_ = require "underscore"
Nodes = require "./nodes"
QueryBuilder = require "./query_builder"

class SelectBuilder extends QueryBuilder
  constructor: ->
    @subqueryIndex = 0

  visit_Relations_Table: (r) ->
    table = @getTableNode(r)
    columns = (@visit(column, table) for column in r.columns())
    new Nodes.Select(table, columns)

  visit_Relations_OrderBy: (r) ->
    operandQuery = @visit(r.operand)
    unless operandQuery.canHaveOrderByAdded()
      operandQuery = wrapQuery(this, operandQuery)
    _.tap operandQuery, (query) =>
      query.orderExpressions = (
        @visit(e, query.table()) for e in r.orderByExpressions)

  visit_Relations_Limit: (r) ->
    _.tap @visit(r.operand), (query) ->
      query.limit = r.count

  visit_Relations_Offset: (r) ->
    _.tap @visit(r.operand), (query) ->
      query.offset = r.count

  visit_Relations_Union: (r) ->
    new Nodes.Union(@visit(r.left), @visit(r.right))

  visit_Relations_Difference: (r) ->
    new Nodes.Difference(@visit(r.left), @visit(r.right))

  visit_Relations_InnerJoin: (r) ->
    [leftQuery, rightQuery] = for side in ['left', 'right']
      operandQuery = @visit(r[side])
      if operandQuery.canHaveJoinAdded?()
        operandQuery
      else
        wrapQuery(this, operandQuery)
    columns = (leftQuery.columns()).concat(rightQuery.columns())
    join = new Nodes.Join(leftQuery.table(), rightQuery.table())
    join.condition = @visit(r.predicate, join)
    new Nodes.Select(join, columns)

  visit_Relations_Projection: (r) ->
    _.tap @visit(r.operand), (query) =>
      query.setColumns(
        @visit(column, query.table()) for column in r.table.columns())

  visit_Relations_Alias: ->
    @visit_Relations_Table.apply(this, arguments)

  visit_Expressions_OrderBy: (e, table) ->
    new Nodes.OrderExpression(
      @visit(e.column, table),
      e.directionCoefficient)

  wrapQuery = (self, query) ->
    subquery = new Nodes.Subquery(query, "t#{++self.subqueryIndex}")
    new Nodes.Select(subquery, subquery.columns())

module.exports = SelectBuilder
