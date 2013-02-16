#!/usr/bin/env coffee

env = process.env['MONARCH_TEST_ENV'] || "dev"
root = "#{__dirname}/../.."

config = require "#{root}/spec/server/support/db/#{env}"
{ exec } = require 'child_process'

exec """
  psql postgres -c 'drop database if exists #{config.database};' -U #{config.user}
  psql postgres -c 'create database #{config.database};' -U #{config.user}
""", (err, stdout, stderr) ->
  console.log stdout
  console.error stderr if stderr
