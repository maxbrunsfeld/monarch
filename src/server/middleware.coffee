_ = require "underscore"
express = require "express"
defaultRepository = require "./default_repository"

module.exports = buildMiddleware = (options = {}) ->
  { sessionKey, sandbox, sandboxUrl } = options
  sessionMiddleware = buildSessionMiddleware(sessionKey || 'monarch')
  sandboxMiddleware = if (sandbox && sandboxUrl)
    buildSandboxMiddleware(sessionKey, sandbox, sandboxUrl)
  else
    noop
  (req, res, next) ->
    sessionMiddleware(req)
    sandboxMiddleware(req, res, next)

buildSessionMiddleware = (sessionKey) ->
  (req, res, next) ->
    req[sessionKey] = defaultRepository.clone().recordClasses()

buildSandboxMiddleware = (sessionKey, sandbox, sandboxUrl) ->
  middleware = express()

  middleware.get sandboxUrl, (req, res) ->
    relationsJson = JSON.parse(req.query.relations)
    sandbox.fetch relationsJson, req[sessionKey], (err, recordsJson) ->
      if err
        res.status(500)
      else
        res.end(JSON.stringify(recordsJson))

  middleware.post "#{sandboxUrl}/:table", (req, res) ->
    tableName = req.params.table
    recordJson = req.body.fieldValues
    sandbox.create tableName, recordJson, req[sessionKey], (err, recordJson) ->
      if err
        res.status(404)
      else
        res.end(JSON.stringify(recordJson))


  middleware.router

noop = (req, res, next) -> next()
