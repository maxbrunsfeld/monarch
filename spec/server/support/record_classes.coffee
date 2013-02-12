root = "#{__dirname}/../../../src/server"
Monarch = require "#{root}/index"

class Blog extends Monarch.Record
  @extended(this)
  @columns
    public: 'boolean'
    title: 'string'
    authorId: 'integer'

class BlogPost extends Monarch.Record
  @extended(this)
  @columns
    public: 'boolean'
    title: 'string'
    blogId: 'integer'

class Comment extends Monarch.Record
  @extended(this)
  @columns
    body: 'string'
    blogPostId: 'integer'
    authorId: 'integer'

module.exports = { Blog, BlogPost, Comment }
