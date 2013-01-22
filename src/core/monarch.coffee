_.extend Monarch,
  fetchUrl: '/sandbox'
  resourceUrlRoot: ''
  resourceUrlSeparator: '-'
  snakeCase: false
  setupConstructor: (constructor, columnDefinitions) ->
    constructor extends Monarch.Record
    constructor.extended(constructor)
    constructor.columns(columnDefinitions) if columnDefinitions

  Expressions: {}
  Relations: {}
  Remote: {}
  Util: {}

