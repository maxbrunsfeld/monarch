Binary = require "./binary"

class Join extends Binary
  constructor: (@left, @right, @condition) ->

  resolveColumnName: (args...) ->
    @left.resolveColumnName(args...) || @right.resolveColumnName(args...)

module.exports = Join
