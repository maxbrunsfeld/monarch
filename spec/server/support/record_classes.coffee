root = "#{__dirname}/../../../src/server"
defaultRepository = require("#{root}/default_repository")
Monarch = require("#{root}/index")

module.exports = ->
  defaultRepository.clear()

  class global.Blog extends Monarch.Record
    @extended(this)
    @columns
      public: 'boolean'
      title: 'string'
      authorId: 'integer'

  class global.BlogPost extends Monarch.Record
    @extended(this)
    @columns
      public: 'boolean'
      title: 'string'
      blogId: 'integer'

  class global.Comment extends Monarch.Record
    @extended(this)
    @columns
      body: 'string'
      blogPostId: 'integer'
      authorId: 'integer'
      parentId: 'integer'
