{ Base, Util } = require("../core")

class Query extends Base
  table: -> @_table
  columns: -> @_columns
  setTable: (x) -> @_table = x
  setColumns: (x) -> @_columns = x

class Select extends Query
  constructor: (table, columns) ->
    @setTable(table)
    @setColumns(columns)
    @orderExpressions = []

  canHaveJoinAdded: ->
    !(@condition? || @limit?)

  canHaveOrderByAdded: ->
    !(@limit?)

class Insert extends Query
  constructor: (table, columns, @valueLists) ->
    @setTable(table)
    @setColumns(columns)

class Update extends Query
  constructor: (table, @assignments) ->
    @setTable(table)

class Delete extends Query
  constructor: (table) ->
    @setTable(table)

class Binary extends Base
  constructor: (@left, @right) ->

class And extends Binary
class Assignment extends Binary
class Difference extends Binary
class Equals extends Binary
class Union extends Binary

for klass in [Union, Difference]
  klass.delegate 'table', 'columns', to: 'left'

class Join
  constructor: (@left, @right, @condition) ->

  traceTable: (name) ->
    @left.traceTable(name) || @right.traceTable(name)

class Literal
  constructor: (@value) ->

class OrderExpression
  constructor: (@column, @directionString) ->

class Column
  constructor: (@name) ->

class SelectColumn
  constructor: (@source, @tableName, @name) ->

  traceSourceTable: ->
    @source.traceTable(@tableName)

class Table
  constructor: (@name) ->

  traceTable: (name) ->
    [this] if name is @name

class Subquery
  constructor: (@query, index) ->
    @name = "t" + index

  traceTable: (name) ->
    innerTable = @query.table().traceTable(name)
    if innerTable
      [this].concat(innerTable)

  columns: ->
    for column in @query.columns()
      new SelectColumn(this, column.tableName, column.name)

class CreateTable
  constructor: (@tableName, @columnDefinitions) ->

class DropTable
  constructor: (@tableName) ->

module.exports = {
  And, Assignment, Column, CreateTable, Delete, Difference, DropTable,
  Equals, Insert, Join, Literal, OrderExpression, Select, SelectColumn
  Subquery, Table, Union, Update }

Util.visit.setupAll(module.exports, "Nodes")
