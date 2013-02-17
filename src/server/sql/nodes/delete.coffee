_ = require "underscore"
Query = require "./query"

class Delete extends Query
  constructor: (table, assignments) ->
    @setTable(table)

module.exports = Delete
