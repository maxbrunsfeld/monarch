_ = require("underscore")

eval do ->
  coffee = require("coffee-script")
  Snockets = require("snockets")
  Snockets.compilers.coffee.compileSync = (file, source) ->
    coffee.compile(source, filename: file, bare: true)
  coreFile = "#{__dirname}/../core/index.coffee"
  (new Snockets).getConcatenation(coreFile, async: false)
