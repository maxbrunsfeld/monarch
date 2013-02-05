Monarch.Json = (->
  { Relations, Expressions, Util } = Monarch
  { singularize, capitalize, camelize, underscoreAndPluralize, underscore, uncapitalize } = Util.Inflection

  @serialize = Monarch.Util.Visitor.visit
  @parse = (json, tables) ->
    type = json.type
    method = this["parse_#{type}"]
    throw "Can't parse #{type} from JSON" unless method
    method.call(this, json, normalizeTables(tables))

  @tableNameFromJson = (name) ->
    singularize(capitalize(camelize(name)))
  @tableNameToJson = (name) ->
    replaceSeparator(underscoreAndPluralize(uncapitalize(name)))

  @columnNameFromJson = camelize
  @columnNameToJson = (name) ->
    replaceSeparator(underscore(name))

  @visit_Relations_Table = (r) ->
    type: 'Table'
    name: @tableNameToJson(r.name)

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
    type: 'Column'
    table: @tableNameToJson(e.table.name)
    name: @columnNameToJson(e.name)

  @parse_Table = (json, tables) ->
    tables[@tableNameFromJson(json.name)]

  @parse_Projection = (json, tables) ->
    new Relations.Projection(
      @parse(json.operand, tables),
      tables[json.table])

  @parse_Selection = (json, tables) ->
    new Relations.Selection(
      @parse(json.operand, tables),
      @parse(json.predicate, tables))

  @parse_InnerJoin = (json, tables) ->
    new Relations.InnerJoin(
      @parse(json.leftOperand, tables),
      @parse(json.rightOperand, tables),
      @parse(json.predicate, tables))

  @parse_Limit = (json, tables) ->
    new Relations.Limit(
      @parse(json.operand, tables),
      json.count)

  @parse_Offset = (json, tables) ->
    new Relations.Offset(
      @parse(json.operand, tables),
      json.count)

  @parse_Difference = (json, tables) ->
    new Relations.Difference(
      @parse(json.leftOperand, tables),
      @parse(json.rightOperand, tables))

  @parse_Union = (json, tables) ->
    new Relations.Union(
      @parse(json.leftOperand, tables),
      @parse(json.rightOperand, tables))

  @parse_Column = (json, tables) ->
    table = tables[@tableNameFromJson(json.table)]
    table.getColumn(@columnNameFromJson(json.name))

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

    this["parse_#{operator}"] = (json, c) ->
      new Expressions[operator](
        @parse(json.leftOperand, c),
        @parse(json.rightOperand, c))

  @visit_Boolean = _.identity
  @visit_Number = _.identity
  @visit_String = _.identity
  @visit_null = _.identity
  @visit_Date = (d) -> d.getTime()

  @parse_Scalar = (json) -> json.value

  replaceSeparator = (name) ->
    name.replace(/_/g, Monarch.resourceUrlSeparator)

  wrapScalars = (value) ->
    return value if _.isObject(value)
    { type: 'Scalar', value }

  normalizeTables = (tables) ->
    result = {}
    result[name] = normalizeTable(table) for name, table of tables
    result

  normalizeTable = (tableOrClass) ->
    if tableOrClass instanceof Relations.Relation
      tableOrClass
    else
      tableOrClass.table

  this
).call({})
