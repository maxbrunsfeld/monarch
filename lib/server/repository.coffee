_ = require "underscore"

class Repository
  constructor: (@connection) ->
    @tables={}

  registerTable: (table) ->
    @tables[table.name] = table

  clone: (connection) ->
    clone = new Repository(connection)
    for tableName, table of this.tables
      clone.tables[tableName] = cloneTable(table, clone)
    clone

  clear: ->
    @tables = {}

cloneTable = (table, repository) ->
  clone = _.clone(table)
  _.extend clone,
    recordClass: cloneRecordClass(table.recordClass, repository)

cloneRecordClass = (klass, repository) ->
  clone = -> klass.apply(this, arguments)
  _.extend clone, klass,
    prototype: klass.prototype
    repository: -> repository

module.exports = Repository
