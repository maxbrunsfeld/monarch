_ = require "underscore"
SqlGenerator = require "../sql/generator"
SelectBuilder = require "../sql/select_builder"
TupleBuilder = require "../tuple_builder"

module.exports = (Relation) ->

  Relation.reopen ->
    transaction: (callback) ->
      repository = @repository()
      repository.connection.begin (err, tx) ->
        classes = repository.clone(tx).recordClasses() unless err
        callback(err, classes)

    readSql: ->
      query = (new SelectBuilder).buildQuery(this)
      (new SqlGenerator).toSql(query)

    all: (f) ->
      [string, literals] = @readSql()
      @connection().query string, literals, (err, result) =>
        return f(err) if err
        f(null, TupleBuilder.visit(this, result.rows))

    at: (index, f) ->
      @offset(index).first(f)

    find: (predicate, f) ->
      predicate = { id: predicate } unless _.isObject(predicate)
      @where(predicate).first(f)

    first: (f) ->
      @limit(1).all (err, results) ->
        f(err, results?[0])

    inRepository: (repository) ->
      @constructor.fromJson(
        @wireRepresentation(),
        repository.tables)

    connection: ->
      @repository().connection
