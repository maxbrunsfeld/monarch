{ root, Monarch, _, async } = require "./spec_helper"
Sandbox = require "#{root}/sandbox"
{ Relations, Record } = Monarch

describe "Sandbox", ->
  sandbox = null

  beforeEach (done) ->
    async.series([
      (f) -> async.parallel([
        (f) -> Blog.deleteAll(f)
        (f) -> BlogPost.deleteAll(f)
        (f) -> Comment.deleteAll(f)
      ], f),
      (f) -> async.parallel([
        (f) -> Blog.create([
          { authorId: 1, id: 11, title: "My Blog", public: true }
          { authorId: 2, id: 12, title: "Not My Blog", public: true }
        ], f),
        (f) -> BlogPost.create([
          { blogId: 11, id: 21, title: "My Post 1", public: true }
          { blogId: 11, id: 22, title: "My Post 2", public: false }
          { blogId: 12, id: 23, title: "Not My Post", public: true }
        ], f)
        (f) -> Comment.create([
          { blogPostId: 21, id: 31, body: "My Comment 1", authorId: 5 }
          { blogPostId: 21, id: 32, body: "My Comment 2", authorId: 5 }
          { blogPostId: 22, id: 33, body: "My Comment 3", authorId: 5 }
          { blogPostId: 29, id: 34, body: "Not My Comment", authorId: 5 }
        ], f)
      ], f)
    ], done)

  beforeEach ->
    class TestSandbox extends Sandbox
      @expose 'blogs', ({ Blog }) ->
        Blog.where(authorId: 1)

      @expose 'blogPosts', ({ BlogPost }) ->
        @blogs().joinThrough(BlogPost)

      @expose 'comments', ({ Comment }) ->
        @blogPosts().joinThrough(Comment)

    sandbox = new TestSandbox({ Blog, BlogPost, Comment })

  describe "#fetch", ->
    describe "for empty relations", ->
      it "passes an empty dataset", (done) ->
        json = [Blog.where(title: 'Non-existent').wireRepresentation()]
        sandbox.fetch json, (err, dataset) ->
          expect(dataset).toEqual({})
          done()

    describe "for relations containing records", ->
      it "passes a dataset containing the given records", (done) ->
        json = [Blog.wireRepresentation(), Comment.wireRepresentation()]
        sandbox.fetch json, (err, dataset) ->
          expect(_.keys(dataset)).toEqual(['blogs', 'comments'])
          expect(dataset.blogs).toEqual({
            11: { authorId: 1, id: 11, title: "My Blog", public: true }
          })
          expect(dataset.comments).toEqual({
            31: { blogPostId: 21, id: 31, body: "My Comment 1", authorId: 5 }
            32: { blogPostId: 21, id: 32, body: "My Comment 2", authorId: 5 }
            33: { blogPostId: 22, id: 33, body: "My Comment 3", authorId: 5 }
          })
          done()

    describe "for relations containing composite tuples", ->
      it "passes a dataset with the tuples decomposed into their component records", (done) ->
        json = [BlogPost.where(public: true).join(Comment).wireRepresentation()]
        sandbox.fetch json, (err, dataset) ->
          expect(_.keys(dataset)).toEqual(['blog_posts', 'comments'])
          expect(dataset['blog_posts']).toEqual({
            21: { blogId: 11, id: 21, title: "My Post 1", public: true }
          })
          expect(dataset['comments']).toEqual({
            31: { blogPostId: 21, id: 31, body: "My Comment 1", authorId: 5 }
            32: { blogPostId: 21, id: 32, body: "My Comment 2", authorId: 5 }
          })
          done()

  describe "#create", ->
    describe "when the given table name doesn't exist", ->
      it "passes an error", (done) ->
        sandbox.create 'cats', { name: 'My New Cat' }, (err, result) ->
          expect(result).toBeUndefined()
          expect(err.code).toBe(404)
          expect(err.message).toBe("Relation 'cats' not found")
          done()

    describe "when the created record ends up being in the exposed relation", ->
      it "saves the record", (done) ->
        sandbox.create 'blogs', { authorId: 1, title: 'My New Blog' }, (err, result) ->
          Blog.find { title: 'My New Blog' }, (err, blog) ->
            expect(blog).toEqualRecord(Blog, { authorId: 1 })
            done()

      it "passes the created record's wire representation", (done) ->
        sandbox.create 'blogs', { authorId: 1, title: 'My New Blog' }, (err, result) ->
          expect(result.id).toBeGreaterThan(0)
          expect(_.omit(result, 'id')).toEqual({
            authorId: 1,
            title: 'My New Blog',
            public: null
          })
          done()

    describe "when the created record doesn't end up being in the exposed relation", ->
      it "does not save the record", (done) ->
        sandbox.create 'blogs', { authorId: 2, title: 'My New Blog' }, (err, result) ->
          Blog.find { title: 'My New Blog' }, (err, blog) ->
            expect(blog).toBeUndefined()
            done()

      it "passes an error", (done) ->
        sandbox.create 'blogs', { authorId: 2, title: 'My New Blog' }, (err, result) ->
          expect(result).toBeUndefined()
          expect(err.code).toBe(404)
          expect(err.message).toBe("Record not found")
          done()

  describe "#delete", ->
    describe "when the given table name doesn't exist", ->
      it "passes an error", (done) ->
        sandbox.delete 'cats', 1, (err, result) ->
          expect(result).toBeUndefined()
          expect(err.code).toBe(404)
          expect(err.message).toBe("Relation 'cats' not found")
          done()

    describe "when the specified record is in the exposed relation", ->
      it "deletes the record", (done) ->
        sandbox.delete 'blog_posts', 22, (err, result) ->
          BlogPost.find 22, (err, blogPost) ->
            expect(blogPost).toBeUndefined()
            done()

    describe "when the specified record is not in the exposed relation", ->
      it "does not delete the record", (done) ->
        sandbox.delete 'blog_posts', 23, (err, result) ->
          BlogPost.find 23, (err, blogPost) ->
            expect(blogPost).toBeA(BlogPost)
            done()

      it "passes an error", (done) ->
        sandbox.delete 'blog_posts', 23, (err, result) ->
          expect(result).toBeUndefined()
          expect(err.code).toBe(404)
          expect(err.message).toBe("Record not found")
          done()

  describe "#update", ->
    describe "when the given table name doesn't exist", ->
      it "passes an error", (done) ->
        sandbox.update 'cats', 7, { name: "timothy" }, (err, result) ->
          expect(result).toBeUndefined()
          expect(err.code).toBe(404)
          expect(err.message).toBe("Relation 'cats' not found")
          done()

    describe "when the specified record in not in the exposed relation", ->
      it "does not change the record", (done) ->
        sandbox.update 'blog_posts', 23, { title: "New title" }, (err, result) ->
          BlogPost.find 23, (err, blogPost) ->
            expect(blogPost.title()).toBe("Not My Post")
            done()

      describe "when the update brings it into the exposed relation", ->
        it "does not change the record", (done) ->
          sandbox.update 'blog_posts', 23, { blogId: 11, title: "New title" }, (err, result) ->
            BlogPost.find 23, (err, blogPost) ->
              expect(blogPost.title()).toBe("Not My Post")
              done()

      it "passes an error", (done) ->
        sandbox.update 'blog_posts', 23, { title: "New title" }, (err, result) ->
          expect(result).toBeUndefined()
          expect(err.code).toBe(404)
          expect(err.message).toBe("Record not found")
          done()

    describe "when the specified record is in the exposed relation", ->
      describe "and it is still in the exposed relation after the update", ->
        it "updates the record", (done) ->
          sandbox.update 'blog_posts', 22, { title: "New title" }, (err, result) ->
            BlogPost.find 22, (err, blogPost) ->
              expect(blogPost.title()).toBe("New title")
              done()

      describe "and it is no longer in the exposed relation after the update", ->
        it "does not update the record", (done) ->
          sandbox.update 'blog_posts', 22, { blogId: 999 }, (err, result) ->
            BlogPost.find 22, (err, blogPost) ->
              expect(blogPost.blogId()).toBe(11)
              done()
