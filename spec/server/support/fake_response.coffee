_ = require("underscore")
express = require("express")

class FakeResponse
  constructor: ->
    @statusCode = 200
    @headers = {}
    @body = ""

  end: (@body) ->

_.defaults(FakeResponse.prototype, express.response)

module.exports = FakeResponse
