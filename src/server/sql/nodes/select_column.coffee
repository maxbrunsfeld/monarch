class SelectColumn
  constructor: (@source, @tableName, @name) ->

  resolveName: ->
    @source.resolveColumnName(@tableName, @name)

module.exports = SelectColumn
