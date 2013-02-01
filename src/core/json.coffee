Monarch.Json = (->
  @serialize = Monarch.Util.Visitor.visit
  @parse = (json) ->
    type = json.type
    method = this["parse_#{type}"]
    throw "Can't parse #{type} from JSON" unless method
    method.apply(this, arguments)

  @visit_Relations_Table = (r) ->
    type: 'Table'
    name: r.resourceName()

  @visit_Relations_Projection = (r) ->
    type: 'Projection'
    operand: @serialize(r.operand)
    table: r.table.name

  @visit_Relations_Selection = (r) ->
    type: 'Selection'
    operand: @serialize(r.operand)
    predicate: @serialize(r.predicate)

  @visit_Relations_InnerJoin = (r) ->
    type: 'InnerJoin',
    leftOperand: @serialize(r.left)
    rightOperand: @serialize(r.right)
    predicate: @serialize(r.predicate)

  @visit_Relations_Limit = (r) ->
    type: 'Limit'
    operand: @serialize(r.operand)
    count: r.count

  @visit_Relations_Offset = (r) ->
    type: 'Offset'
    operand: @serialize(r.operand)
    count: r.count

  @visit_Relations_Difference = (r) -> 
    type: 'Difference'
    leftOperand: @serialize(r.left)
    rightOperand: @serialize(r.right)

  @visit_Relations_Union = (r) ->
    type: 'Union'
    leftOperand: @serialize(r.left)
    rightOperand: @serialize(r.right)

  @visit_Relations_OrderBy = (r) ->
    @serialize(r.operand)

  @visit_Expressions_Column = (e) ->
    type: 'Column',
    table: e.table.resourceName(),
    name: e.resourceName()

  _.each [
    'Equal'
    'LessThan'
    'GreaterThan'
    'GreaterThanOrEqual'
    'LessThanOrEqual'
    'And'
    'Or'
  ], (operator) =>
    this["visit_Expressions_#{operator}"] = (e) ->
      type: operator,
      leftOperand: wrapScalars(@serialize(e.left)),
      rightOperand: wrapScalars(@serialize(e.right))

  @visit_Boolean = _.identity
  @visit_Number = _.identity
  @visit_String = _.identity
  @visit_null = _.identity
  @visit_Date = (d) -> d.getTime()

  wrapScalars = (value) ->
    return value if _.isObject(value)
    { type: 'Scalar', value }

  this
).call({})
