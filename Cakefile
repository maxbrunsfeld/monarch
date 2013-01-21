option '-p', '--path [DIR]', 'path to directory'

task "build", "compile source files", ->
  fs = require("fs")
  Snockets = require 'snockets'
  snockets = new Snockets

  fs.writeFileSync(
    "monarch.js",
    snockets.getConcatenation 'src/client/index.coffee', async: false)

  fs.writeFileSync(
    "monarch_test_support.js",
    snockets.getConcatenation 'src/client_test_support/index.coffee', async: false)

task "spec:client", "start server for client-side tests", ->
  require "#{__dirname}/script/server"
  console.log "Spec server listening on port 8888"

task "spec:server", "run server-side tests", (options) ->
  specPath = options.path or "spec/server"

  { spawn } = require 'child_process'
  jasmine_bin = "#{__dirname}/node_modules/jasmine-node/bin/jasmine-node"
  runTests = ->
    proc = spawn(jasmine_bin, [ "--coffee", "--nohelpers", "#{__dirname}/#{specPath}" ])
    proc.stdout.pipe(process.stdout)
    proc.stderr.pipe(process.stderr)

  watcher = require('watch-tree')
  for path in ["spec/server", "src/core", "src/server"]
    watcher.watchTree("#{__dirname}/#{path}", 'sample-rate': 10)
      .on('fileModified', runTests)
      .on('fileCreated', runTests)
      .on('fileDeleted', runTests)
  runTests()

task "spec:setup", "setup database for server-side tests", ->
  require './spec/server/support/setup'
