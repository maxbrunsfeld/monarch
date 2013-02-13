express = require "express"

module.exports = (sessionKey, sandboxClass, sandboxUrl) ->
  sessionKey ?= 'monarch'
  sandboxUrl ?= '/sandbox'
  middleware = express()

  middleware.get sandboxUrl, (req, res) ->
    relationsJson = JSON.parse(req.query.relations)
    sandbox(req).fetch(relationsJson, handleResponse(res))

  middleware.post "#{sandboxUrl}/:tableName", (req, res) ->
    { tableName } = req.params
    { fieldValues } = req.body
    sandbox(req).create(tableName, fieldValues, handleResponse(res))

  middleware.put "#{sandboxUrl}/:tableName/:id", (req, res) ->
    { tableName, id } = req.params
    { fieldValues } = req.body 
    sandbox(req).update(tableName, parseInt(id), fieldValues, handleResponse(res))

  middleware.delete "#{sandboxUrl}/:tableName/:id", (req, res) ->
    { tableName, id } = req.params
    sandbox(req).delete(tableName, parseInt(id), handleResponse(res))

  sandbox = (req) ->
    new sandboxClass(req[sessionKey])

  middleware.router

handleResponse = (res) ->
  (err, result) ->
    [status, body] = if err
      [err.code, err.message]
    else
      [200, JSON.stringify(result)]
    res.status(status).end(body)
