#[
#  filename: blog.nim
#  description: the rendering engine for bloom
#  authors:
#    Divy Srivastava (@divy-work) <dj.srivastava23@gmail.com>
#  ]#

# import some epic modules
import re
import database
import db_sqlite, strutils
import times, os
import json
import markdown

# read admin configuration
var configFile = readFile("configuration.json")
var config = parseJson(configFile)

# our post div or component
var postStr = """<div class="col-md-4 ftco-animate">
	            <div class="blog-entry">
	              <a href="blog-single.html" class="block-20" style="background-image: url('{{image}}');">
	              </a>
	              <div class="text p-4 d-block">
	                <div class="meta mb-3">
	                  <div><a href="{{url}}">{{date}}</a></div>
	                </div>
	                <h3 class="heading"><a href="/{{url}}">{{title}}</a></h3>
	              </div>
	            </div>
	          </div>"""

#[
#  name: renderIndex
#  description: serves index page and collects database posts
#  arguments: content:string
#  returns: string
#  authors:
#     Divy Srivastava (@divy-work) <dj.srivastava23@gmail.com>
#  api: public
# ]#
proc renderIndex*(content: string):string =
  var list: string = ""
  var db = open("bloom.db", "", "", "")
  var dbConn = newDatabase()
  var ahey = db.getAllRows(sql"SELECT * FROM Post")
  for hey in ahey:
    var x = postStr.replace(re"{{title}}",hey[0]).replace(re"{{url}}",hey[1]).replace(re"{{date}}",hey[1].split(re"T")[0]).replace(re"{{image}}",hey[4])
    list.add(x)
  return content.replace(re"{{posts}}",list).replace(re"{{author}}",config["author"].str).replace(re"{{title}}", config["title"].str).replace(re"{{email}}",config["email"].str)

#[
#  name: renderBlogPage
#  description: serves blog page for a required post
#  arguments: content: string, param: string
#  returns: string
#  authors:
#     Divy Srivastava (@divy-work) <dj.srivastava23@gmail.com>
#  api: public
# ]#
proc renderBlogPage*(content:string, param:string):string =
  var tagList:string = ""
  var tagXML = "<a href='#' class='tag-cloud-link'>{tag}</a>"
  var dbConn = newDatabase()
  var ahoy = dbConn.findPost(param)
  for tags in ahoy[2].split(","):
    tagList.add(tagXML.replace(re"{tag}", tags))
  return content.replace(re"{{body}}",markdown(ahoy[3])).replace(re"{{author}}",config["author"].str).replace(re"{{title}}", config["title"].str).replace(re"{{email}}",config["email"].str).replace(re"{{blog_title}}",ahoy[0]).replace(re"{{about}}",config["about"].str).replace(re"{{tags}}",tagList)
  
