#!/usr/bin/env coffee

express = require('express')
connect = require('connect')
ejs = require('ejs')
connect_assets = require('connect-assets')({
  src: __dirname + "/../.."
})

app = express()
  .set("views", __dirname)
  .engine('ejs', ejs.__express)
  .use(connect.static(__dirname + '/jasmine'))
  .use(connect_assets)

app.get('/', (req, res) ->
  res.render('jasmine/index.html.ejs'))

app.listen(8888)
console.log("Spec server listening on port 8888")
