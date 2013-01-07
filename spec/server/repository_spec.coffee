{ Monarch, root } = require "./spec_helper"
Repository = require "#{root}/repository"
ConnectionPool = require "#{root}/connection_pool"
defaultRepository = require "#{root}/default_repository"

describe "Repository", ->
  repository = null

  class Blog extends Monarch.Record
    @extended(this)
    @columns
      public: 'boolean'
      title: 'string'
      authorId: 'integer'

  class BlogPost extends Monarch.Record
    @extended(this)
    @columns
      public: 'boolean'
      title: 'string'
      blogId: 'integer'

  beforeEach ->
    repository = new Repository

  describe "#registerTable", ->
    it "adds the table to the repository's tables hash", ->
      repository.registerTable(Blog.table)
      expect(repository.tables.Blog).toBe(Blog.table)

  describe "#clone", ->
    [clone, connection] = []

    beforeEach ->
      repository.registerTable(Blog.table)
      repository.registerTable(BlogPost.table)
      connection = new ConnectionPool

      clone = repository.clone(connection)

    it "returns a repository", ->
      expect(clone).toBeA(Repository)

    it "uses the given database connection", ->
      expect(clone.connection).toBe(connection)

    it "copies the original repository's tables", ->
      expect(clone.tables.Blog.name).toBe('Blog')
      expect(clone.tables.BlogPost.name).toBe('BlogPost')
      expect(clone.tables.Blog.columnsByName).toEqual(Blog.table.columnsByName)
      expect(clone.tables.BlogPost.columnsByName).toEqual(BlogPost.table.columnsByName)

    it "gives each table a copy of the original table's record class", ->
      Blog2 = clone.tables.Blog.recordClass
      expect(new Blog2).toBeA(Blog)
      expect(new Blog).toBeA(Blog2)
      expect(Blog2.create).toBe(Blog.create)
      expect(Blog2.updateAll).toBe(Blog.updateAll)

    it "gives the record class the correct function name", ->
      Blog2 = clone.tables.Blog.recordClass
      BlogPost2 = clone.tables.BlogPost.recordClass
      expect((new Blog2).toString()).toMatch(/<Blog /)
      expect((new BlogPost2).toString()).toMatch(/<BlogPost /)

    it "makes the clone's tables use the clone as their repository", ->
      expect(clone.tables.Blog.repository()).toBe(clone)
      expect(clone.tables.BlogPost.repository()).toBe(clone)
      expect(clone.tables.Blog.recordClass.repository()).toBe(clone)
      expect(clone.tables.BlogPost.recordClass.repository()).toBe(clone)

    it "does not alter the original repository's tables", ->
      expect(Blog.repository()).toBe(defaultRepository)
      expect(BlogPost.repository()).toBe(defaultRepository)
      expect(Blog.table.repository()).toBe(defaultRepository)
      expect(BlogPost.table.repository()).toBe(defaultRepository)

