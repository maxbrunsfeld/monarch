#= require_tree ./expressions
#= require_tree ./relations

do ->
  for moduleName in ["Expressions", "Relations"]
    _.each Monarch[moduleName], (klass, klassName) ->
      methodName = "visit_#{moduleName}_#{klassName}"
      klass.prototype.acceptVisitor = (visitor, args) ->
        visitor[methodName](this, args...)
