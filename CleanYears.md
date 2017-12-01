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
tmp = gsub("[0-9]{1,2}-[A-Z][a-z]{2}-([0-9]{2})", "\\1", d$Year_First[w])
d$startYear[w] = as.integer(paste0("20", tmp))
```
Note that we prepended the strings with 20 to make them 4 digits, e.g., 08 to 2008.
Again, recall that gsub() will leave strings unaltered if the regular expression doesn't match.
Accordingly, for these, as.integer() will again return NA. So we will only change the 
elements of startYear which gave us a legitimate integer. 
We can also check that values are between 1900 and 2017.

So let's take a look and see what values we got  in this step:
```
table(tmp[!is.na(as.integer(paste0("20", tmp)))])
```
```
       01   02   03   04   05   06   07   08   09   10   11   12   13 
2788    9   58   35   69   93   47   18   23   45   25    7   17    2 
  14   15   47   89   93 
   3    1    1    1    2 
```
Again, we see many empty strings. But we also see 01, 02, 03, ...
However, we also see 89 and 93, although there are only 3 in total. Let's take a look at these by finding then in Year_First:
```
grep("[0-9]{1,2}-[A-Z][a-z]{2}-([89][0-9])", d$Year_First, value = TRUE)
```
Note we changed the pattern to look for 8 or 9 followed by a digit.
This matched
```
[1] "9-Aug-89"  "9-Apr-93"  "21-Jan-93"
```
So there are only 3 and we can fix these later when post-processing
2089 and 2093 or any value greater than 2017.  We can subtract 100.
Alternatively, we could make our original query more specific to have
the first digit of the two digit year be either 0 or 1 so that we only matched 2000 to 2020.
Then we could do the 1900-1999 with a separate regular expression.


## Next Pattern
Let's turn our attention to the remaining strings in d$Year_First for which we have 
not extracted a year in `d$startYear`.
Again, let's look at the unique values in d$Year_First that we haven't yet converted 
to non-NA values in d$startYear:
```
w = is.na(d$startYear) & d$Year_First != ""
unique(d$Year_First[w])
```
```
 [1] "2007-08"                    "Autumn 2003"               
 [3] "Mosquitoes fed from animal" "1960, 1985"                
 [5] "1971, 1983"                 "1983 original isolation"   
 [7] "1967 original isolation"    "1971 original isolation"   
 [9] "2007-2009"                  "10-Aug"                    
[11] "1995-2004"                  "1960-1962"                 
[13] "8-Aug"                      "7-Oct"                     
[15] "6-Feb"                      "1997-1998"                 
[17] "1986-1987"                  "8-Sep"                     
[19] "9-Nov"                      "9-Oct"                     
[21] "10-Sep"                     "3-May"                     
[23] "8-Jul"                      "11-Feb"                    
[25] "2011-12"                    "9-Mar"                     
[27] "8-Jun"                      "15-Sep"                    
[29] "12-Aug"                     "5/10/2015"                 
[31] "8/4/2014"                   "7/13/2015"                 
[33] "2005-08"                    "7/2/2012"                  
[35] "6/9/2008"                   "7/7/2008"                  
[37] "8/4/2008"                   "8/11/2008"                 
[39] "8/18/2008"                  "7-Aug"                     
[41] "9-Aug"                      "8305 E"                    
[43] "E23312421"                  "1982-1983"                 
[45] "1968 original isolation"   
```
There is no obvious year for values such as 8-Aug. So we'll leave those as NA.
Let's convert the values such as "8/11/2008".
This is very similar to the day-month-year except we have the month number, 
the month comes first, the day second, 
and we have a four digit year.
Let's write a regular expression to match these:
```
rx = "([0-9]|1[0-2])/[0-9]{1,2}/((19|20)[0-9]{2})"
```
We can check what it matches with
```
grep(rx, unique(d$Year_First[w]), value = TRUE)
```
```
[1] "5/10/2015" "8/4/2014"  "7/13/2015" "7/2/2012"  "6/9/2008" 
[6] "7/7/2008"  "8/4/2008"  "8/11/2008" "8/18/2008"
```
This seems to be all the ones. So we can use this as 
```
w = is.na(d$startYear) & d$Year_First != ""
tmp = gsub(rx, "\\2", d$Year_First[w])
d$startYear[w] = as.integer(tmp)
```

We are now left with only 58 NA values in startYear:
```
table(is.na(d$startYear))
```
These correspond to 
```
rem = unique(d$Year_First[is.na(d$startYear)])
rem
```

Let's deal with the range of years that appear with a , or a - and two years.
Let's find these 
```
grep(", |-", rem, value = TRUE)
 [1] "2007-08"    "1960, 1985" "1971, 1983" "2007-2009"  "10-Aug"    
 [6] "1995-2004"  "1960-1962"  "8-Aug"      "7-Oct"      "6-Feb"     
