{ Monarch, async, pg, root } = require "./spec_helper"
defaultRepository = require "#{root}/default_repository"
Repository = require "#{root}/repository"
Transaction = require "#{root}/transaction"

describe "Record", ->
  Blog = null

  beforeEach (done) ->
    defaultRepository.clear()

    class Blog extends Monarch.Record
      @extended(this)
      @columns
        public: 'boolean'
        title: 'string'
        authorId: 'integer'

    Blog.deleteAll ->
      Blog.create [
        { public: true, title: 'Public Blog1', authorId: 1 },
        { public: true, title: 'Public Blog2', authorId: 1 },
      ], done

  describe ".extended(subclass)", ->
    it "associates the subclass with a table in the default repository", ->
      expect(Blog.name).toBe('Blog')
      expect(Blog.table instanceof Monarch.Relations.Table).toBeTruthy()
      expect(Blog.table.name).toBe('Blog')
      expect(Blog.table).toBe(defaultRepository.tables.Blog)

    it "automatically defines an integer-typed id column", ->
      expect(Blog.table.getColumn('id').type).toBe('integer')

  describe ".transaction", ->
    [repository, TransactionBlog] = []

    beforeEach (done) ->
      repository = new Repository(defaultRepository.connection)
      repository.registerTable(Blog.table)
      Blog.transaction (err, { Blog }) ->
        TransactionBlog = Blog
        Blog.create({ title: 'In transaction' }, done)

    it "starts a transaction, passing a set of record classes that use the transaction", (done) ->
      async.parallel([
        (f) ->
          TransactionBlog.find { title: 'In transaction' }, (err, blog) ->
            expect(blog.title()).toBe('In transaction')
            f()
        (f) ->
          Blog.find { title: 'In transaction' }, (err, blog) ->
            expect(blog).toBeUndefined()
            f()
      ], done)

    describe ".commit", ->
      it "commits the transaction", (done) ->
        TransactionBlog.commit ->
          Blog.find { title: 'In transaction' }, (err, blog) ->
            expect(blog.title()).toBe('In transaction')
            done()

    describe ".rollBack", ->
      it "commits the transaction", (done) ->
        TransactionBlog.rollBack ->
          Blog.find { title: 'In transaction' }, (err, blog) ->
            expect(blog).toBeUndefined()
            done()

  describe "#isPersisted", ->
    it "returns true when the record has an id", ->
      blog = new Blog(id: 1, public: false, title: 'New Blog', authorId: 2)
      expect(blog.isPersisted()).toBeTruthy()

    it "returns false when the record does not have an id", ->
      blog = new Blog(id: null, public: false, title: 'New Blog', authorId: 2)
      expect(blog.isPersisted()).toBeFalsy()

  describe "#save", ->
    describe "when the record has not yet been saved", ->
      it "inserts a record", (done) ->
        blog = new Blog(public: false, title: 'New Blog', authorId: 2)
        blog.save (err) ->
          Blog.find { title: 'New Blog' }, (err, record) ->
            expect(record).toEqualRecord(Blog,
              public: false,
              title: 'New Blog',
              authorId: 2
            )
            done()

    describe "when the record has already been saved", ->
      it "updates the record", (done) ->
        Blog.find { title: 'Public Blog1' }, (err, blog) ->
          id = blog.id()
          blog.title('New Blog, version 2')
          blog.save ->
            Blog.find id, (err, updatedBlog) ->
              expect(updatedBlog).toEqualRecord(Blog,
                public: true,
                title: 'New Blog, version 2',
                authorId: 1
              )
              done()

  describe "#destroy", ->
    describe "when the record has not been saved", ->
      it "does not delete any records", (done) ->
        blog = new Blog(id: 2, public: false, title: 'New Blog', authorId: 2)
        blog.destroy (err, result) ->
          Blog.all (err, results) ->
            expect(results.length).toBe(2)
            done()

    describe "when the record has already been saved", ->
      it "deletes the record", (done) ->
        Blog.first (err, blog) ->
          id = blog.id()
          blog.destroy ->
            Blog.find id, (err, blog) ->
              expect(blog).toBeUndefined()
              done()

