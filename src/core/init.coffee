Monarch = ->
  Monarch.setupConstructor.apply(Monarch, arguments)

if typeof exports is 'undefined'
  window.Monarch = Monarch
else
  module.exports = Monarch
