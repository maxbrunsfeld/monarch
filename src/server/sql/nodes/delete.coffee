_ = require "underscore"
Query = require "./query"

class Delete extends Query
  constructor: (table, assignments) ->
    @setTable(table)

  toSql: ->
    _.compact([
      "DELETE FROM",
      @table().toSql(),
      @whereClauseSql()
    ]).join(' ')

  whereClauseSql: ->
    "WHERE " + @condition().toSql() if @condition()

module.exports = Delete
