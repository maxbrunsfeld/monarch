_ = require 'underscore'
async = require 'async'

root = "#{__dirname}/../../src/server"
Monarch = require "#{root}/index"
defaultRepository = require "#{root}/default_repository"

matchers = require './support/matchers'
recordClasses = require "./support/record_classes"
databaseConfig = require "./support/db/dev"
FakeResponse = require "./support/fake_response"

jasmine.DEFAULT_TIMEOUT_INTERVAL = 500
global.beforeAll = (f) ->
  beforeEach(_.once(f))

beforeEach ->
  reinitializeRepository()
  Monarch.configureConnection(databaseConfig)
  @addMatchers(matchers)

reinitializeRepository = ->
  defaultRepository.clear()
  for klassName, klass of recordClasses
    defaultRepository.registerTable(klass.table)

module.exports = {
  _
  async
  root
  Monarch
  recordClasses
  databaseConfig
  FakeResponse
}
