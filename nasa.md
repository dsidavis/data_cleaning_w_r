# Reading the NASA Weather Data

## List all the Files in the Directory

We are looking at the .txt files only
```
ff = list.files(nasaDir, pattern = "\\.txt$", full.names = TRUE)
```
Note that we escaped the . so it is treated literally
and we ensure that the file ends with txt. This excludes
any .txt.bak or .txt~ or .txt123 files.


The files are organized by variable name.
We want to find these variable names, without the number.txt suffix.
We want to see how many files there are for each variable.
So we remove the suffix from the file names and get a count for each unique name:
```
fvar = gsub("[0-9]+\\.txt$", "", basename(ff))
table(fvar)
```
So 72 for each of the 7 variables which are named
cloudhigh, cloudlow, cloudmid, ozone, pressure, surftemp, temperature.

We'll also do the same for each unique number in the suffix to check that there are an equal number
of files for each of these.
There should be 7 for each and then we will know we have the same files for each variable.
```
fnum = gsub(".*([0-9]+)\\.txt$", "\\1", basename(ff))
table(fnum)
```
This doesn't actually give us what we want?  Why?
Think carefully about what the .* is matching.
It is greedy. What does ([0-9]+) then match?


We can fix this by looking for 
```
fnum = gsub("[a-zA-Z]+([0-9]+)\\.txt$", "\\1", basename(ff))
```
We could also use
```
fnum = gsub("[^0-9]+([0-9]+)\\.txt$", "\\1", basename(ff))
```
which is a litte more general and also shorter.

Now we can count the number of files for each number
```
table(fnum)
```

Are all the numbers represented or are there gaps in the sequence?
```
fnum = as.integer(fnum)
all(sort(unique(fnum)) == seq(min(fnum), max(fnum)))
```


# Reading a File

Looking at one of the files, we see
```
             VARIABLE : Mean high cloud amount (%)
             FILENAME : ISCCPMonthly_avg.nc
             FILEPATH : /usr/local/fer_data/data/
             SUBSET   : 24 by 24 points (LONGITUDE-LATITUDE)
             TIME     : 16-OCT-1996 00:00
              113.8W 111.2W 108.8W 106.2W 103.8W 101.2W 98.8W  96.2W  93.8W  91.2W  88.8W  86.2W  83.8W  81.2W  78.8W  76.2W  73.8W  71.2W  68.8W  66.2W  63.8W  61.2W  58.8W  56.2W  
               27     28     29     30     31     32     33     34     35     36     37     38     39     40     41     42     43     44     45     46     47     48     49     50
 36.2N / 51:   4.50   8.00   8.00  10.00   9.50   8.00   9.00   9.00  11.50  14.50  14.50  12.00  12.00  12.00  10.50   9.00   8.50  10.50  10.50  16.50  20.50  22.50  24.00  24.00
 33.8N / 50:   2.00   2.00   5.00   7.50   7.00   7.00  10.00  10.00  14.50  13.50  11.50  14.50  14.50  14.50  13.00  13.00  13.50  17.00  21.00  21.00  19.50  20.00  20.50  24.00
 31.2N / 49:   1.50   1.50   3.00   3.50   4.50   7.50  12.00  11.00  11.00  12.50  16.00  14.50  16.00  15.50  16.00  16.00  18.00  23.00  22.50  21.00  19.00  17.00  17.00  18.50
```
The first 5 lines are metadata giving a description of the VARIABLE, the original FILENAME,
FILEPATH, SUBSET and the TIME for the data.
The next line gives the longitudes for the grid of observations.
The  next line gives the grid number from 27 through 50.
Then each of the next lines contains the actual observations.
The first 3 elements give the latitude e.g. 36.2N, then a /, and then the grid row number.
Then the actual observations for that latitude are given as numbers  for each of the longitude
values.


