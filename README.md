# Nim-lang google dorks SQL injections checker

This is a POC for using nim for IT security.

## Function

1) This code will do a bing search checking for `php?id=` in the URL. 
2) It will then catch 5 pages with 50 results on each and save the URLs in the `sqlurls.txt`.
3) Each URL will be checked for SQL error messages in `sql.txt`.
4) If an error is found, the URL will be save in `sqliprone.txt`

## Requirements

* nim
* `nimble q`

## Run

### Code
To run the code, you'll need to include the ssl flag (`-d:ssl`).

Run it with: `nim c -d:ssl -r gdork_sqli.nim`

### Executable
Run it with: `./gdork_sqli`
