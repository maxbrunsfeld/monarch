Repository = require "./repository"
ConnectionPool = require "./connection_pool"
module.exports = new Repository(new ConnectionPool)
