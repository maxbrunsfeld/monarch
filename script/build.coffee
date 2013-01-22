fs = require("fs")
snockets = new (require("snockets"))

module.exports = (srcFile, destinationFile) ->
  code = snockets.getConcatenation(srcFile, async: false)
  fs.writeFileSync(destinationFile, code)
