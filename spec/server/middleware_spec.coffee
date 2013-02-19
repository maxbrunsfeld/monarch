{ root, Monarch, _, FakeResponse } = require "./spec_helper"
Sandbox = require "#{root}/sandbox"
middleware = require "#{root}/middleware"

describe "middleware", ->
  [req, res, next, route, TestSandbox] = []

  beforeEach ->
    class TestSandbox extends Sandbox

    req = { method: 'GET', headers: {} }
    res = new FakeResponse
    next = jasmine.createSpy('next')

    route = middleware({
      sessionKey: 'db',
      sandboxUrl: '/sandbox'
      sandboxClass: TestSandbox
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
    [err, result] = []

    beforeEach ->
      [err, result] = [null, {}]
      _.each ["fetch", "create", "update", "delete"], (methodName) ->
        spyOn(TestSandbox.prototype, methodName).andCallFake ->
          _.last(arguments).call(this, err, result)

    itStopsTheRequest = ->
      it "does not call the next layer in the middleware stack", ->
        route(req, res, next)
        expect(next).not.toHaveBeenCalled()

    itHandlesSuccess = ->
      describe "when the operation succeeds", ->
        beforeEach ->
          err = null
          result = { blogs: { 5: { title: "dude" } } }

        it "responds with the result", ->
          route(req, res, next)
          expect(res.statusCode).toBe(200)
          expect(res.body).toBe(JSON.stringify(result))

    itHandlesErrors = ->
      describe "when an error occurs", ->
        beforeEach ->
          err = { code: 404, message: "Relation 'sandwiches' not found" }
          result = null

        it "responds with an error", ->
          route(req, res, next)
          expect(res.statusCode).toBe(404)
          expect(res.body).toBe("Relation 'sandwiches' not found")

    describe "when fetching relations", ->
      beforeEach ->
        _.extend req,
          url: '/sandbox'
          query: {
            relations: JSON.stringify([
              Blog.limit(5).wireRepresentation()
            ])
          }

      it "fetches the relations using the sandbox", ->
        route(req, res, next)
        expect(TestSandbox::fetch).toHaveBeenCalled()
        expect(TestSandbox::fetch.calls[0].args[0]).toEqual([
          Blog.limit(5).wireRepresentation()
        ])

      itStopsTheRequest()
      itHandlesSuccess()
      itHandlesErrors()

    describe "when creating a record", ->
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

      it "creates the record using the sandbox", ->
        route(req, res, next)
        expect(TestSandbox::create).toHaveBeenCalled()
        expect(TestSandbox::create.calls[0].args[0]).toBe('blog_posts')
        expect(TestSandbox::create.calls[0].args[1]).toEqual({
          title: 'New Post'
          public: true
        })

      itStopsTheRequest()
      itHandlesSuccess()
      itHandlesErrors()

    describe "when deleting a record", ->
      beforeEach ->
        _.extend req,
          method: 'DELETE'
          url: '/sandbox/blog_posts/17'

      it "deletes the record using the sandbox", ->
        route(req, res, next)
        expect(TestSandbox::delete).toHaveBeenCalled()
        expect(TestSandbox::delete.calls[0].args[0]).toBe('blog_posts')
        expect(TestSandbox::delete.calls[0].args[1]).toBe(17)

      itStopsTheRequest()
      itHandlesSuccess()
      itHandlesErrors()

    describe "when updating a record", ->
      beforeEach ->
        _.extend req,
          method: 'PUT'
          url: '/sandbox/blog_posts/17'
          body: {
            fieldValues: {
              title: 'New Post'
              public: true
            }
          }

      it "updates the record using the sandbox", ->
        route(req, res, next)
        expect(TestSandbox::update).toHaveBeenCalled()
        expect(TestSandbox::update.calls[0].args[0]).toBe('blog_posts')
        expect(TestSandbox::update.calls[0].args[1]).toBe(17)
        expect(TestSandbox::update.calls[0].args[2]).toEqual({
          title: 'New Post'
          public: true
        })

      itStopsTheRequest()
      itHandlesSuccess()
      itHandlesErrors()

