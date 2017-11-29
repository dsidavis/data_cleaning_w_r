
+ list.files(pattern = "\\.txt$")
+ Get the variable names and count of files for each (gsub)
+ Get the numbers and count for each
+ Check TIME is at line 5 for all files.
   + Shell's grep and system() and then R's extraction of the line number
   + Using R' grep() after reading lines in a file.

+ read.table()
+ Separate N and S in leftmost column
   + use gsub() or strsplit()
+ get the TIME value and trim it.
    named character classes
+ [low priority] Going back getting  longitude values
+ _mod versions where we have to split N and S and /grid-number
+ Finding missing value and mapping.  999 or if not using read.table() recognize NA moniker.




literal matching
Escaping
anchors ($)

dot (for .*)
quantifiers (* +.  Not ? or {m,n})

character classes [0-9], [a-z]
trim - named character classes



Didn't get
greedy

{m,n}
alternation

word boundaries


ignore.case or tolower()
fixed

grep(value = TRUE, invert = TRUE) - see mannheim
