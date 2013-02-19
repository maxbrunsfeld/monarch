_ = require "underscore"
Nodes = require "./nodes"
{ visit } = require("../core").Util

visitPrimitive = (value) ->
  new Nodes.Literal(value)

class QueryBuilder
  buildQuery: (args...) ->
    @visit(args...)

  visit: visit

  visit_Boolean: visitPrimitive
  visit_Number: visitPrimitive
  visit_String: visitPrimitive
  visit_null: visitPrimitive

  visit_Relations_Selection: (r, args...) ->
    _.tap @visit(r.operand, args...), (query) =>
      query.addCondition(@visit(r.predicate, query.table()))

  visit_Expressions_And: (e, table) ->
    new Nodes.And(@visit(e.left, table), @visit(e.right, table))

  visit_Expressions_Equal: (e, table) ->
    new Nodes.Equals(@visit(e.left, table), @visit(e.right, table))

  visit_Expressions_Column: (e, table) ->
    new Nodes.SelectColumn(table, e.table.resourceName(), e.resourceName())

  buildTableNode: (table) ->
    new Nodes.Table(table.resourceName())

module.exports = QueryBuilder
