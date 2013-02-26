{ Monarch, async, _, fixtureData } = require "../spec_helper"
{ Relation } = Monarch.Relations

describe "Relation", ->
  [blogs, blogPosts, comments] = []

  beforeEach (done) ->
    blogs = Blog.table
    blogPosts = BlogPost.table
    comments = Comment.table

    async.series([
      (f) -> Blog.table.deleteAll(f),
      (f) -> BlogPost.table.deleteAll(f),
      (f) -> Comment.table.deleteAll(f),
      (f) -> Blog.table.create([
        { id: 1, public: true, title: 'Public Blog1', authorId: 1 }
        { id: 2, public: true, title: 'Public Blog2', authorId: 1 }
        { id: 3, public: false, title: 'Private Blog1', authorId: 1 }
      ], f),
      (f) -> BlogPost.table.create([
        { id: 1, public: true, title: 'Public Post1', blogId: 1 }
        { id: 2, public: true, title: 'Public Post2', blogId: 2 }
        { id: 3, public: false, title: 'Private Post1', blogId: 1 }
        { id: 4, public: false, title: 'Private Post2', blogId: 2 }
      ], f),
      (f) -> Comment.table.create([
        { id: 1, body: 'Comment1', blogPostId: 1, authorId: 1, parentId: null }
        { id: 2, body: 'Comment2', blogPostId: 1, authorId: 1, parentId: 1 }
        { id: 3, body: 'Comment3', blogPostId: 2, authorId: 1, parentId: 1 }
        { id: 4, body: 'Comment4', blogPostId: 2, authorId: 1, parentId: 2 }
      ], f),
    ], done)

  describe ".fromJson", ->
    tables = null

    beforeEach ->
      tables = {
        Blog: Blog.table,
        BlogPost: BlogPost.table,
        Comment: Comment.table
      }

    checkJsonParsing = (relation) ->
      json = relation.wireRepresentation()
      expect(Relation.fromJson(json, tables)).toEqual(relation)

    it "works for tables", ->
      checkJsonParsing Blog.table

    it "works for selections", ->
      checkJsonParsing Blog.table.where(public: true)

    it "works for joins", ->
      checkJsonParsing Blog.table.join(BlogPost.table)
      checkJsonParsing Blog.table.join(BlogPost.table).join(Comment.table)

    it "works for projections", ->
      checkJsonParsing Blog.table.joinThrough(BlogPost.table)

    it "works for limits and offsets", ->
      checkJsonParsing Blog.table.limit(10)
      checkJsonParsing Blog.table.offset(10)
      checkJsonParsing Blog.table.limit(10, 2)

    it "works for unions and differences", ->
      checkJsonParsing Blog.where(authorId: 5).union(Blog.where(public: true))
      checkJsonParsing Blog.where(authorId: 5).difference(Blog.where(public: true))

    it "works when given record classes instead of tables", ->
      tables = { Blog, BlogPost, Comment }
      checkJsonParsing Blog.table

  describe ".inRepository", ->
    it "makes a clone of the relation that uses the given repository", ->
      relation = Blog.where(public: true).join(BlogPost.where(public: false))
      newRepository = relation.repository().clone()
      newRelation = relation.inRepository(newRepository)
      expect(newRelation.isEqual(relation)).toBeTruthy()
      expect(newRelation.repository()).toBe(newRepository)

  describe "#all", ->
    describe "tables", ->
      it "builds the table's record class", (done) ->
        blogPosts.all (err, records) ->
          expect(records).toEqualRecords(BlogPost, [
            { id: 1, public: true, title: 'Public Post1', blogId: 1 }
            { id: 2, public: true, title: 'Public Post2', blogId: 2 }
            { id: 3, public: false, title: 'Private Post1', blogId: 1 }
            { id: 4, public: false, title: 'Private Post2', blogId: 2 }
          ])
          done()

    describe "selections", ->
      it "builds the right record class", (done) ->
        blogPosts.where(public: true).all (err, records) ->
          expect(records).toEqualRecords(BlogPost, [
            { id: 1, public: true, title: 'Public Post1', blogId: 1 }
            { id: 2, public: true, title: 'Public Post2', blogId: 2 }
          ])
          done()

    describe "orderings", ->
      describe "on a table", ->
        it "builds the right record class", (done) ->
          blogPosts.orderBy('id desc').all (err, records) ->
            expect(records).toEqualRecords(BlogPost, [
              { id: 4, public: false, title: 'Private Post2', blogId: 2 }
              { id: 3, public: false, title: 'Private Post1', blogId: 1 }
              { id: 2, public: true, title: 'Public Post2', blogId: 2 }
              { id: 1, public: true, title: 'Public Post1', blogId: 1 }
            ])
            done()

      describe "on a limit", ->
        it "adds the correct order by clause", (done) ->
          blogPosts.limit(2).orderBy('id desc').all (err, records) ->
            expect(records).toEqualRecords(BlogPost, [
              { id: 2, public: true, title: 'Public Post2', blogId: 2 }
              { id: 1, public: true, title: 'Public Post1', blogId: 1 }
            ])
            done()

    describe "limits", ->
      it "builds the right record class", (done) ->
        blogs.limit(2).all (err, records) ->
          expect(records).toEqualRecords(Blog, [
            { id: 1, public: true, title: 'Public Blog1', authorId: 1 }
            { id: 2, public: true, title: 'Public Blog2', authorId: 1 }
          ])
          done()

    describe "offsets", ->
      it "builds the right record class", (done) ->
        blogPosts.offset(2).all (err, records) ->
          expect(records).toEqualRecords(BlogPost, [
            { id: 3, public: false, title: 'Private Post1', blogId: 1 }
            { id: 4, public: false, title: 'Private Post2', blogId: 2 }
          ])
          done()

    describe "joins", ->
      describe "between two tables", ->
        it "builds composite tuples with the correct left and right records", (done) ->
          blogs.join(blogPosts).all (err, tuples) ->
            sortedTuples = _.sortBy tuples, (t) -> [t.left.id(), t.right.id()]
            expect(sortedTuples).toEqualCompositeTuples(
              Blog, [
                { id: 1, public: true, title: 'Public Blog1', authorId: 1 }
                { id: 1, public: true, title: 'Public Blog1', authorId: 1 }
                { id: 2, public: true, title: 'Public Blog2', authorId: 1 }
                { id: 2, public: true, title: 'Public Blog2', authorId: 1 }
              ],
              BlogPost, [
                { id: 1, public: true, title: 'Public Post1', blogId: 1 }
                { id: 3, public: false, title: 'Private Post1', blogId: 1 }
                { id: 2, public: true, title: 'Public Post2', blogId: 2 }
                { id: 4, public: false, title: 'Private Post2', blogId: 2 }
              ])
            done()

      describe "between a limit and a table", ->
        it "builds composite tuples with the correct left and right records", (done) ->
          blogs.limit(1).join(blogPosts).all (err, tuples) ->
            expect(tuples).toEqualCompositeTuples(
              Blog, [
                { id: 1, public: true, title: 'Public Blog1', authorId: 1 }
                { id: 1, public: true, title: 'Public Blog1', authorId: 1 }
              ],
              BlogPost, [
                { id: 1, public: true, title: 'Public Post1', blogId: 1 }
                { id: 3, public: false, title: 'Private Post1', blogId: 1 }
              ])
            done()

      describe "between a selection and a table", ->
        it "builds composite tuples with the correct left and right records", (done) ->
          blogs.where(title: 'Public Blog1').join(blogPosts).all (err, tuples) ->
            expect(tuples).toEqualCompositeTuples(
              Blog, [
                { id: 1, public: true, title: 'Public Blog1', authorId: 1 }
                { id: 1, public: true, title: 'Public Blog1', authorId: 1 }
              ],
              BlogPost, [
                { id: 1, public: true, title: 'Public Post1', blogId: 1 }
                { id: 3, public: false, title: 'Private Post1', blogId: 1 }
              ])
            done()

      describe "with three tables, grouped left-associatively", ->
        it "builds composite tuples with the correct left and right records", (done) ->
          blogs.join(blogPosts).join(comments).all (err, tuples) ->
            sortedTuples = _.sortBy tuples, (t) -> [t.left.left.id(), t.left.right.id()]
            leftTuples = (t.left for t in sortedTuples)
            rightTuples = (t.right for t in sortedTuples)

            expect(leftTuples).toEqualCompositeTuples(
              Blog, [
                { id: 1, public: true, title: 'Public Blog1', authorId: 1 }
                { id: 1, public: true, title: 'Public Blog1', authorId: 1 }
                { id: 2, public: true, title: 'Public Blog2', authorId: 1 }
                { id: 2, public: true, title: 'Public Blog2', authorId: 1 }
              ],
              BlogPost, [
                { id: 1, public: true, title: 'Public Post1', blogId: 1 }
                { id: 1, public: true, title: 'Public Post1', blogId: 1 }
                { id: 2, public: true, title: 'Public Post2', blogId: 2 }
                { id: 2, public: true, title: 'Public Post2', blogId: 2 }
              ])
            expect(rightTuples).toEqualRecords(
              Comment, [
                { id: 1, body: 'Comment1', blogPostId: 1, authorId: 1 }
                { id: 2, body: 'Comment2', blogPostId: 1, authorId: 1 }
                { id: 3, body: 'Comment3', blogPostId: 2, authorId: 1 }
                { id: 4, body: 'Comment4', blogPostId: 2, authorId: 1 }
              ])
            done()

      describe "with three tables, grouped right-associatively", ->
        it "builds composite tuples with the correct left and right records", (done) ->
          blogs.join(blogPosts.join(comments)).all (err, tuples) ->
            sortedTuples = _.sortBy tuples, (t) -> [t.left.id(), t.right.left.id()]
            leftTuples = (t.left for t in sortedTuples)
            rightTuples = (t.right for t in sortedTuples)

            expect(leftTuples).toEqualRecords(
              Blog, [
                { id: 1, public: true, title: 'Public Blog1', authorId: 1 }
                { id: 1, public: true, title: 'Public Blog1', authorId: 1 }
                { id: 2, public: true, title: 'Public Blog2', authorId: 1 }
                { id: 2, public: true, title: 'Public Blog2', authorId: 1 }
              ])
            expect(rightTuples).toEqualCompositeTuples(
              BlogPost, [
                { id: 1, public: true, title: 'Public Post1', blogId: 1 }
                { id: 1, public: true, title: 'Public Post1', blogId: 1 }
                { id: 2, public: true, title: 'Public Post2', blogId: 2 }
                { id: 2, public: true, title: 'Public Post2', blogId: 2 }
              ],
              Comment, [
                { id: 1, body: 'Comment1', blogPostId: 1, authorId: 1 }
                { id: 2, body: 'Comment2', blogPostId: 1, authorId: 1 }
                { id: 3, body: 'Comment3', blogPostId: 2, authorId: 1 }
                { id: 4, body: 'Comment4', blogPostId: 2, authorId: 1 }
              ])
            done()

      describe "with the same table occurring twice", ->
        it "builds composite tuples with the correct left and right records", (done) ->
          childComments = comments.alias()
          relation = comments.join(childComments,
            childComments.getColumn('parentId').eq(comments.getColumn('id')))

          relation.all (err, tuples) ->
            sortedTuples = _.sortBy tuples, (t) -> [t.left.id(), t.right.id()]
            leftTuples = (t.left for t in sortedTuples)
            rightTuples = (t.right for t in sortedTuples)

            expect(leftTuples).toEqualRecords(
              Comment, [
                { id: 1, body: 'Comment1', blogPostId: 1, authorId: 1, parentId: null }
                { id: 1, body: 'Comment1', blogPostId: 1, authorId: 1, parentId: null }
                { id: 2, body: 'Comment2', blogPostId: 1, authorId: 1, parentId: 1 }
              ])
            expect(rightTuples).toEqualRecords(
              Comment, [
                { id: 2, body: 'Comment2', blogPostId: 1, authorId: 1, parentId: 1 }
                { id: 3, body: 'Comment3', blogPostId: 2, authorId: 1, parentId: 1 }
                { id: 4, body: 'Comment4', blogPostId: 2, authorId: 1, parentId: 2 }
              ])
            done()

      describe "with the same table occurring thrice", ->
        it "builds correctly nested composite tuples", (done) ->
          childComments = comments.alias()
          grandChildComments = comments.alias()

          relation =
            comments
            .join(childComments,
              childComments.getColumn('parentId').eq(comments.getColumn('id')))
            .join(grandChildComments,
              grandChildComments.getColumn('parentId').eq(childComments.getColumn('id')))

          relation.all (err, tuples) ->
            leftTuples = (t.left for t in tuples)
            rightTuples = (t.right for t in tuples)

            expect(leftTuples).toEqualCompositeTuples(
              Comment, [
                { id: 1, body: 'Comment1', blogPostId: 1, authorId: 1, parentId: null }
              ],
              Comment, [
                { id: 2, body: 'Comment2', blogPostId: 1, authorId: 1, parentId: 1 }
              ])
            expect(rightTuples).toEqualRecords(
              Comment, [
                { id: 4, body: 'Comment4', blogPostId: 2, authorId: 1, parentId: 2 }
              ])
            done()

    describe "projections", ->
      it "builds a the right record class", (done) ->
        blogs.joinThrough(blogPosts).all (err, records) ->
          sortedRecords = _.sortBy records, (r) -> r.id()
          expect(sortedRecords).toEqualRecords(BlogPost, [
            { id: 1, public: true, title: 'Public Post1', blogId: 1 }
            { id: 2, public: true, title: 'Public Post2', blogId: 2 }
            { id: 3, public: false, title: 'Private Post1', blogId: 1 }
            { id: 4, public: false, title: 'Private Post2', blogId: 2 }
          ])
          done()

    describe "unions", ->
      it "builds a the right record class", (done) ->
        blogs.limit(2).union(blogs.limit(2, 1)).all (err, records) ->
          sortedRecords = _.sortBy records, (r) -> r.id()
          expect(sortedRecords).toEqualRecords(Blog, [
            { id: 1, public: true, title: 'Public Blog1', authorId: 1 }
            { id: 2, public: true, title: 'Public Blog2', authorId: 1 }
            { id: 3, public: false, title: 'Private Blog1', authorId: 1 }
          ])
          done()

    describe "differences", ->
      it "builds a the right record class", (done) ->
        blogs.limit(2).difference(blogs.limit(2, 1)).all (err, records) ->
          sortedRecords = _.sortBy records, (r) -> r.id()
          expect(sortedRecords).toEqualRecords(Blog, [
            { id: 1, public: true, title: 'Public Blog1', authorId: 1 }
          ])
          done()

  describe "#find", ->
    describe "when a predicate is passed", ->
      it "retrieves the first record matching the predicate", (done) ->
        blogs.find {title: "Public Blog2"}, (err, record) ->
          expect(record).toEqualRecord(Blog,
            id: 2,
            public: true,
            title: 'Public Blog2',
            authorId: 1
          )
          done()

      describe "when no record matches the predicate", ->
        it "passes null", (done) ->
          blogs.find { title: "Non-existent Blog" }, (err, record) ->
            expect(err).toBeNull()
            expect(record).toBeUndefined()
            done()

    describe "when an id is passed", ->
      it "retrieves the record with that id", (done) ->
        blogs.find 2, (err, record) ->
          expect(record).toEqualRecord(Blog,
            id: 2,
            public: true,
            title: 'Public Blog2',
            authorId: 1
          )
          done()

  describe "#at", ->
    describe "when a record exists at the given index", ->
      it "retrieves the record", (done) ->
        blogs.at 0, (err, record) ->
          expect(record.title()).toBe("Public Blog1")
          blogs.at 1, (err, record) ->
            expect(record.title()).toBe("Public Blog2")
            blogs.at 2, (err, record) ->
              expect(record.title()).toBe("Private Blog1")
              done()

  describe "#first", ->
    describe "when the relation has at least one record", ->
      it "retrieves the first record", (done) ->
        blogs.first (err, record) ->
          expect(record.title()).toBe("Public Blog1")
          done()

    describe "when the relation has no records", ->
      it "passes undefined", (done) ->
        blogs.where(title: 'Non-existent Blog').first (err, record) ->
          expect(err).toBeNull()
          expect(record).toBeUndefined()
          done()
