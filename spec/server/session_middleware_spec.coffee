{ root, Monarch, _ } = require "./spec_helper"
middleware = require "#{root}/session_middleware"

describe "session middleware", ->
  [req, res, Blog, BlogPost] = []

  beforeEach ->
    req = {}
    res = {}
    class Blog extends Monarch.Record
      @extended(this)
    class BlogPost extends Monarch.Record
      @extended(this)

  it "adds the monarch record classes to the request", (done) ->
    middleware() req, res, ->
      { Blog, BlogPost } = req.monarch
      expect(new Blog).toBeA(Monarch.Record)
      expect(new BlogPost).toBeA(Monarch.Record)
      done()

  it "will use a key other than 'monarch', based on the 'key' option", (done) ->
    middleware(key: 'records') req, res, ->
      { Blog, BlogPost } = req.records
      expect(new Blog).toBeA(Monarch.Record)
      expect(new BlogPost).toBeA(Monarch.Record)
      done()

  it "creates clones of the record classes with their own repository", (done) ->
    Repository = require "#{root}/repository"
    defaultRepository = require "#{root}/default_repository"

    middleware() req, res, ->
      { Blog } = req.monarch
      repository = Blog.repository()
      expect(repository).toBeA(Repository)
      expect(repository).not.toBe(defaultRepository)
      expect(repository.connection).toBe(defaultRepository.connection)
      done()