There are 504 files. Do we think that they all have the same structure.
We don't want to manually check all of them. It takes a long time and 
we will also make mistakes.
Instead, we want to programmatically check.
One conjecture is that the TIME field is in the 5th row/line of each  file.
We can check this with
```
tl = sapply(ff, function(x) grep("TIME", readLines(x)))
table(tl)
```
And indeed we get 5 for all of them.

Another way to do this is to use the shell's version of grep via the system() (or system2())
function and read the results back into R 
```
cmd = sprintf("grep -n TIME %s/*.txt", nasaDir)
out = system(cmd, intern = TRUE)
```
```
head(out)
```
```
[1] "cloudhigh1.txt:5:             TIME     : 16-JAN-1995 00:00" 
[2] "cloudhigh10.txt:5:             TIME     : 16-OCT-1995 00:00"
[3] "cloudhigh11.txt:5:             TIME     : 16-NOV-1995 00:00"
[4] "cloudhigh12.txt:5:             TIME     : 16-DEC-1995 00:00"
[5] "cloudhigh13.txt:5:             TIME     : 16-JAN-1996 00:00"
[6] "cloudhigh14.txt:5:             TIME     : 16-FEB-1996 00:00"
```

We want to get the line number from each line of the output.
These are the numbers between the first and second :, i.e. after the
file name.
So we use a gsub() with a regular expression to get these:
```
time.ln = gsub("^.*txt:([0-9]+):.*", "\\1", out)
```
Here we put parentheses around the pattern that matches the number.
These parentheses identify the pattern and we can refer to it in the substitution text
as number 1, i.e. "\\1".


We can also check if the latitudes, or perhaps just the first one,  are the same for all
files.
```
trim = function(x) gsub("(^[[:space:]]+|[[:space:]]+$)", "", x)
```

```
l1 = sapply(ff, function(x) 
                  strsplit(trim(readLines(x)[8]), "\\s+")[[1]][1])
```
And again, we get 504 values of 36.2
```
table(l1)
```

If we want, we can count the number of lines that start with (spaces and then) a number
followed by N or S.
```
tmp = sapply(ff, function(x) 
         	       length(grep("^\\s+[0-9.]+[SN]", readLines(x))))
```

We can continue to check the contents across files are the same.
Alternatively, we can read the data into R and then compare the resulting
latitude and longitude values and times for the same file number across the
7 variables.

So for each file, let's read the data into data frame.
We'll unravel the values for the variable into a single column.
We'll repeat the latitude and longitude approriately and also the date-time information.
So each file will yield a data frame with 4 columns - value, latitude, longitude and date-time.


There are various different ways to read a file into a data frame.
Each will take several steps. To get the values, 
perhaps the "simplest" approach is to use read.table(), but skip the
first 7 rows.
```
d = read.table(ff[1], skip = 7, stringsAsFactors = FALSE)
```
Let's take a look at what we got:
```
head(d)
```
````
     V1 V2  V3   V4 V5   V6   V7   V8   V9  V10  V11  V12  V13  V14
1 36.2N  / 51: 26.0 23 23.0 17.0 19.5 17.0 16.0 16.0 16.0 19.0 18.0
2 33.8N  / 50: 20.0 20 18.5 16.5 18.0 15.0 15.0 15.0 16.0 15.0 15.0
3 31.2N  / 49: 16.0 16 14.0 12.5 13.5 14.5 13.5 13.5 13.5 13.0 13.0
4 28.8N  / 48: 13.0 11 11.0 11.0 14.0 13.5 11.5 12.0 15.0 18.0 18.0
5 26.2N  / 47:  7.5  8 10.5 10.5 15.0 16.5 19.5 20.0 20.5 19.5 17.0
6 23.8N  / 46:  8.0 11 13.0 19.5 19.5 26.0 27.5 25.5 20.0 14.0  9.5
   V15  V16  V17  V18  V19  V20  V21  V22  V23  V24  V25  V26  V27
