Query = require "./query"

class Update extends Query
  constructor: (table, assignments) ->
    @setTable(table)
    @setAssignments(assignments)

  @accessors 'assignments'

module.exports = Update
