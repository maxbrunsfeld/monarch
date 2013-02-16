#!/usr/bin/env coffee

fs = require("fs")
{ parallel } = require("async")
{ execFile } = require("child_process")
Snockets = require("snockets")

build = (sourceFile, destinationFile) ->
  (new Snockets).scan sourceFile, (err, graph) ->
    dependencies = graph.getChain(sourceFile)
    args = ["-c", "--join", destinationFile]
    execFile "coffee", args.concat(dependencies), (err) ->
      message = err || "Wrote file #{destinationFile}"
      console.log message


build("src/client/index.coffee", "lib/client.js")
build("src/client_test_support/index.coffee", "lib/client_test_support.js")
