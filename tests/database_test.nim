import ../src/database
import db_sqlite
import os, times
import strutils
type
  CTime = int64

proc time(arg: ptr CTime): CTime {.importc, header: "<time.h>".}

type
  TM {.importc: "struct tm", header: "<time.h>".} = object
    tm_min: cint
    tm_hour: cint

proc localtime(time: ptr CTime): ptr TM {.importc, header: "<time.h>".}
var seconds = time(nil)
let tm = localtime(addr seconds)
echo(tm.tm_hour, ":", tm.tm_min)

when isMainModule:
  removeFile("bloom.db")
  var db = open("bloom.db", "", "", "")
  var dbConn = newDatabase()
  db.exec(sql"DROP TABLE IF EXISTS Post")
  db.exec(sql"""CREATE TABLE Post (
                 title text,
                 time Time,
                 tags text,
                 body text
              )""")
  dbConn.post(Post(title: "Hey",time: getTime(),tags: "test,hello,nimlang",body: "## Hey"))
  var hey = db.getRow(sql"SELECT * FROM Post WHERE title = ?", "Hey")
  echo("All tests finished successfully!")
