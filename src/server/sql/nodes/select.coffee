_ = require "underscore"
Query = require "./query"

class Select extends Query
  constructor: (table, columns) ->
    @setTable(table)
    @setColumns(columns)
    @setCondition(null)
    @setOrderExpressions([])

  @accessors 'columns', 'orderExpressions', 'limit', 'offset'

  canHaveJoinAdded: ->
    !(@condition()? || @limit()?)

  canHaveOrderByAdded: ->
    !(@limit()?)

module.exports = Select
