_ = require "underscore"
{ Json } = require("./core")

class Sandbox
  constructor: (@exposeTables) ->

  fetch: (relationsJson, tables, fn) ->
    tables = @exposeTables(tables)
    relations = for relationJson in relationsJson
      Json.parse(relationJson, tables)

    relations[0].all (err, records) ->
      return fn(err, null) if err
      json = {}
      unless _.isEmpty(records)
        klass = records[0].constructor
        name = Json.tableNameToJson(klass.name)
        json[name] = (record.wireRepresentation() for record in records)
      fn(null, json)

  create: (tableName, recordJson, tables, fn) ->
    table = tables[Json.tableNameFromJson(tableName)]
    return fn('No such table') unless table
    table.create recordJson, (err, count, rows) ->
      return fn(err) if err
      fn(null, rows[0])

module.exports = Sandbox
