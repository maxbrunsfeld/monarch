Monarch.Util.visit = do ->
  visit = (object, args...) ->
    if object?.acceptVisitor
      object.acceptVisitor(this, args)
    else
      visitPrimitive.apply(this, arguments)

  visit.setup = (klass, names...) ->
    klass.prototype.acceptVisitor = acceptVisitorFn(names)

  visit.setupAll = (module, names...) ->
    for name, klass of module
      visit.setup(klass, names, name)

  # private

  acceptVisitorFn = (names) ->
    name = names.join("_")
    methodName = "visit_#{name}"
    (visitor, args) ->
      throw new Error("Cannot visit #{name}") unless visitor[methodName]
      visitor[methodName](this, args...)

  visitPrimitive = (object) ->
    name = visiteeName(object)
    methodName = "visit_#{name}"
    throw new Error("Cannot visit #{name}") unless this[methodName]
    this[methodName].apply(this, arguments)

  visiteeName = (object) ->
    switch object
      when null then "null"
      when undefined then "undefined"
      else object.constructor.name

  visit
