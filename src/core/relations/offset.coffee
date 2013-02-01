class Monarch.Relations.Offset extends Monarch.Relations.Relation
  @deriveEquality 'operand', 'count'
  @delegate 'getColumn', 'inferJoinColumns', 'columns', 'repository', to: 'operand'

  constructor: (@operand, @count) ->
    @orderByExpressions = operand.orderByExpressions
