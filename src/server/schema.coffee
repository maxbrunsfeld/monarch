Generator = require "./sql/generator"
{ CreateTable, DropTable } = require "./sql/nodes"
{ connection } = require "./default_repository"

module.exports =
  dropTable: (tableName, done) ->
    statement = new DropTable(tableName)
    sql = (new Generator).toSql(statement)[0]
    @connection().query(sql, done)

  createTable: (tableName, columnDefinitions, done) ->
    statement = new CreateTable(tableName, columnDefinitions)
    sql = (new Generator).toSql(statement)[0]
    @connection().query(sql, done)

  connection: ->
    connection
