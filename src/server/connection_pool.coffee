_ = require "underscore"
pg = require('pg').native
Transaction = require "./transaction"

REQUIRED_KEYS = ['host', 'port', 'user', 'database']
OPTIONAL_KEYS = ['password']
CONFIG_KEYS = REQUIRED_KEYS.concat(OPTIONAL_KEYS)

class ConnectionPool
  constructor: ->
    @_config = {}

  configure: (params) ->
    for key, value of params
      @_config[key] = params[key] if _.include(REQUIRED_KEYS, key)

  query: (args..., callback) ->
    return callback(error) if error = configError(this)
    pg.connect @_config, (err, client) ->
      return callback(err) if err
      client.query(args..., callback)

  begin: (callback) ->
    client = new pg.Client(@_config)
    client.connect (err) ->
      return callback(err) if err
      client.query "BEGIN", (err, result) ->
        callback(err, new Transaction(client))

configError = (pool) ->
  missingConfigOptions = _.filter REQUIRED_KEYS, (key) -> !pool._config[key]
  unless _.isEmpty(missingConfigOptions)
    new Error("Missing connection parameters: " + missingConfigOptions.join(', '))

module.exports = ConnectionPool
