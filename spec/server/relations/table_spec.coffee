{ Monarch, async, recordClasses } = require "../spec_helper"
{ Blog } = recordClasses
blogs = Blog.table

describe "Relations.Table", ->
  beforeEach (done) ->
    blogs.deleteAll(done)

  describe "#create", ->
    describe "when a single attribute hash is passed", ->
      it "inserts a record with the given attributes", (done) ->
        blogs.create { public: true, title: "New Blog 1", authorId: 11 }, ->
          blogs.find { title: "New Blog 1" }, (err, record) ->
            expect(record.public()).toBeTruthy()
            expect(record.authorId()).toBe(11)
            done()

    describe "when an array of attribute hashes is passed", ->
      hashes = null

      beforeEach ->
        hashes = [
          { id: 1, public: true, title: "New Blog 1", authorId: 11 }
          { id: 2, public: true, title: "New Blog 2", authorId: 12 }
        ]

      it "inserts a record with each set of attributes", (done) ->
        blogs.create hashes, ->
          blogs.all (err, records) ->
            expect(records).toEqualRecords(Blog, [
              { id: 1, public: true, title: "New Blog 1", authorId: 11 }
              { id: 2, public: true, title: "New Blog 2", authorId: 12 }
            ])
            done()

      it "passes the number of records created", (done) ->
        blogs.create hashes, (err, count) ->
          expect(count).toBe(2)
          done()

      it "passes the ids of the rows created", (done) ->
        blogs.create hashes, (err, count, rows) ->
          expect(rows.length).toBe(2)
          expect(rows[0].id).toBeGreaterThan(0)
          expect(rows[1].id).toBe(rows[0].id + 1)
          done()

  describe "#updateAll", ->
    beforeEach (done) ->
      blogs.create([
        { id: 1, public: true, title: "New Blog 1", authorId: 11 }
        { id: 2, public: true, title: "New Blog 2", authorId: 12 }
      ], done)

    it "updates all records in the table with the given attributes", (done) ->
      blogs.updateAll { public: false, authorId: 13 }, ->
        blogs.all (err, records) ->
          expect(records).toEqualRecords(Blog, [
            { id: 1, public: false, title: "New Blog 1", authorId: 13 }
            { id: 2, public: false, title: "New Blog 2", authorId: 13 }
          ])
          done()

    it "passes the number of records updated", (done) ->
      blogs.updateAll { public: false, authorId: 13 }, (err, result) ->
        expect(result).toBe(2)
        done()

  describe "#deleteAll", ->
    beforeEach (done) ->
      blogs.create([
        { id: 1, public: true, title: "New Blog 1", authorId: 11 }
        { id: 2, public: true, title: "New Blog 2", authorId: 12 }
      ], done)

    it "deletes all records in the table", (done) ->
      blogs.deleteAll ->
        blogs.all (err, records) ->
          expect(records).toEqual([])
          done()

    it "passes the number of records deleted", (done) ->
      blogs.deleteAll (err, result) ->
        expect(result).toBe(2)
        done()
