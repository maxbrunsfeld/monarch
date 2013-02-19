SelectColumn = require("./select_column")

class Subquery
  constructor: (@query, index) ->
    @name = "t" + index

  resolveColumnName: (tableName, columnName) ->
    innerNames = @query.table().resolveColumnName(tableName, columnName)
    if innerNames
      {
        tableName: @name,
        columnName: innerNames.columnName,
        innerTableName: innerNames.tableName
      }

  allColumns: ->
    for column in @query.columns()
      new SelectColumn(this, column.tableName, column.name)

module.exports = Subquery
