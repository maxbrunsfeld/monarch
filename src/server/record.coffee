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

    save: (callback) ->
      if @isPersisted()
        singletonRelation(this).updateAll(@fieldValues(), callback)
      else
        self = this
        @constructor.table.create(@fieldValues(), (err, _, rows) ->
          self.id(rows[0].id) unless err
          callback.apply(this, arguments))

    destroy: ->
      if @isPersisted()
        singletonRelation(this).deleteAll(arguments...)

    isPersisted: ->
      @id()?

    reload: (callback) ->
      throw "Can't reload unpersisted record" unless @isPersisted()
      singletonRelation(this).first (err, record) =>
        @localUpdate(record.fieldValues())
        callback()

singletonRelation = (record) ->
  record.constructor.table.where(id: record.id())
