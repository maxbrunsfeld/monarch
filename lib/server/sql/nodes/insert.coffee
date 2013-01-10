class Insert
  constructor: (@table, @columns, @valueLists) ->

  toSql: ->
    [
      "INSERT INTO",
      @table.toSql(),
      @columnsClause(),
      "VALUES",
      @valuesClause()
    ].join(' ')

  columnsClause: ->
    parenthesizedList(@columns)

  valuesClause: ->
    (parenthesizedList(list) for list in @valueLists).join(', ')

parenthesizedList = (elements) ->
  listSql = (element.toSql() for element in elements).join(', ')
  "( #{listSql} )"

module.exports = Insert
