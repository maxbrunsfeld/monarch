{ Monarch, recordClasses } = require "../spec_helper"
{ Blog } = recordClasses
blogs = Blog.table

describe "DeleteBuilder", ->
  describe "tables", ->
    it "constructs a delete statement", ->
      sql = blogs.deleteSql()
      expect(sql).toBeLikeQuery("""
        DELETE FROM "blogs"
      """)

  describe "selections", ->
    it "constructs a delete statement with a condition", ->
      sql = blogs.where(authorId: 5).deleteSql()
      expect(sql).toBeLikeQuery("""
        DELETE FROM
          "blogs"
        WHERE
          "blogs"."author_id" = 5
      """)

