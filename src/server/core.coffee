_ = require("underscore")

eval do ->
  coffee = require("coffee-script")
  Snockets = require("snockets")
  Snockets.compilers.coffee.compileSync = (file, source) ->
    coffee.compile(source, filename: file, bare: true)
  coreFile = "#{__dirname}/../core/index.coffee"

  # debugging
  s = new Snockets
  s.scan(coreFile, async: false)
  chain = s.getCompiledChain(coreFile, async: false)
  files = (entry.filename for entry in chain)
  console.log files

  (new Snockets).getConcatenation(coreFile, async: false)
