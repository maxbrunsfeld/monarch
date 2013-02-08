_ = require "underscore"
Monarch = require("./core")
{ connection } = require('./default_repository')

_.extend Monarch,
  resourceUrlSeparator: '_'
  middleware: require "./middleware"
  Schema: require "./schema"
  Sandbox: require "./sandbox"

  configureConnection: (args...) ->
    connection.configure(args...)

require('./relations/relation')(Monarch.Relations.Relation)
require('./relations/table')(Monarch.Relations.Table)
require('./relations/selection')(Monarch.Relations.Selection)
require('./record')(Monarch.Record)

module.exports = Monarch
