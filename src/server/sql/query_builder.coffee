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
      @addCondition(query, @visit(r.predicate, query.table()))

  visit_Expressions_And: (e, table) ->
    new Nodes.And(@visit(e.left, table), @visit(e.right, table))

  visit_Expressions_Equal: (e, table) ->
    new Nodes.Equals(@visit(e.left, table), @visit(e.right, table))

  visit_Expressions_Column: (e, table) ->
    new Nodes.SelectColumn(table, getTableAlias(this, e.table), e.resourceName())

  addCondition: (node, condition) ->
    node.condition =
      if node.condition
        new Nodes.And(node.condition, condition)
      else
        condition

  buildTableNode: (r) ->
    new Nodes.Table(r.resourceName(), getTableAlias(this, r))

  getTableAlias = (self, table) ->
    tableName = table.resourceName()
    self.aliasesByTable ?= {}
    aliases = self.aliasesByTable[tableName] ?= {}
    aliases[table.alias] ?= do ->
      index = _.size(aliases)
      if index == 0
        tableName
      else
        "#{tableName}#{index + 1}"

module.exports = QueryBuilder
