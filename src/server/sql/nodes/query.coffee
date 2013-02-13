And = require "./and"
{ Base } = require "../../core"

class Query extends Base
  @accessors 'table', 'condition'

  addCondition: (newCondition) ->
    @setCondition(
      if @condition()
        new And(@condition(), newCondition)
      else
        newCondition)

module.exports = Query

