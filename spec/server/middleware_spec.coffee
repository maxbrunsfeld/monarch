{ root, Monarch, _, FakeResponse } = require "./spec_helper"
{ Relations, Record } = Monarch
{ Relation, Table } = Relations
Sandbox = require "#{root}/sandbox"
middleware = require "#{root}/middleware"

describe "middleware", ->
  [req, res, route, Blog, BlogPost] = []

  beforeEach ->
    class Blog extends Monarch.Record
      @extended(this)
      @columns
        title: 'string'
        public: 'boolean'
    class BlogPost extends Monarch.Record
      @extended(this)
      @columns
        title: 'string'
        public: 'boolean'

    req = { method: 'GET', headers: {} }
    res = new FakeResponse

    route = middleware({
      sessionKey: 'db',
      sandboxUrl: '/sandbox'
      sandbox: new Sandbox ({ Blog }) ->
        { Blog: Blog.where(public: true) }
    })

  describe "when not making a request to the sandbox", ->
    beforeEach ->
      req.url = '/not-sandbox'

    it "adds the monarch record classes to the request", (done) ->
      route req, res, ->
        { Blog, BlogPost } = req.db
        expect(new Blog).toBeA(Monarch.Record)
        expect(new BlogPost).toBeA(Monarch.Record)
        done()

    it "uses the key 'monarch' by default", (done) ->
      route = middleware()
      route req, res, ->
        { Blog, BlogPost } = req.monarch
        expect(new Blog).toBeA(Monarch.Record)
        expect(new BlogPost).toBeA(Monarch.Record)
        done()

    it "creates clones of the record classes with their own repository", (done) ->
      Repository = require "#{root}/repository"
      defaultRepository = require "#{root}/default_repository"

      route req, res, ->
        { Blog } = req.db
        repository = Blog.repository()
        expect(repository).toBeA(Repository)
        expect(repository).not.toBe(defaultRepository)
        expect(repository.connection).toBe(defaultRepository.connection)
        done()

  describe "when making a request to the sandbox", ->
    [records, err, next] = []

    beforeEach ->
      _.extend req,
        url: '/sandbox'
        query: {
          relations: JSON.stringify([
            Blog.limit(5).wireRepresentation()
          ])
        }

      next = jasmine.createSpy('next')
      spyOn(Relation.prototype, "all").andCallFake((fn) -> fn(err, records))

    describe "when fetching a single relation", ->
      it "does not call the next layer in the middleware stack", ->
        route(req, res, next)
        expect(next).not.toHaveBeenCalled()

      it "constructs the relation based on the given table definitions", ->
        records = []
        route(req, res)
        query = Relation.prototype.all
        expect(query.calls.length).toBe(1)
        expect(query.calls[0].object.isEqual(
          Blog.where(public: true).limit(5))
        ).toBeTruthy()

      describe "when the relation contains records", ->
        beforeEach ->
          records = [
            new Blog(title: 'blog1')
            new Blog(title: 'blog2')
          ]

        it "responds with the records as JSON", ->
          route(req, res)
          expect(JSON.parse(res.body)).toEqual({
            blogs: [
              { title: 'blog1' }
              { title: 'blog2' }
            ]
          })

      describe "when the relation contains no records", ->
        beforeEach ->
          err = null
          records = []

        it "responds with empty JSON", ->
          route(req, res)
          expect(JSON.parse(res.body)).toEqual({})

      describe "when an error occurs while fetching the relation", ->
        beforeEach ->
          err = { message: '' }
          records = null

        it "responds with an error", ->
          route(req, res)
          expect(res.statusCode).toBe(500)

    describe "when creating a record", ->
      [err, results] = []

      beforeEach ->
        _.extend req,
          method: 'POST'
          url: '/sandbox/blog_posts'
          body: {
            fieldValues: {
              title: 'New Post'
              public: true
            }
          }

        err = null
        results = [{}]
        spyOn(Table.prototype, "create").andCallFake((json, fn) ->
          fn(err, null, results))

      it "creates the record", ->
        route(req, res, next)
        create = Table.prototype.create
        expect(create.calls.length).toBe(1)
        expect(create.calls[0].object.isEqual(BlogPost.table)).toBeTruthy()
        expect(create.calls[0].args[0]).toEqual({
          title: 'New Post'
          public: true
        })

      describe "when the table does not exist", ->
        it "responds with a 'not found'", ->
          req.url = '/sandbox/non_existent_things'
          route(req, res, next)
          expect(res.statusCode).toBe(404)

      describe "when the record is created successfully", ->
        it "responds with the record's final attributes", ->
          results = [{ title: 'New Post', public: true, id: 57 }]
          route(req, res, next)
          expect(JSON.parse(res.body)).toEqual(results[0])
