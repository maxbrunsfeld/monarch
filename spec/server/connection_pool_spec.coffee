{ root, _, databaseConfig } = require "./spec_helper"
ConnectionPool = require "#{root}/connection_pool"

describe "ConnectionPool", ->
  connectionPool = null

  beforeEach ->
    connectionPool = new ConnectionPool

  describe "#query", ->
    describe "when the connection is not configured", ->
      it "calls the callback with an error indicating the missing options", (done) ->
        connectionPool.query 'select 1', (err, result) ->
          expect(err.message).toMatch(/Missing.*host.*port/)
          done()

    describe "when connecting to the database fails", ->
      beforeEach ->
        connectionPool.configure(
          _.extend({}, databaseConfig, user: 'totally-wrong'))

      it "calls the callback with a connection error", (done) ->
        connectionPool.query 'select 1', (err, result) ->
          expect(err.message).toMatch(/role.*does not exist/)
          done()

    describe "when connecting to the database succeeds", ->
      beforeEach ->
        connectionPool.configure(databaseConfig)

      describe "when the query fails", ->
        it "calls the callback with the error", (done) ->
          connectionPool.query 'nonsense', (err, result) ->
            expect(err.message).toMatch(/syntax.*error.*nonsense/)
            done()

      describe "when the query succeeds", ->
        it "calls the callback with the error", (done) ->
          connectionPool.query 'select 1 as "one"', (err, result) ->
            expect(err).toBeNull()
            expect(result.rows).toEqual([{one: 1}])
            done()

  describe "#begin", ->
    beforeEach (done) ->
      connectionPool.configure(databaseConfig)
      connectionPool.query('DELETE FROM "blogs"', done)

    describe "when a connection is successfully established", ->
      it "calls the callback with a database connection retrieved from the pool", (done) ->
        connectionPool.begin (err, transaction) ->
          transaction.query 'select 1 as "one"', (err, result) ->
            expect(result.rows).toEqual([{one: 1}])
            transaction.end()
            done()

    describe "when there is a connection error", ->
      beforeEach ->
        connectionPool.configure(
          _.extend({}, databaseConfig, user: 'totally-wrong'))

      it "calls the callback the error", (done) ->
        connectionPool.begin (err, transaction) ->
          expect(transaction).toBeUndefined()
          expect(err.message).toMatch(/role.*does not exist/)
          done()

    describe "Transaction#query", ->
      transaction = null

      beforeEach (done) ->
        connectionPool.begin (err, tx) ->
          transaction = tx
          transaction.query("""
            INSERT INTO "blogs"
              ("title")
            VALUES
              ('In transaction');
          """, done)

      it "makes changes that are visible within the transaction", (done) ->
        transaction.query 'SELECT * FROM "blogs"', (err, result) ->

          expect(result.rows.length).toBe(1)
          expect(result.rows[0].title).toBe('In transaction')
          transaction.end()
          done()

      it "makes changes that aren't visible to other connections in the pool", (done) ->
        connectionPool.query 'SELECT * FROM "blogs"', (err, result) ->
          expect(result.rows).toEqual([])
          transaction.end()
          done()

      describe "Transaction#commit", ->
        beforeEach (done) ->
          transaction.commit(done)

        it "commits the changes made in the transaction", (done) ->
          connectionPool.query 'SELECT * FROM "blogs"', (err, result) ->
            expect(result.rows.length).toBe(1)
            expect(result.rows[0].title).toBe('In transaction')
            done()

      describe "Transaction#rollback", ->
        beforeEach (done) ->
          transaction.rollBack(done)

        it "rolls back the changes made in the transaction", (done) ->
          connectionPool.query 'SELECT * FROM "blogs"', (err, result) ->
            expect(result.rows).toEqual([])
            done()
