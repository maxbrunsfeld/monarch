_ = require "underscore"
{ Base } = require "../../core"

module.exports = class Select extends Base
  constructor: (table, columns) ->
    @setTable(table)
    @setColumns(columns)
    @setCondition(null)
    @setOrderExpressions([])

  toSql: ->
    _.compact([
      @selectClauseSql(),
      @fromClauseSql(),
      @whereClauseSql(),
      @orderByClauseSql(),
      @limitClauseSql(),
      @offsetClauseSql()
    ]).join(' ')

  @accessors 'table', 'columns', 'condition', 'orderExpressions',
             'limit', 'offset'

  selectClauseSql: ->
    parts = @columns().map (columnRef) -> columnRef.toSelectClauseSql()
    "SELECT " + parts.join(', ')

  fromClauseSql: ->
    "FROM " + @table().toSql()

  whereClauseSql: ->
    "WHERE " + @condition().toSql() if @condition()

  orderByClauseSql: ->
    if not _.isEmpty(@orderExpressions())
      "ORDER BY " + @orderExpressions().map((e) -> e.toSql()).join(', ')

  limitClauseSql: ->
    if @limit()
      "LIMIT " + @limit()

  offsetClauseSql: ->
    if @offset()
      "OFFSET " + @offset()

  canHaveJoinAdded: ->
    !(@condition()? || @limit()?)

  canHaveOrderByAdded: ->
    !(@limit()?)
