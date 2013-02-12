{ Monarch, root, _, recordClasses } = require "./spec_helper"
Repository = require "#{root}/repository"
ConnectionPool = require "#{root}/connection_pool"
{ Blog, BlogPost } = recordClasses

describe "Repository", ->
  repository = null

  beforeEach ->
    repository = new Repository

  describe "#registerTable", ->
    it "adds the table to the repository's tables hash", ->
      repository.registerTable(Blog.table)
      expect(repository.tables.Blog).toBe(Blog.table)

    it "makes the repository the table's repository", ->
      repository.registerTable(Blog.table)
      expect(Blog.repository()).toBe(repository)
      expect(Blog.table.repository()).toBe(repository)

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
      expect(clone.tables.Blog).toBeA(Monarch.Relations.Table)
      expect(clone.tables.Blog.name).toBe('Blog')
      expect(clone.tables.Blog.columnsByName).toEqual(Blog.table.columnsByName)
      expect(clone.tables.BlogPost).toBeA(Monarch.Relations.Table)
      expect(clone.tables.BlogPost.name).toBe('BlogPost')
      expect(clone.tables.BlogPost.columnsByName).toEqual(BlogPost.table.columnsByName)

    it "gives each table a copy of the original table's record class", ->
      Blog2 = clone.tables.Blog.recordClass
      expect(Blog2).not.toBe(Blog)
      blog2 = new Blog2
      expect(blog2).toBeA(Blog2)
      expect(blog2.constructor).toBe(Blog2)
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
      expect(Blog.repository()).toBe(repository)
      expect(BlogPost.repository()).toBe(repository)
      expect(Blog.table.repository()).toBe(repository)
      expect(BlogPost.table.repository()).toBe(repository)

