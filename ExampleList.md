
## List of possible examples for Regular Expressions and Data Input


### Reading Data Input  Examples

+ Mannheim geolocation data
+ NASA atmospheric data
+ Personal ads.
+ Robot data
+ Email data (spamassassin, enron)


+ Email SMTP log data across machines


### Regular Expressions
+ Money amounts ($124,000   $12.02, ....)
+ Numbers  (123,423   1234534)
+ ZIP code - simple and full.  (95616  95817-2201)
+ IP Address  
```
ip = c("169.237.46.128", "128.32.135.10", "987.123.23")
grep("^[0-2]?[0-9]{1,2}\\.[0-2]?[0-9]{1,2}\\.[0-2]?[0-9]{1,2}\\.[0-2]?[0-9]{1,2}$", ip)
```
+ Dates  (01/12/2017, 1/12/2017, 1/12/17, 12/1/17, Dec. 1, 2017, 1st December 2017)
```
grep("([0-9]([01]/[0-9]/(19[0-9]{2}|20[01][0-9])")
```
+ Times  (9.15, 9:15:03)
+ Everything inside quotes  ( 'Text containing "some quoted material" within it')
+ URLs  (http://google.com,  https://www.google.com, http://localhost:8080)
+ Two words in a row  ("With the the content")
```
grep("([a-z]+) \\1", c("With the the content", "nothing here"))
```
or more generally
```
grep("\\b([a-z]+)\\b\\s+\\1", c("With the the content", "nothing here"))
```
+ Author name  (e.g.  D. Temple Lang,  M. Espe)


## Transform Text

+ Change extension on a file name
```
gsub("\\.pdf$", ".xml", filenames)
```
+ Change Smart quotes to regular quotes (“ versus ",  ‘ and ’ versus ')
```
```



### XML 
  + don't use regular expressions

### Natural Language Processing
  + Free text parts of speech
  + Entity recognition and extraction


