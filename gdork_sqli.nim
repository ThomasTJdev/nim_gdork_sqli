# (c) MIT - 2016 ThomasTJ (TTJ)
#
# Nimble q
# nim c -d:ssl -r gdork_sqli.nim
#

import os             #
import httpclient     # Connections
import q              # Manage HTML result
import re             # Regex in HTML result
import strutils       # For replacing
import times          # Get current time
import xmltree        # q depends on it


var htmlRaw: string   # HTML data from gdork (bing)
var htmlData: string  # HTML data to be checked for errors
var sqlmaybe: string  # Path to not-checked URLs
var counterA = 0      # Counter for prone URLs
var counterB = 0      # Counter for tries which failed
var counterC = 0      # Counter for tried URLs


let t = epochTime()   # Current epoch time


## Gets the current time
proc curtime(): string =
  return "[$# $#] " % [getDateStr(), getClockStr()]


## Handler for user interruption (Ctrl+C) 
proc handler() {.noconv.} =
  echo "\n"
  echo curtime(), "Program has run for ", formatFloat(epochTime() - t, precision = 0), " seconds."
  quit 0
 
setControlCHook(handler)


## First action - find file with SQL error messages
echo curtime(), "Name of sqlmsg file:"
var sqlmsg = "sql.txt"
while (existsFile sqlmsg) != true:
  echo curtime(), "[!] Files does no exists. Try again."
  sqlmsg = readLine(stdin) 


## Gather URLs to test
proc urlchoice(question: string): bool =
  echo question, " (e/n)"
  while true:
    case readLine(stdin)
    of "e", "E": return true
    of "n", "N": return false
    else: echo "Please be clear: (e)xisting or (n)ew"

## Action on proc urlchoice
if urlchoice("Check file with (e)xisting URLs or scan net for (n)ew?"):
  echo "Input path to file with urls:"
  var sqlmaybe = readLine(stdin) 
  while (existsFile sqlmaybe) != true:
    echo curtime(), "[!] Files does no exists. Try again."
    sqlmaybe = readLine(stdin) 
else:
  # Get raw urls
  sqlmaybe = "sqlurls.txt"
  for i in 1..5:
    echo curtime(), "Retrieving pagenr: ", $i, " from bing."
    var searchUrl = "http://www.bing.com/search?q=instreamset:(url%20title):php?id=&count=50&first=" & $(i * 50)
    htmlRaw = newHttpClient().getContent(searchUrl)
    var doc = q(htmlRaw)
    var outQ = doc.select("li.b_algo h2 a")

    var dd: string
    var s: string
    dd = $outQ
    s = dd.replace(re"\n", "")
    s = s.replace(re"<a\shref=", "\n")
    s = s.replace(re"\sh=.*,", ",")
    s = s.replace(re">.*a>", "")
    s = strutils.replace(s, "\"", "")
    s = strutils.replace(s, ",", "")
    s = strutils.replace(s, " ", "")
    var f = open(sqlmaybe, fmAppend)
    f.writeLine s
    f.close()


## Make output file ready for results
var sqlout = "sqliprone.txt"
if (existsFile sqlout) == true:
  var f = open(sqlout, fmAppend)
  var time = "\n[$# $#]  Scan initiated" % [getDateStr(), getClockStr()]
  f.writeLine $time
  f.close()


## Loop through URLs
for lineURL in lines sqlmaybe:
  try:
    htmlData = newHttpClient().getContent(lineURL & "'")
    echo curtime(), "Checking url nr.: ", $counterC
    inc(counterC)
    for lineSQL in lines sqlmsg:
      let s = htmlData.find(lineSQL)
      if s >= 0:
        echo "\n"
        echo curtime(), "PRONE: ", lineURL & "'"
        echo curtime(), "ERROR: ", s, " ", lineSQL
        echo "\n"
        var f = open(sqlout, fmAppend)
        f.writeLine lineURL
        f.close()
        inc(counterA)
        break
      else:
        inc(counterB)
        discard
  except:
    discard


## Ending, did it work?
echo "\n"
echo curtime(), "Found prone: ", $counterA
echo curtime(), "Not prone: ", $counterB
echo curtime(), "Results saved in: ", $sqlout

