class Monarch.Relations.Difference extends Monarch.Relations.Relation
  @deriveEquality 'left', 'right'
  @delegate 'getColumn', 'inferJoinColumns', 'columns', 'repository', to: 'left'

  constructor: (@left, @right) ->
    @orderByExpressions = left.orderByExpressions
