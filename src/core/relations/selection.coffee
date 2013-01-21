class Monarch.Relations.Selection extends Monarch.Relations.Relation
  @deriveEquality 'operand', 'predicate'
  @delegate 'getColumn', 'inferJoinColumns', 'columns', 'repository', to: 'operand'

  constructor: (@operand, predicate) ->
    @predicate = @resolvePredicate(predicate)
    @orderByExpressions = operand.orderByExpressions

  create: (attributes, args...) ->
    @operand.create(addSatisfyingAttributes(@predicate, attributes), args...)

  created: (attributes) ->
    @operand.created(addSatisfyingAttributes(@predicate, attributes))

  wireRepresentation: ->
    type: 'Selection'
    predicate: @predicate.wireRepresentation()
    operand: @operand.wireRepresentation()

addSatisfyingAttributes = (predicate, hashes) ->
  satisifyingAttributes = predicate.satisfyingAttributes()
  if _.isArray(hashes)
    for hash in hashes
      _.extend({}, hash, satisifyingAttributes)
  else
    _.extend({}, hashes, satisifyingAttributes)
