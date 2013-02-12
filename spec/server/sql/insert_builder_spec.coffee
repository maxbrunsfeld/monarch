{ Monarch, recordClasses } = require "../spec_helper"
{ Blog } = recordClasses
blogs = Blog.table

describe "InsertBuilder", ->
  describe "when passed a single hash of attributes", ->
    it "creates an insert statement with a single list of values", ->
      sql = blogs.createSql({ public: true, title: 'Blog1', authorId: 5 })
      expect(sql).toBeLikeQuery("""
        INSERT INTO "blogs"
          ("public", "title", "author_id")
        VALUES
          (true, 'Blog1', 5)
        RETURNING "id"
      """)

  describe "when passed multiple hashes of attributes", ->
    it "creates an insert statement with a single list of values", ->
      sql = blogs.createSql([
        { public: true, title: 'Blog1', authorId: 11 }
        { public: false, title: 'Blog2', authorId: 12 }
      ])
      expect(sql).toBeLikeQuery("""
        INSERT INTO "blogs"
          ("public", "title", "author_id")
        VALUES
          (true, 'Blog1', 11),
          (false, 'Blog2', 12)
        RETURNING "id"
      """)

    it "fills in null values if attributes are missing from some hashes", ->
      sql = blogs.createSql([
        { public: true, title: 'Blog1' }
        { title: 'Blog2', authorId: 12 }
      ])
      expect(sql).toBeLikeQuery("""
        INSERT INTO "blogs"
          ("public", "title", "author_id")
        VALUES
          (true, 'Blog1', NULL),
          (NULL, 'Blog2', 12)
        RETURNING "id"
      """)
