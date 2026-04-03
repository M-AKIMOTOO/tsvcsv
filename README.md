# tsvcsv

`tsvcsv` is a small Nim command-line tool that formats CSV or TSV data into an aligned table for terminal output.

## Features

- Reads from a file or standard input
- Auto-detects delimiter from file extension
- Supports explicit delimiter selection with `-d`
- Tries to keep wide characters aligned in terminal output

## Build

```sh
nim c tsvcsv.nim
```

This project includes [config.nims](/home/akimoto/program/nim/tsvcsv/config.nims), so the default build already uses:

- `-d:release`
- `--opt:speed`
- `--passL:-s`

This generates the stripped executable `./tsvcsv`.

If you want to override the project config explicitly, you can still run:

```sh
nim c -d:release --opt:speed --passL:-s tsvcsv.nim
```

## Usage

```sh
tsvcsv [options] [file]
```

Options:

- `-d`, `--delimiter:SEP` set the field delimiter
- `-h`, `--help` show help

Delimiter behavior:

- If a file ends with `.tsv`, tab is used automatically
- Otherwise, comma is used automatically for files
- When reading from standard input, comma is used by default
- You can force a tab delimiter with `-d:'\t'`

## Examples

```sh
./tsvcsv sample.csv
./tsvcsv sample.tsv
cat sample.tsv | ./tsvcsv -d:'\t'
cat sample.csv | ./tsvcsv
```

## Files

- `config.nims`: default Nim build settings for release, speed, and stripping
- `tsvcsv.nim`: source code
- `sample.csv`: CSV example input
- `sample.tsv`: TSV example input
