class Column
  constructor: (@source, @tableName, @name) ->

  resolveName: ->
    @source.resolveColumnName(@tableName, @name)

module.exports = Column
