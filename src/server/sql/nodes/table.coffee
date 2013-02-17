class Table
  constructor: (@tableName) ->

  resolveColumnName: (tableName, columnName) ->
    if tableName is @tableName
      {
        tableName: @tableName,
        columnName: columnName,
      }

module.exports = Table
