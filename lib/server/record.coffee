defaultRepository = require "./default_repository"

module.exports = (Record) ->

  Record.reopen ->
    @repository = ->
      defaultRepository

    @transaction = (callback) ->
      repository = @repository()
      repository.connection.begin (err, tx) ->
        classes = repository.clone(tx).recordClasses() unless err
        callback(err, classes)

    @commit = (callback) ->
      @repository().connection.commit(callback)

    @rollBack = (callback) ->
      @repository().connection.rollBack(callback)

    for methodName in ['deleteAll', 'create']
      do (methodName) =>
        this[methodName] = ->
          @table[methodName].apply(@table, arguments)

    save: ->
      if @isPersisted()
        singletonRelation(this).updateAll(@fieldValues(), arguments...)
      else
        @constructor.table.create(@fieldValues(), arguments...)

    destroy: ->
      if @isPersisted()
        singletonRelation(this).deleteAll(arguments...)

    isPersisted: ->
      @id()?

singletonRelation = (record) ->
  record.constructor.table.where(id: record.id())
