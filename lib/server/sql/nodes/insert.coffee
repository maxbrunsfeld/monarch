class Insert
  constructor: (@table, @columns, @valueLists) ->

  toSql: ->
    [
      "INSERT INTO",
      @table.toSql(),
      @columnsClauseSql(),
      "VALUES",
      @valuesClauseSql(),
      @returningClauseSql()
    ].join(' ')

  columnsClauseSql: ->
    parenthesizedList(@columns)

  valuesClauseSql: ->
    (parenthesizedList(list) for list in @valueLists).join(', ')

  returningClauseSql: ->
    'RETURNING "id"'

parenthesizedList = (elements) ->
  listSql = (element.toSql() for element in elements).join(', ')
  "( #{listSql} )"

module.exports = Insert
