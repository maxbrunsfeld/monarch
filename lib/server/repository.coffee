_ = require "underscore"

class Repository
  constructor: (@connection) ->
    @tables={}

  registerTable: (table) ->
    setRepository(table, this)
    @tables[table.name] = table

  recordClasses: ->
    recordClasses = {}
    for name, table of @tables
      recordClasses[name] = table.recordClass
    recordClasses

  clone: (connection) ->
    newRepository = new Repository(connection)
    for tableName, table of this.tables
      newRepository.registerTable(cloneTable(table))
    newRepository

  clear: ->
    @tables = {}

cloneTable = (table) ->
  newRecordClass = cloneClass(table.recordClass)
  newTable = new (table.constructor)(newRecordClass)
  newRecordClass.table = newTable
  _.extend newTable, table, { recordClass: newRecordClass }

setRepository = (table, repository) ->
  table.recordClass.repository = -> repository

cloneClass = (klass) ->
  newKlass = cloneNamedFunction(klass)
  dummyConstructor = _.extend((->), prototype: klass.prototype)
  newKlass.prototype = _.extend((new dummyConstructor), klass.prototype, constructor: newKlass)
  _.extend newKlass, klass

cloneNamedFunction = (f) ->
  eval("function #{f.name}() { return f.apply(this, arguments); } #{f.name}")

module.exports = Repository
