{ Base, Util } = require("../core")

class Query extends Base
  @accessors 'table', 'condition'

  addCondition: (newCondition) ->
    @setCondition(
      if @condition()
        new And(@condition(), newCondition)
      else
        newCondition)

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

class Insert
  constructor: (@table, @columns, @valueLists) ->

class Update extends Query
  constructor: (table, assignments) ->
    @setTable(table)
    @setAssignments(assignments)

  @accessors 'assignments'

class Delete extends Query
  constructor: (table, assignments) ->
    @setTable(table)

class Binary extends Base
  constructor: (@left, @right) ->

class And extends Binary
class Assignment extends Binary
class Equals extends Binary

class Difference extends Binary
  @delegate 'table', 'columns', to: 'left'
class Union extends Binary
  @delegate 'table', 'columns', to: 'left'

class Join
  constructor: (@left, @right, @condition) ->

  resolveColumnName: (args...) ->
    @left.resolveColumnName(args...) || @right.resolveColumnName(args...)

class Literal
  constructor: (@value) ->

class OrderExpression
  constructor: (@column, @directionString) ->

class Column
  constructor: (@name) ->

class SelectColumn
  constructor: (@source, @tableName, @name) ->

  resolveName: ->
    @source.resolveColumnName(@tableName, @name)

class Table
  constructor: (@tableName) ->

  resolveColumnName: (tableName, columnName) ->
    if tableName is @tableName
      {
        tableName: @tableName,
        columnName: columnName,
      }

class Subquery
  constructor: (@query, index) ->
    @name = "t" + index

  resolveColumnName: (tableName, columnName) ->
    innerNames = @query.table().resolveColumnName(tableName, columnName)
    if innerNames
      {
        tableName: @name,
        columnName: innerNames.columnName,
        innerTableName: innerNames.tableName
      }

  allColumns: ->
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
