fs = require("fs")
{ parallel } = require("async")
{ execFile } = require("child_process")
Snockets = require("snockets")

module.exports = (sourceFile, destinationFile) ->
  (new Snockets).scan sourceFile, (err, graph) ->
    dependencies = graph.getChain(sourceFile)
    args = ["-c", "--join", destinationFile]
    execFile "coffee", args.concat(dependencies), (err) ->
      message = err || "Wrote file #{destinationFile}"
      console.log message
