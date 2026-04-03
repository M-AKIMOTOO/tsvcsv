# Compile: nim c -d:release tsvcsv.nim
# 2026/04/03 
# AKIMOTO 
import os, parsecsv, strutils, unicode, parseopt, streams, terminal

const helpMessage = """
########                                             ####
   ##     ######   ##     ##                        ###### 
   ##    ##    ##  ##     ##                       ########
   ##    ##        ##     ##                        ######
 #####    ######   ##     ##      ##   #             ####
##    #        ##   ##   ##       # #  # ##      
##       ##    ##    ## ##        #  # #  #  #####    ##
##    #   #####        #          #   ##  ## # # #    ##
 #####  

tsvcsv - A simple tool to format TSV/CSV files for terminal output.

Usage:
  tsvcsv [options] [file]

Options:
  -d, --delimiter:SEP   Set the field delimiter (default: auto-detected)
  -h, --help            Show this help message

Examples:
  tsvcsv data.csv
  cat data.tsv | tsvcsv -d:'\t'
"""

proc get_display_width(s: string): int =
  ## 文字列の表示幅を計算（簡易的な全角対応）
  result = 0
  for rune in s.runes:
    if rune.int > 0x07FF:
      result += 2
    else:
      result += 1

proc print_table(rows: seq[seq[string]]) =
  if rows.len == 0: return

  let num_cols = rows[0].len
  var col_widths = newSeq[int](num_cols)

  for row in rows:
    for i in 0 ..< min(num_cols, row.len):
      col_widths[i] = max(col_widths[i], get_display_width(row[i]))

  proc print_row(row: seq[string], widths: seq[int]) =
    var line = ""
    for i in 0 ..< num_cols:
      let val = if i < row.len: row[i] else: ""
      let width = widths[i]
      let padding = " ".repeat(max(0, width - get_display_width(val)))
      line.add(val & padding & "  ")
    echo line.strip(trailing = true)

  print_row(rows[0], col_widths)
  
  var sep = ""
  for w in col_widths:
    sep.add("-".repeat(w) & "  ")
  echo sep.strip(trailing = true)

  for i in 1 ..< rows.len:
    print_row(rows[i], col_widths)

proc main() =
  var filename = ""
  var separator = '\0'
  var hasArgs = false
  
  var p = initOptParser()
  while true:
    p.next()
    case p.kind
    of cmdEnd: break
    of cmdShortOption, cmdLongOption:
      hasArgs = true
      case p.key
      of "d", "delimiter":
        if p.val == "\\t":
          separator = '\t'
        elif p.val.len > 0:
          separator = p.val[0]
      of "h", "help":
        echo helpMessage
        quit(0)
      else: discard
    of cmdArgument:
      hasArgs = true
      filename = p.key

  if not hasArgs and stdin.isatty:
    echo helpMessage
    quit(0)

  var stream: Stream
  if filename == "":
    stream = newFileStream(stdin)
    if separator == '\0': separator = ','
  else:
    if not fileExists(filename):
      echo "Error: File not found: ", filename
      quit(1)
    stream = newFileStream(filename, fmRead)
    if separator == '\0':
      if filename.endsWith(".tsv"):
        separator = '\t'
      else:
        separator = ','

  if stream.isNil:
    echo "Error: Could not open stream"
    quit(1)

  var rows: seq[seq[string]] = @[]
  var csv: CsvParser
  try:
    csv.open(stream, filename, separator = separator)
    while csv.readRow():
      rows.add(csv.row)
  finally:
    csv.close()

  print_table(rows)

if isMainModule:
  main()
