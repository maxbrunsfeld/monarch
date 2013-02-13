_ = require "underscore"
sessionMiddleware = require "./session"
sandboxMiddleware = require "./sandbox"

module.exports = (options = {}) ->
  { sessionKey, sandboxClass, sandboxUrl } = options
  if sandboxClass
    stackMiddleware(
      sessionMiddleware(sessionKey),
      sandboxMiddleware(sessionKey, sandboxClass, sandboxUrl))
  else
    sessionMiddleware(sessionKey)

stackMiddleware = (outer, inner) ->
  (req, res, next) ->
    outer(req, res, ->
      inner(req, res, next))

module.exports.session = sessionMiddleware
module.exports.sandbox = sandboxMiddleware
