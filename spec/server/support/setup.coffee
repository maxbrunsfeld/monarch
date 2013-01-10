pg = require 'pg'
_ = require 'underscore'
{ series } = require 'async'
testConfig = require './database'
adminConfig = _.extend({}, testConfig, database: 'postgres')
testDatabase = testConfig.database

series [

  (f) ->
    pg.connect adminConfig, (err, client) ->
      return f(err) if err
      series [
        (f) -> client.query(
          "DROP DATABASE IF EXISTS #{testDatabase};", f)
        (f) -> client.query(
          "CREATE DATABASE #{testDatabase};", f)
      ], f

  (f) ->
    pg.connect testConfig, (err, client) ->
      return f(err) if err
      client.query """
        DROP TABLE IF EXISTS "blogs";
        DROP TABLE IF EXISTS "blog_posts";
        DROP TABLE IF EXISTS "comments";

        CREATE SEQUENCE "blogs_id_seq";
        CREATE TABLE "blogs" (
          id integer NOT NULL DEFAULT nextval('blogs_id_seq'),
          public boolean,
          title varchar,
          author_id integer);
        ALTER SEQUENCE "blogs_id_seq" OWNED BY "blogs"."id";

        CREATE SEQUENCE "blog_posts_id_seq";
        CREATE TABLE "blog_posts" (
          id integer NOT NULL DEFAULT nextval('blog_posts_id_seq'),
          public boolean,
          title varchar,
          blog_id integer);
        ALTER SEQUENCE "blog_posts_id_seq" OWNED BY "blog_posts"."id";

        CREATE SEQUENCE "comments_id_seq";
        CREATE TABLE "comments" (
          id integer NOT NULL DEFAULT nextval('comments_id_seq'),
          body varchar,
          author_id integer,
          blog_post_id integer);
        ALTER SEQUENCE "comments_id_seq" OWNED BY "comments"."id";
      """, f

], (e) ->
  message = if e then ("Error:" + e) else "Success."
  console.log message
  pg.end()
