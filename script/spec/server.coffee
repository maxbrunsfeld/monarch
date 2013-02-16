#!/usr/bin/env coffee

root = "#{__dirname}/../.."
{ spawn } = require 'child_process'
options = require("optimist").argv
jasminePath = "#{root}/node_modules/jasmine-node/bin/jasmine-node"

# options
specPath = options._[0] || "spec/server"
watch = options.w

proc = null

stopTests = ->
  if proc
    proc.kill('SIGINT')
    console.log "\n"

runTests = ->
  stopTests()
  proc = spawn(jasminePath, [ "--coffee", "--nohelpers", "--forceexit", "#{root}/#{specPath}" ])
  proc.stdout.pipe(process.stdout)
  proc.stderr.pipe(process.stderr)

runTests()

if watch
  watcher = require('watch-tree')
  for path in ["spec/server", "src/core", "src/server"]
    watcher.watchTree("#{root}/#{path}", 'sample-rate': 10)
      .on('fileModified', runTests)
      .on('fileCreated', runTests)
      .on('fileDeleted', runTests)
else
  proc.on('exit', (code) ->
    process.exit(code))
