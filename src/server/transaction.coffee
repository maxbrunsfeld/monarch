class Transaction
  constructor: (@client) ->

  query: (args...) ->
    @client.query(args...)

  rollBack: (callback) ->
    queryAndClose(this, "ROLLBACK", callback)

  commit: (callback) ->
    queryAndClose(this, "COMMIT", callback)

  end: ->
    @client.end()

queryAndClose = (transaction, sql, callback) ->
  transaction.query sql, (err, result) ->
    transaction.end()
    callback(err, result)

module.exports = Transaction
