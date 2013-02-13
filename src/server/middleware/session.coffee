defaultRepository = require "../default_repository"

module.exports = (sessionKey) ->
  sessionKey ?= 'monarch'
  (req, res, next) ->
    req[sessionKey] = defaultRepository.clone().recordClasses()
    next()
