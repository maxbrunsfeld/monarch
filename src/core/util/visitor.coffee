Monarch.Util.Visitor = do ->
  visitPrimitive = (object) ->
    name = visiteeName(object)
    method = this['visit_' + name]
    throw new Error("Cannot visit #{name}") unless method
    method.apply(this, arguments)

  visiteeName = (object) ->
    switch object
      when null then "null"
      when undefined then "undefined"
      else object.constructor.name

  visit: (object, args...) ->
    if object?.acceptVisitor?
      object.acceptVisitor(this, args)
    else
      visitPrimitive.apply(this, arguments)
