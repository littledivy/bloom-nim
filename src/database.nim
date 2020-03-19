#[
#  filename: database.nim
#  description: a module to handle db_sqlite database operations
#  authors:
#    Divy Srivastava (@divy-work) <dj.srivastava23@gmail.com>
]#

# module imports
import times
import db_sqlite
import strutils

# defining our Database object type
type
  Database* = ref object
    db: DbConn

#[
#  name: newDatabase
#  description: creates a new database instance
#  arguments: filename(default: bloom.db)
#  returns: type Database ref object
#  authors:
#     Divy Srivastava (@divy-work) <dj.srivastava23@gmail.com>
#  api: public
]#
proc newDatabase*(filename = "bloom.db"): Database =
  new result
  result.db = open(filename, "", "", "")

# defining the Post object type
type
  Post* = object
    title*: string
    time*: Time
    tags*: string
    body*: string
    image*: string
  Comments* = object # TODO: Implement comments
    username*: string
    time*: Time
    msg*: string

#[
#  name: post
#  description: inserts a post in the database
#  arguments: database: Database ref object, message: Post object
#  returns: untyped or null
#  authors:
#     Divy Srivastava (@divy-work) <dj.srivastava23@gmail.com>
#  api: public
]#
proc post*(database: Database, message: Post) =
  database.db.exec(sql"INSERT INTO Post VALUES (?, ?, ?, ?, ?);", message.title, message.time, message.tags ,message.body, message.image)

#[
#  name: findAllPosts
#  description: Retrives all posts from the databse
#  arguments: database: Database ref object
#  returns: sequence[sequence[string]]
#  authors:
#     Divy Srivastava (@divy-work) <dj.srivastava23@gmail.com>
#  api: public
]#
proc findAllPosts*(database: Database): seq[seq[string]] =
  let posts = database.db.getAllRows(sql"SELECT * FROM Post")
  return posts

#[
#  name: findPost
#  description: Retrives post based on its ID
#  arguments: database: Database ref object, post: Post ID or Time
#  returns: sequence[string]
#  authors:
#     Divy Srivastava (@divy-work) <dj.srivastava23@gmail.com>
#  api: public
 ]#
proc findPost*(database: Database, post: string) : seq[string] =
  let post = database.db.getRow(sql"SELECT * FROM Post WHERE time = ?", post)
  return post

#[
#  name: checkPost
#  description: Checks existence of a particular post
#  arguments: database: Database ref object, post: Post ID or Time
#  returns: boolean
#  authors:
#     Divy Srivastava (@divy-work) <dj.srivastava23@gmail.com>
#  api: public
]#
proc checkPost*(database: Database, post: string) : bool =
  let resPost = database.db.getRow(sql"SELECT * FROM Post WHERE time = ?", post)
  if resPost[0].len == 0:
    return false
  return true

# <TODO>: Add comments to posts 
# proc comment*(database: Database, user: Comments) =
#  database.db.exec(sql"INSERT INTO Comment VALUES (?, ?, ?);", user.username, $user.time.toSeconds(), user.msg)
# </ TODO>

#[
#  name: close
#  description: Closes the databse instance
#  arguments: database: Database ref object
#  returns: untype or null
#  authors:
#     Divy Srivastava (@divy-work) <dj.srivastava23@gmail.com>
#  api: public
]#
proc close*(database: Database) =
  database.db.close()

#[
#  name: setup
#  description: Prepares the database for handling data
#  arguments: database: Database ref object
#  returns: untyped or null
#  authors:
#     Divy Srivastava (@divy-work) <dj.srivastava23@gmail.com>
#  api: public
]#
proc setup*(database: Database) =
  database.db.exec(sql"DROP TABLE IF EXISTS Post")
  database.db.exec(sql"""CREATE TABLE Post(
    title text,
    time Time,
    tags text,
    body text,
    image text
  )""")
