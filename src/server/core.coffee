_ = require("underscore")
snockets = new (require("snockets"))
corePath = "#{__dirname}/../core/index.coffee"
eval snockets.getConcatenation(corePath, async: false)
