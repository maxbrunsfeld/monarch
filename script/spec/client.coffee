#!/usr/bin/env coffee

express = require('express')
ejs = require('ejs')
connectAssets = require('connect-assets')(src: "#{__dirname}/../..")

app = express()
  .set("views", __dirname)
  .engine('ejs', ejs.__express)
  .use(express.static(__dirname + '/jasmine'))
  .use(connectAssets)

app.get('/', (req, res) ->
  res.render('jasmine/index.html.ejs'))

app.listen(8888)
console.log("Spec server listening on port 8888")
