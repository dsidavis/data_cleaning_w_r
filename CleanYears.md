# Cleaning and Transforming Text Data

Let's consider a different data set.
These are data  manually entered into a spreadsheet.
The data  come from reading journal articles
and then identifying information such as 
+ first year
+ last year
+ country
+ identifier for PDF(s)

The data are in 
[http://dsi.ucdavis.edu/Workshops/CleaningRegex/YearCountry.csv](http://dsi.ucdavis.edu/Workshops/CleaningRegex/YearCountry.csv).
So we can read these into R with
```
u = "http://dsi.ucdavis.edu/Workshops/CleaningRegex/YearCountry.csv"
d = read.csv(u, stringsAsFactors = FALSE)
```

We look at the first few lines
```
head(d)
```
```
  Year_First Year_Last          Country                           PDF
1                   NA      Philippines internal-pdf://2699927534.pdf
2                   NA     Saudi Arabia                          <NA>
3                   NA     Saudi Arabia                          <NA>
4                 1954            Japan                          <NA>
5                 1954            Japan                          <NA>
6                   NA Papua New Guinea internal-pdf://0659339597.pdf
```


Again, we check the class of the data frame, the dimensions, 
names, the classes of the columns and call summary():
```
class(d)
dim(d)
names(d)
sapply(d, class)
summary(d)
```
```
  Year_First          Year_Last      Country         
 Length:4143        Min.   :1954   Length:4143       
 Class :character   1st Qu.:1998   Class :character  
 Mode  :character   Median :2006   Mode  :character  
                    Mean   :2001                     
                    3rd Qu.:2012                     
                    Max.   :2016                     
                    NA's   :3775                     
     PDF           
 Length:4143       
 Class :character  
 Mode  :character  
```


## Year_First

Let's look at the Year_First values.
They are strings/characters rather than numbers.
So something is not quite correct about them.
Let's look at the values.
```
tt = sort(table(d$Year_First))
```
```
tail(tt)
```
```
2002 2008 2007 2011 2003      
  43   45   52   76   93 2788 
```
These look fine. The last one with the highest count is the empty string.

We can look at all of the unique values with `names(tt)`.
There are 440 of them so it isn't too much to look at.
```
names(tt)
```
This mixes the legitimate year strings with  the non-legitimate ones.

Alternatively, we can coerce the values to integers and ssee which result as NA values:
```
i = is.na(as.integer(d$Year_First))
unique(d$Year_First[i])
```
There are still 375 of these.
```
  [1] ""
                  
  [2] "2007-08"                                                                                                                 
  [3] "Autumn 2003"                                                                                                             
  [4] "18-Oct-04"                                                                                                               
  [5] "21-Oct-04"                                                                                                               
 ......................

[369] "28-Sep-03"                                                                                                               
[370] "26-Jul-06"                                                                                                               
[371] "25-Sep-03"                                                                                                               
[372] "83¥Ë_¥Ë_¥Ë_¥Ë_¥Ë_¥Ë_¥Ë_¥Ë_05 E"                                                                                          
[373] "E23¥Ë_¥Ë_¥Ë_¥Ë_¥Ë_¥Ë_¥Ë_¥Ë_31¥Ë_¥Ë_¥Ë_¥Ë_¥Ë_¥Ë_¥Ë_¥Ë_¥Ë_¥Ë_¥Ë_¥Ë_¥Ë_¥Ë_24¥Ë_¥Ë_¥Ë_¥Ë_¥Ë_¥Ë_¥Ë_¥Ë_21¥Ë_¥Ë_¥Ë_¥Ë_¥Ë_¥Ë_¥Ë_"
[374] "1982-1983"                                                                                                               
[375] "1968 original isolation"                                                                                                 
```

We see
+ range of years ("2007-08")
+ an actual date in the form day-month-year
+ a year and some text ("1969 original isolation")
+ some weird text ("83¥Ë_¥Ë_¥Ë_¥Ë_¥Ë_¥Ë_¥Ë_¥Ë_05 E")

We want the year and we can get it from the first 3 types.
But we first need to remove the odd characters – ¥Ë_ – from the final type.
We need to replace all occurrences of this three character sequence with the empty string.
We can do this with gsub().

```
tmp = gsub("¥Ë_", "", d$Year_First)
```
It is often a good idea to assign the modified vector to a temporary variable
and inspect it and verify we didn't corrup legitimate values.
When we are certain it is correct, we can assign it to d$Year_First to replace
the original vector
```
d$Year_First = tmp
```

So we can recompute the table i as above to see if this fixed any of the elements:
```
i = is.na(as.integer(d$Year_First))
unique(d$Year_First[i])
```
This did eliminate one entry. (Which one?)



In this list of elements that weren't integers, we also see
strings of the form 
+ "8/4/2008", 
+ "15-Sep" (with no year)
+ "1960, 1985"
+ "Autumn 2003"
+ "Mosquitoes fed from animal"


So now we have larger set of patterns to process to extract the year.

The order in which we process these is important.
Let's get the well-structured ones first
+ day-month-year
+ /day/month/year

How can we identify each of these.

## day-month-year
We are looking for which strings follow the pattern
```
one or two digits followed by - 
followed by a capital letter followed by 2 characters 
followed by two digits
```

+ Are there any with 4 digits for the year?
+ Do we care about possibly matching a month name that isn't Jan, Feb, Mar, ... Dec?
+ What about years that are greater than 2017?
+ or day of the month greater than 31?

Note that we can convert these strings directly to Dates in R and have R handle the
names of the months, illegal day of the month, etc.
However, we may still want to recognize the subset in this format before passing them 
to as.Date().  Again, there is nearly
always a better approach for any given problem that is specific to the problem.
Regular expressions are a very general and rarely the best, but often the most convenient
and expedient.

We can represent our pattern above  as a regular expression with
```
[0-9][0-9]?-[A-Z][a-z][a-z]-[0-9][0-9]
```
Let's check this works on a few of the elements:
```
tst = c("9-Aug-06", "13-Aug-08", "999-August-2008")
grep("[0-9][0-9]?-[A-Z][a-z][a-z]-[0-9][0-9]", tst)
```
This only matches the first two, as we had intended.

We can write this very slightly more succinctly using quantifiers
to say 1 or 2 digits or characters in different places
```
grep("[0-9]{1,2}-[A-Z][a-z]{2}-[0-9]{2}", tst)
```
We can also allow the year as 08 or 2008 by allowing between 2 and 4 digits in the year
```
grep("[0-9]{1,2}-[A-Z][a-z]{2}-[0-9]{2,4}", tst)
```
Of course, this allows 3 digits, e.g., 108 which would not be valid!
So we could ensure either 2 or 4 digits in the year using alternation:
```
grep("[0-9]{1,2}-[A-Z][a-z]{2}-([0-9]{2}|[0-9]{4})", tst)
```
This is getting more complicated but this is due to being  more precise and specific.


The next thing we want to do is get the year from these strings.
Again, gsub() will do the work.
```
gsub("[0-9]{1,2}-[A-Z][a-z]{2}-([0-9]{2}|[0-9]{4})", "\\1", tst)
```
Note that when we didn't match a string, gsub() left the string unaltered.
We can either only convert the strings that match the regular expression by
first identifying those with grepl(), or we can just check the results
of gsub() yield an integer.



Let's create a new variable in our data frame named `startYear` with the first year.
We create this initially with 
```
d$startYear = as.integer(d$Year_First)
```
Now, we will apply our regular expression to those elements of d$Year_First which
have a corresponding NA value in d$startYear, i.e. for which as.integer(d$Year_First) "failed".
We do this with:
```
w = is.na(d$startYear)
tmp = gsub("[0-9]{1,2}-[A-Z][a-z]{2}-([0-9]{2}|[0-9]{4})", "\\1", d$Year_First[w])
d$startYear[w] = as.integer(tmp)
```
Again, recall that gsub() will leave strings unaltered if the regular expression doesn't match.
Accordingly, for these, as.integer() will again return NA. So we will only update the 



## Matching Legitimate Month Names
What if we want to ensure Bob doesn't match as a month name?
We can use alternation in our regular expression
```
grep("[0-9]{1,2}-(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)-([0-9]{2}|[0-9]{4})", tst)
```
NOTE:  The () for the alternation makes this group number 1. Hence the year is now in group \\2
and we need to change the gsub() to substitute that group, not \\1.

I didn't actually write out the months Jan|Feb....
Instead, I pasted the elements of month.abb together with
```
paste(month.abb, collapse = "|")
```
and put that into  the  regular expression.
Alternatively, I can programmatically create the regular expression within 
```
sprintf("[0-9]{1,2}-(%s)-([0-9]{2}|[0-9]{4})", paste(month.abb, collapse = "|"))
```

But what if we were doing this in another locale/language where the month names
were not in month.abb or if we wanted the days of the week.  There is a good trick for this.
We can get the abbreviated month names with 
```
format(seq(as.Date("2017-1-1"), length = 12, by = "month"), "%b")
```
We create a sequence of length 12 starting on January 1st and we format these using %b which
indicates  the abbreviated month name.


The key thing here is that we can programmatically generate regular expressions since they
are just strings in R. If we want to match, for example, city names, we can paste these
together.




## Matching Legitimate Day of Month

Suppose we wanted to guard against the day of the month being in excess of 31.
We could do this when converting the value to a Date object in R and that may be the best thing to
do as it can detect, e.g., 31 February.
However, we can also do a less robust version with regular expressions.
We can allow 
+ a single digit, or 
+ a 1 and any following digit, or
+ a 2 and any following digit, or 
+ a 3 followed by 0 or 1.
We can implement this with
```
grep("(0-9|1[0-9]|2[0-9]|3[0-1])-(Jan|Feb...)-[0-9]{2}", ts)
```

We can also simplify the 2 middle alternatives to `[12][0-9]`.
