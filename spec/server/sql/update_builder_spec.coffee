{ Monarch, recordClasses } = require "../spec_helper"
{ Blog } = recordClasses
blogs = Blog.table

describe "UpdateBuilder", ->
  describe "tables", ->
    it "constructs an update statement", ->
      sql = blogs.updateSql(public: false, title: "Updated Blog")
      expect(sql).toBeLikeQuery("""
        UPDATE "blogs"
        SET
          "public" = $1,
          "title" = $2
      """, [false, "Updated Blog"])

  describe "selections", ->
    it "constructs an update statement with a condition", ->
      sql = blogs.where(authorId: 5).updateSql(
        public: false,
        title: "Updated Blog"
      )
      expect(sql).toBeLikeQuery("""
        UPDATE "blogs"
        SET
          "public" = $1,
          "title" = $2
        WHERE
          "blogs"."author_id" = $3
      """, [false, "Updated Blog", 5])
