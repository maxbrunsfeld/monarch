_ = require "underscore"
async = require "async"
{ Json, CompositeTuple } = require("./core")

class Sandbox
  constructor: (@recordClasses) ->

  @expose = (name, f) ->
    definition = -> f.call(this, @recordClasses)
    this::_tableDefinitions ?= {}
    this::_tableDefinitions[name] = definition
    this::[name] = definition

  fetch: (relationsJson, fn) ->
    relations = for relationJson in relationsJson
      Json.parse(relationJson, exposedTables(this))
    async.map relations, ((relation, f) -> relation.all(f)), (err, recordLists) ->
      fn(err, buildDataset(recordLists) unless err)

  create: (name, fieldValues, fn) ->
    beginTransactionWithTable this, name, (table, exposedTable) ->
      return fn(tableNotFound(name)) unless table
      table.create fieldValues, (err, count, rows) ->
        exposedTable.find rows[0].id, (err, record) ->
          if record
            table.commit -> fn(err, record.wireRepresentation())
          else
            table.rollBack -> fn(recordNotFound())

  update: (name, id, fieldValues, fn) ->
    beginTransactionWithTable this, name, (table, exposedTable) ->
      return fn(tableNotFound(name)) unless table
      exposedTable.find id, (err, record) ->
        return fn(recordNotFound()) unless record
        record.update fieldValues, (err) ->
          exposedTable.find id, (err, record) ->
            if record
              table.commit -> fn(err, record.wireRepresentation())
            else
              table.rollBack -> fn(recordNotFound())

  delete: (name, id, fn) ->
    [tableName, exposedTable] = getExposedTable(this, name)
    return fn(tableNotFound(name)) unless exposedTable
    exposedTable.find id, (err, record) ->
      if record
        record.destroy(fn)
      else
        fn(recordNotFound())

  beginTransactionWithTable = (sandbox, name, fn) ->
    [tableName, exposedTable] = getExposedTable(sandbox, name)
    return fn() unless exposedTable
    exposedTable.transaction (err, tx) ->
      txTable = tx[tableName]
      txExposedTable = exposedTable.inRepository(txTable.repository())
      fn(txTable, txExposedTable)

  getExposedTable = (sandbox, name) ->
    tableName = Json.tableNameFromJson(name)
    [tableName, exposedTables(sandbox)[tableName]]

  exposedTables = (sandbox) ->
    tables = {}
    for name, definition of sandbox._tableDefinitions
      tableName = Json.tableNameFromJson(name)
      tables[tableName] = definition.call(sandbox)
    tables

  buildDataset = (recordLists) ->
    dataset = {}
    addTuplesToDataset(dataset, list) for list in recordLists
    dataset

  addTuplesToDataset = (dataset, tuples) ->
    return if _.isEmpty(tuples)
    klass = tuples[0].constructor
    if (klass is CompositeTuple)
      addTuplesToDataset(dataset, (tuple.left for tuple in tuples))
      addTuplesToDataset(dataset, (tuple.right for tuple in tuples))
    else
      tableName = Json.tableNameToJson(klass.name)
      hash = dataset[tableName] ?= {}
      for tuple in tuples
        hash[tuple.id()] = tuple.wireRepresentation()

  tableNotFound = (name) ->
    { code: 404, message: "Relation '#{name}' not found" }

  recordNotFound = ->
    { code: 404, message: "Record not found" }

module.exports = Sandbox
