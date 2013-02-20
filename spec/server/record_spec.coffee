{ Monarch, async, root } = require "./spec_helper"
Repository = require "#{root}/repository"
Transaction = require "#{root}/transaction"
defaultRepository = require "#{root}/default_repository"

describe "Record", ->
  beforeEach (done) ->
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
      blog = null

      beforeEach ->
        blog = new Blog(public: false, title: 'New Blog', authorId: 2)

      it "inserts a record", (done) ->
        blog.save (err) ->
          Blog.find { title: 'New Blog' }, (err, record) ->
            expect(record).toEqualRecord(Blog,
              public: false,
              title: 'New Blog',
              authorId: 2
            )
            done()

      it "sets the record's id from the database", (done) ->
        blog.save ->
          expect(blog.id()).toBeGreaterThan(1)
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
        Blog.find { title: 'Public Blog1' }, (err, blog) ->
          id = blog.id()
          blog.destroy ->
            Blog.find id, (err, blog) ->
              expect(blog).toBeUndefined()
              done()

  describe "#reload", ->
    record = null

    beforeEach ->
      record = new Blog(public: true, title: 'New Blog', authorId: 5)

    describe "when the record is not persisted", ->
      it "raises an error", ->
        expect(->
          record.reload ->
        ).toThrow("Can't reload unpersisted record")

    describe "when the record is persisted", ->
      beforeEach (done) ->
        record.save ->
          Blog.where(id: record.id()).updateAll { title: 'Updated Blog' }, ->
            done()

      it "updates the record's fields from the database", (done) ->
        expect(record.title()).toBe('New Blog')
        record.reload ->
          expect(record.title()).toBe('Updated Blog')
          done()

  describe ".hasMany", ->
    [blog, post] = []

    beforeEach (done) ->
      Blog.create {id: 1}, ->
        Blog.find 1, (err, record) ->
          blog = record
          done()

      BlogPost.create {id: 1}, ->
        BlogPost.find 1, (err, record) ->
          post = record
          done()

    it "returns the class", ->
      expect(BlogPost.hasMany('comments')).toBe(BlogPost)

    it "defines a hasMany relation", ->
      BlogPost.hasMany('comments')
      expect(post.comments()).toEqual(Comment.where(blogPostId: 1))

    it "supports a 'className' option", ->
      class PostComment extends Monarch.Record
        @extended(this)
        @columns(blogPostId: 'integer')

      BlogPost.hasMany('comments', className: 'PostComment')

      expect(post.comments()).toEqual(PostComment.where(blogPostId: 1))

    it "supports a 'foreignKey' option", ->
      class Comment extends Monarch.Record
        @extended(this)
        @columns(postId: 'integer')

      BlogPost.hasMany('comments', foreignKey: 'postId')

      expect(post.comments()).toEqual(Comment.where(postId: 1))

    it "supports an 'orderBy' option", ->
      class Comment extends Monarch.Record
        @extended(this)
        @columns
          blogPostId: 'integer'
          body: 'string'
          createdAt: 'datetime'

      BlogPost.hasMany('comments', orderBy: 'body desc')
      post1 = new BlogPost(id: 1)
      expect(post1.comments()).toEqual(
        Comment.where({blogPostId: 1}).orderBy('body desc'))

      post2 = new BlogPost(id: 2)
      BlogPost.hasMany('comments', orderBy: ['body desc', 'createdAt'])
      expect(post2.comments()).toEqual(
        Comment.where({blogPostId: 2}).orderBy('body desc', 'createdAt'))

    it "supports a 'conditions' option", ->
      class Comment extends Monarch.Record
        @extended(this)
        @columns(blogPostId: 'integer', public: 'boolean', score: 'integer')

      BlogPost.hasMany('comments', conditions: { public: true, 'score >': 3 })
      expect(post.comments()).toEqual(
        Comment.where({ public: true, 'score >': 3, blogPostId: 1 }))

    it "supports a 'through' option", ->
      Blog
        .hasMany('posts', className: 'BlogPost')
        .hasMany('comments', through: 'posts')

      BlogPost.columns(blogId: 'integer')
      expect(blog.comments()).toEqual(blog.posts().joinThrough(Comment))

  describe ".relatesTo(name, definition)", ->
    it "defines a method that returns a memoized relation", ->
      class Comment extends Monarch.Record
        @extended(this)
        @columns(postId: 'integer', public: 'boolean')

      BlogPost.relatesTo 'comments', ->
        Comment.where(postId: this.id())

      BlogPost.relatesTo 'publicComments', ->
        Comment.where(postId: this.id(), public: true)

      post = new BlogPost(id: 1)

      expect(post.comments()).toEqual(Comment.where({postId: 1}))
      expect(post.comments()).toBe(post.comments()) # memoized

      expect(post.comments()).not.toBe(post.publicComments())

  describe ".belongsTo(name, options)", ->
    [blogId, blog] = []

    beforeEach (done) ->
      blogId = 5
      Blog.create { id: blogId, title: "The Blog" }, ->
        Blog.find blogId, (err, result) ->
          blog = result
          done()

    it "returns the class", ->
      expect(Blog.belongsTo('user')).toBe(Blog)

    it "sets up a belongs to relationship", (done) ->
      BlogPost.belongsTo('blog')

      post = new BlogPost(blogId: blogId)
      post.blog (err, postBlog) ->
        expect(postBlog.isEqual(blog)).toBeTruthy()
        done()

    it "supports 'className' and 'foreignKey' options", (done) ->
      BlogPost.belongsTo("theBlog", className: "Blog", foreignKey: "blogId")

      post = new BlogPost(blogId: blogId)
      post.theBlog (err, postBlog) ->
        expect(postBlog.isEqual(blog)).toBeTruthy()
        done()
