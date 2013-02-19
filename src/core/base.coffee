class Monarch.Base
  { capitalize } = Monarch.Util.Inflection

  isEqual = (left, right) ->
    if left.isEqual?
      left.isEqual(right)
    else
      _.isEqual(left, right)

  @deriveEquality: (properties...) ->
    @prototype.isEqual = (other) ->
      return false unless other instanceof @constructor
      for property in properties
        return false unless isEqual(this[property], other[property])
      true

  @delegate: (methodNames..., {to}) ->
    for methodName in methodNames
      do (methodName) =>
        @prototype[methodName] = (args...) -> this[to][methodName](args...)

  @reopen: (f) ->
    prototypeProperties = f.call(this)
    _.extend(this.prototype, prototypeProperties)