[11] "1997-1998"  "1986-1987"  "8-Sep"      "9-Nov"      "9-Oct"     
[16] "10-Sep"     "3-May"      "8-Jul"      "11-Feb"     "2011-12"   
[21] "9-Mar"      "8-Jun"      "15-Sep"     "12-Aug"     "2005-08"   
[26] "7-Aug"      "9-Aug"      "1982-1983" 
```
We want to avoid the day-monthName. We also have one element that has the end year
as two digits: 2007-08. Otherwise, we could look for 4 digits, a - and then four digits.
We also want our regular expression to be **as general as we need it for this data set and not any
more general (for other potential data sets)**.
So let's find the 4year-4year first:
```
rx = "[0-9]{4}-[0-9]{4}"
```
We can see which elements this matches, and which it doesn't with:
```
grep(rx, rem, value = TRUE)
grep(rx, rem, value = TRUE, invert = TRUE)
```
So let's allow the two-digit end year:
```
```
rx = "[0-9]{4}-[0-9]{2,4}"
grep(rx, rem, value = TRUE)
grep(rx, rem, value = TRUE, invert = TRUE)
```
That gets what we want.

We could deal with the ", " format separately. However, it is very similar
so we can incorporate both the "-" and ", " range separator into the same regular expression:
```
rx = "[0-9]{4}(-|, )[0-9]{2,4}"
grep(rx, rem, value = TRUE)
grep(rx, rem, value = TRUE, invert = TRUE)
```

So we can begin to apply this to Year_First and then update startYear.
Note however, we need the first year in the range, not the entire string.  Also,
we would like to take the second year in the range and use that to set the Year_Last column if
the corresponding element there is currently NA.
This is different from what we have been doing in earlier extractions above, but it is still feasible.

We first find the elements of Year_First we want to process by looking for the NA values in startYear
```
w = is.na(d$startYear) & d$Year_First != ""
```

We'll adapt our regular expression (rx) above slightly to put parentheses around
the two year parts so we can refer to them via backreferences.
```
rx = "([0-9]{4})(-|, )([0-9]{2,4})"
```
The starting year  will be in \\1, if there was a match. And we can convert that to an integer
and use that value for startYear.
```
tmp = gsub(rx, "\\1", d$Year_First[w])
d$startYear[w] = as.integer(tmp)
```

We can set the second/end year in Year_Last with:
```
w = w & is.na(d$Year_Last)
d$Year_Last[w] = as.integer(gsub(rx, "\\3", d$Year_First[w]))
```
Here we focus not just on the NA values in Year_First, but those for which Year_Last is also NA.
Then we process those elements of Year_First and extract the 3rd backreference, if there was a
match.  If there was no match, the as.integer() will give an NA.


### Making the 2-digit Years into 4-digits

Rather than deal with the two-digit end year, we could substitute in the first two digits.
So 2005-08 would become 2005-2008. We could do this with, e.g.,
```
gsub("^([0-9]{4})-([0-9]{2})$", "\\1-20\\2", "2005-08")
```
Note that we added ^ and $ to ensure we didn't match any string with more than 4 digits before the -
and, most importantly, the first two digits of a four digit year, e.g.  2007-2008.
Without the $ in the regular expression, we would get
```
gsub("^([0-9]{4})-([0-9]{2})", "\\1-20\\2", "2005-2008")
```
```
[1] "2005-202008"
```


## The Remaining Elements
We'll now deal with the remaining elements which are
```
 [1] "Autumn 2003"                "Mosquitoes fed from animal"
 [3] "1983 original isolation"    "1967 original isolation"   
 [5] "1971 original isolation"    "10-Aug"                    
 [7] "8-Aug"                      "7-Oct"                     
 [9] "6-Feb"                      "8-Sep"                     
[11] "9-Nov"                      "9-Oct"                     
[13] "10-Sep"                     "3-May"                     
[15] "8-Jul"                      "11-Feb"                    
[17] "9-Mar"                      "8-Jun"                     
[19] "15-Sep"                     "12-Aug"                    
[21] "7-Aug"                      "9-Aug"                     
[23] "8305 E"                     "E23312421"                 
[25] "1968 original isolation"   
```
We want the 2003, 1983, 1967, 1968, i.e. any 4 digits in a row and ignore the rest
of the text.
This would ignore (not match), e.g., the 12-Aug string.
However, this would also match parts of the "8305 E" and also "E23312421" strings.
So we are looking for 4 digits that start with 19 or 20.
Note that we also have to discard the rest of the characters in the string
We can write this with
```
rx = ".*\\b((19|20)[0-9]{2})\\b.*"
gsub(, "\\1", rem)
```

We can use this now to extract the remaining years:
```
w = is.na(d$startYear) & d$Year_First != ""
tmp = gsub(rx, "\\1", d$Year_First[w])
d$startYear[w] = as.integer(tmp)
```


Again, we can look the elements of Year_First for which we did not get a year with
```
rem = unique(d$Year_First[is.na(d$startYear)])
rem
```
```
 [1] "Mosquitoes fed from animal" "10-Aug"                    
 [3] "8-Aug"                      "7-Oct"                     
 [5] "6-Feb"                      "8-Sep"                     
 [7] "9-Nov"                      "9-Oct"                     
 [9] "10-Sep"                     "3-May"                     
[11] "8-Jul"                      "11-Feb"                    
[13] "9-Mar"                      "8-Jun"                     
[15] "15-Sep"                     "12-Aug"                    
[17] "7-Aug"                      "9-Aug"                     
[19] "8305 E"                     "E23312421"                 
```
These do not contain a year and so we are done!


# More Specific Regular Expressions

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
