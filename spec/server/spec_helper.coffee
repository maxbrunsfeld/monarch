env = process.env.MONARCH_TEST_ENV || 'dev'

_ = require 'underscore'
async = require 'async'

root = "#{__dirname}/../../src/server"
Monarch = require "#{root}/index"
defaultRepository = require "#{root}/default_repository"

matchers = require './support/matchers'
setupRecordClasses = require "./support/record_classes"
databaseConfig = require "./support/db/#{env}"
FakeResponse = require "./support/fake_response"

jasmine.DEFAULT_TIMEOUT_INTERVAL = 500
global.beforeAll = (f) ->
  beforeEach(_.once(f))

beforeEach ->
  setupRecordClasses()
  Monarch.configureConnection(databaseConfig)
  @addMatchers(matchers)

module.exports = {
  _
  async
  root
  Monarch
  databaseConfig
  FakeResponse
}
