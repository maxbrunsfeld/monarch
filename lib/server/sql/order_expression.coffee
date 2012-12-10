module.exports = ({ Monarch, _ }) ->

  class Monarch.Sql.OrderExpression
    constructor: (@tableName, @columnName, @directionString) ->

    toSql: ->
      "\"#{@tableName}\".\"#{@columnName}\" #{@directionString}"