1 19.0 19.5 19.5 18.0 16.0 14.0 14.0 14.0 18.0 20.5 22.0 25.5 25.5
2 17.5 17.0 17.0 17.0 17.5 17.5 18.0 19.0 19.0 20.0 22.0 23.5 23.5
3 16.5 18.5 20.0 21.0 21.0 21.0 20.5 20.5 19.5 19.0 19.0 19.0 20.5
4 18.5 20.5 20.5 18.5 18.0 17.0 15.0 15.0 14.0 13.0 13.0 13.5 12.5
5 16.0 16.0 16.0 12.5  9.5  8.5  7.5  5.5  4.5  4.5  6.5  6.5 10.0
6  8.5 10.0  8.0  4.5  5.0  5.0  4.5  3.5  2.5  2.5  4.0  8.0 12.5
```
The latitude values are in the first column. We can discard the 2nd and 3rd columns.
And the values are in the remaining columns.
So 
```
vals = unlist(d[-(1:3)])
```
gives us the vector of values we want.


### Latitude Values
Let's get the numeric values for latitude.
```
lat = as.numeric(gsub("[SN]", "", d[[1]]))
```
Note substring() wouldn't work properly as the strings have a different number of characters.
We need to multiply by -1 for those with S.
```
i = grepl("S$", d[[1]])
lat[i] = -1*lat[i]
```

## Longitudes

To get the longitudes, we need to read the 6th line of the file
and the split the text into strings.
We can do this with strsplit() or with read.table().
```
lon = strsplit(readLines(ff[1])[6], "\\s+")[[1]]
```
We have to remove the first value which is "".
We could either trim the line before we split it, or
just drop any element that is "".

Alternatively
```
lon = unlist(read.table(ff[1], skip = 5, nrow = 1, stringsAsFactors = FALSE))
```
We need to get rid of the W at the end. We'll use gsub() again:
```
lon = as.numeric(gsub("[WE]$", "", lon))
```
Again, if there were both East and West longitudes, we would need to convert
them to + and - respectively.


## Date-Time

```
tm = readLines(ff[1])[5]
```
```
[1] "             TIME     : 16-JAN-1995 00:00"
```

We can then use gsub() to get the value after the :
```
tm = gsub(".*: ", "", tm)
```
As always, using ".*" in a regular expression can be dangerous.
It works here only because we have a space after the :
Otherwise, ".*:" would have matched the second :, i.e. the one in the minutes and seconds (00:00).



### Putting It All Together

For completeness, let's create the data frame.

```
d = data.frame(values = vals,
               latitude = rep(lat, length(lon)),
    		   longitude = rep(lon, each = length(lat)),
 	  	       date = rep(as.POSIXct(strptime(tm, "%d-%b-%Y %M:%S")), length(vals)))
```



We leave it to the reader turn the code into  a function
that can be applied to each indivual file.


### Cleaning the Data for read.table()

Let's suppose we wanted to read the rectangular collection of values 
from row 8 onwards as a data frame, but 
+ we don't want the / gridNumber
+ we want the N or S in the latitude as a separate column
+ we ignore the longitudes

This is slightly contrived in this context. However,
we are trying to show how we can use regular expressions

We read the lines in the file. Then we discard the first 7.
```
ll = readLines(ff[1])[-(1:7)]
```

Then we change the linest to remove the " / 51: " etc.
Since there is a : in each line, we can use
```
ll = gsub(" / [0-9]+: ", "", ll)
```

Next, we want to add a space before the N or S.
```
ll = gsub("([NS])", " \\1", ll)
```

Now we can read this using a textConnection() and read.table()
```
d = read.table(textConnection(ll))
```


# Features of Regular Expressions We Used


<!--
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

-->


+ literal matching
+ Escaping characters
+ anchors ($)
+ Special s
+ dot (for .*)
+ quantifiers (* +.) But not ? or {m,n})
+ character classes [NS], [0-9], [a-z]
+ trim - named character classes, [[:space:]]
+ alternation (in trim)
+ Greedy matching


## Didn't See
+ {m,n}
+ word boundaries
+ ignore.case or tolower()
+ fixed = TRUE/FALSE
+ grep(value = TRUE, invert = TRUE) - see mannheim
