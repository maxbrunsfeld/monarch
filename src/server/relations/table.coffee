Generator = require "../sql/generator"
InsertBuilder = require "../sql/insert_builder"
UpdateBuilder = require "../sql/update_builder"
DeleteBuilder = require "../sql/delete_builder"

module.exports = (Table) ->

  Table.reopen ->
    createSql: -> buildSql(this, InsertBuilder, arguments)
    updateSql: -> buildSql(this, UpdateBuilder, arguments)
    deleteSql: -> buildSql(this, DeleteBuilder, arguments)

    create: (args..., f) -> executeAndGetRowCount(this, @createSql(args...), f)
    updateAll: (args..., f) -> executeAndGetRowCount(this, @updateSql(args...), f)
    deleteAll: (args..., f) -> executeAndGetRowCount(this, @deleteSql(args...), f)

buildSql = (relation, builderClass, args) ->
  query = (new builderClass).buildQuery(relation, args...)
  (new Generator).toSql(query)

executeAndGetRowCount = (table, [sql, literals], f) ->
  table.connection().query sql, literals, (err, result) ->
    return f(err) if err
    f(null, result.rowCount, result.rows)
