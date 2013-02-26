class Monarch.Relations.Alias extends Monarch.Relations.Relation
  @delegate 'resourceName', 'inferJoinColumns', 'repository', to: 'operand'
  @deriveEquality 'name', 'alias'
  @index = 0

  constructor: (@operand) ->
    @columnsByName = {}
    @name = operand.name
    @recordClass = operand.recordClass
    @alias = "alias#{@constructor.index++}"

  columns: ->
    @getColumn(name) for name of @operand.columnsByName

  getColumn: (name) ->
    @columnsByName[name] ?= @operand.getColumn(name).clone(this)
