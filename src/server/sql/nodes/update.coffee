_ = require "underscore"
Query = require "./query"

class Update extends Query
  constructor: (table, assignments) ->
    @setTable(table)
    @setAssignments(assignments)

  @accessors 'assignments'

  toSql: ->
    _.compact([
      "UPDATE",
      @table().toSql(),
      "SET",
      @assignmentsClauseSql(),
      @whereClauseSql()
    ]).join(' ')

  assignmentsClauseSql: ->
    (assignment.toSql() for assignment in @assignments()).join(', ')

  whereClauseSql: ->
    "WHERE " + @condition().toSql() if @condition()

module.exports = Update
