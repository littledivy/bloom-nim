#[
#  filename: index.nim
#  description: the complete server and binder for all the modules :)
#  authors:
#    Divy Srivastava (@divy-work) <dj.srivastava23@gmail.com>
#  ]#

# import some cool modules
import jester, asyncdispatch
import src/blog
import src/database
import times, os
import json

# read admin confirgurations (feel free to change them)
var configFile = readFile("configuration.json")
var config = parseJson(configFile)

# creates a new Database instance
var db = newDatabase()

# defines our Jester routes here
routes:
  get "/":
    # response in rendered by the render_index procedure in blog.nim
    resp render_index(readFile("views/blog.ejs"))
  get "/upload":
    # checks for authentication
    if request.cookies.hasKey("username"):
      # serves upload page
      resp readFile("views/upload.ejs")
    # redirects back to index
    else: redirect("/")
  get "/login":
    # serves the login poge
    resp readFile("views/login.ejs")
  post "/login":
    # handles login credentials
    if @ "username" == config["username"].str:
      # checks username &  password validity
      if @ "password" == config["password"].str:
        # sets cookie as proof of authentication
        setCookie("username", @ "username", getTime().getGMTime() + 2.hours)
        # redirects to the upload page
        redirect("/upload")
      # redirects back to index  
      else: redirect("/")
    # redirects back to index
    else: redirect("/")    
  post "/upload/post":
    # checks admin authentication
    if request.cookies.hasKey("username"):
      # creates a new Post object based on input
      let post = Post(
        title: @"title",
        tags: @"tags",
        time: getTime(),
        body: @"text",
        image: @"image"
      )
      # saves the post to the databse instance
      db.post(post)
      # assures the client
      resp "Done"
    # redirects back to index
    else: redirect("/")
  get "/@id":
    # checks posts existence
    if db.checkPost( @ "id"):
      # renders the blog page for a particular post
       resp render_blog_page(readFile("views/blog-single.ejs"),@"id")
    else:
      # redirects back to index
       redirect("/")

# creates an eternal loop
runForever()
