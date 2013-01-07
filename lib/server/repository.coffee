ConnectionPool = require "./connection_pool"

class Repository
  constructor: ->
    @tables = {}
    @connection = new ConnectionPool

  registerTable: (table) ->
    @tables[table.name] = table

  clear: ->
    @tables = {}

module.exports = Repository
