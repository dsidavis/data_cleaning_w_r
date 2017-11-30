# Cleaning Data Example

There are general guidelines and steps in cleaning data.
However, *all cleaning is context-specific.*
But we will illustrate some ideas with a specific example.


When cleaning data, it is important to try to think through
the entire provenance of the data and what could have gone wrong at each of the steps
+ how were the data initially recorded (electronically or on paper)?
+ were the values entered by a machine or by a human?
+ how many different humans entered the data?
+ what conventions and protocols did they use?
+ could they have spelled things differently? used different terms for the same thing?
  abbreviations?
+ did auto-complete propogate new erroneous entries (e.g. in Excel you enter a value
 that is wrong and correct it but Excel remembers the initial value as a possible entry when prompting)
+ did they use the same date format?
+ what are possible typos?
+ could they have entered a value in the wrong column?
+ might they have sorted the rows having frozen other invisible columns?


## The Data
The data are house sales in the San Francisco Bay Area in the early 2000s.
These are from Wickham et al.'s SF House Price Blues paper.
They are easy to understand.

```
d = read.csv("SFHouseSales.csv")
```

Even if we know the contents of the CSV, we check the class of
d and all its columns, the number rows and columns, the names of the columns:
```
class(d)
sapply(d, class)
dim(d)
names(d)
```
Are there any surprises? e.g. a column that you
thought should be a number is a factor.
If so, 
+ determine what the surprise is
+ probably check the CSV file and see how the surprise arose
   + an unexpected value (perhaps a symbol for missing value)
   + a quote or comment character R treated in an undesired way (see quote.char, comment.char
     parameters for read.table())

Did the data get messed up when exporting from Excel to a CSV file? e.g. 
formatting in Excel one way but appearing in the cell and CSV as something else?


## Summary
The summary() function gives us a sanity check 
```
summary(d)
```
```
                 county                 city             zip       
 Santa Clara County :79935   San Francisco: 22213   Min.   :94002  
 Contra Costa County:73767   Oakland      : 17195   1st Qu.:94520  
 Alameda County     :71214   Santa Rosa   : 11229   Median :94580  
 Solano County      :29424   Fremont      : 10782   Mean   :94688  
 San Mateo County   :27377   Evergreen    :  8930   3rd Qu.:95032  
 Sonoma County      :25246   Antioch      :  8636   Max.   :95820  
 (Other)            :41230   (Other)      :269208   NA's   :28     
                     street           price         
 460 Crescent Street    :    37   Min.   :   22000  
 1201 Glen Cove Parkway :    32   1st Qu.:  406500  
 1085 Murrieta Boulevard:    21   Median :  540000  
 900 Southampton Road   :    20   Mean   :  613273  
 100 Thorndale Drive    :    18   3rd Qu.:  715000  
 355 Parkview Terrace   :    18   Max.   :20000000  
 (Other)                :348047   NA's   :4         
       br              lsqft               bsqft        
 Min.   :      1   Min.   :        9   Min.   :    122  
 1st Qu.:      2   1st Qu.:     3800   1st Qu.:   1121  
 Median :      3   Median :     5670   Median :   1434  
 Mean   :     11   Mean   :    62525   Mean   :   1663  
 3rd Qu.:      4   3rd Qu.:     7788   3rd Qu.:   1894  
 Max.   :1450000   Max.   :418611600   Max.   :8944000  
 NA's   :66423     NA's   :59698       NA's   :51053    
      year               date             long             lat       
 Min.   :   0    2004-10-10:  3357   Min.   :-123.6   Min.   :36.98  
 1st Qu.:1953    2004-09-26:  3316   1st Qu.:-122.3   1st Qu.:37.54  
 Median :1970    2004-09-05:  3142   Median :-122.1   Median :37.77  
 Mean   :1965    2004-10-31:  2985   Mean   :-122.1   Mean   :37.79  
 3rd Qu.:1985    2005-07-24:  2973   3rd Qu.:-121.9   3rd Qu.:38.00  
 Max.   :3894    (Other)   :332416   Max.   :-121.3   Max.   :38.85  
 NA's   :60879   NA's      :     4   NA's   :32887    NA's   :32887  
                                      quality      
 QUALITY_ADDRESS_RANGE_INTERPOLATION      :205024  
 gpsvisualizer                            : 42035  
 QUALITY_CITY_CENTROID                    : 24628  
 QUALITY_EXACT_PARCEL_CENTROID            : 20530  
 QUALITY_ZIP_CODE_TABULATION_AREA_CENTROID: 18567  
 (Other)                                  :  4522  
 NA's                                     : 32887  
              match       
 Exact           :242184  
 Relaxed         : 36600  
 Relaxed; Soundex: 27850  
 Soundex         :  3014  
 1               :  2775  
 (Other)         :  2883  
 NA's            : 32887  
```


Note that the factors are shown with only a subset of the most frequent levels
and the rest are grouped into Other.  So we will have to look at the levels
separately. But summary gives us a very useful initial overview and allows us
to check some important high-level conditions.



## Missing Values - NAs

It is good to try to fix the easy problems that will impact later validation.
For example, we should look at the NAs and if there are only a few, see if we can
resolve these. If we can, this helps checking the results of the other values
in those columns later.  We may also find some structural issues such as all the
cells being moved one column to the right and hence leaving an empty cell.
Not only would we correct this empty cell, we would move all the other values
back to the correct columns and so any previous validation on those columns
would be muddled by the erroneous values.


We see the column 
+ zip  has 28 NAs, 
+ price has 4, 
+ date has 4
+ br (bedrooms) has 66423  - a lot and too many to check by hand
+ lsqft (lot size square feet) has 59698
+ bsqft (building size) has 51053

We don't get a count of the NAs in the factors. We'll return to these separately.

Both price  and date have 4 NAs which is manageable by hand and also exactly the same number.
Let's look at these observations:
```
d[ is.na(d$price) | is.na(d$date), ]
```
```
                   county      city   zip street price      br lsqft
37086      Alameda County   Fremont 94539    246    NA 1450000    NA
37087          2003-09-07              NA           NA      NA    NA
251205 Santa Clara County Cupertino    NA  95037    NA  790000    NA
251206         2005-06-26              NA           NA      NA    NA
       bsqft year date      long      lat
37086     NA   NA <NA> -121.9292 37.51501
37087     NA   NA <NA>        NA       NA
251205    NA   NA <NA> -122.0419 37.31749
251206    NA   NA <NA>        NA       NA
                                   quality match
37086  QUALITY_ADDRESS_RANGE_INTERPOLATION Exact
37087                                 <NA>  <NA>
251205 QUALITY_ADDRESS_RANGE_INTERPOLATION Exact
251206                                <NA>  <NA>
```
So when price is NA, so is date.

Note the row numbers. They are adjacent/consecutive pairs.  That is an interesting "coincidence"!
We should explore whether these were generated at the same time.

But note that while the rows within each pair are a consecutive,
they are very different. In fact, the first and third are similar,
and the 2nd and 4th are similar.
The 2nd and 4th are basically all NAs except for the county which is actually a date
and these look like the date the observations were recorded. (We know this from
contextual knowledge of the date, but we will also confirm this by looking at the
date column).

The first row has a ridiculous br  value (1,450,000) and a missing price.
Again, contextual knowledge allows us to presume that the price is $1.45 million.
The street is just a number. If we look at other values for the street column,
we'll see that it should be the number and street name. 

The third row has a value for street that looks remarkably like a zip code - 95037.
If we look up this ZIP code, we get Morgan Hill in Santa Clara county. So the county value
is fine. Morgan Hill and Cupertino are close but not adjacent.  So perhaps the city is correct, but
it may not be.  (See [http://www.zipmap.net/California.htm](http://www.zipmap.net/California.htm).)
We should move the street value into the zip column and make the street value  NA.
We should also make a note that the city may be wrong.

**This does suggest that we should check that the city name matches the zip code and that the
city and zip correspond to the county**

Similarly, the number of bedrooms (790,000) looks to be the price (although it seems low).
So we should move it to the price column.


```
i = "37086"
d[i, "price"] = d[i, "br"]
d[i, "br"] = NA
```
```
i = "251205"
d[i, "zip"] = d[i, "street"]
d[i, "price"] = d[i, "br"]
d[i, "br"] = d[i, "street"] = NA
```


### How do we make a note? 
+ Where do we put it? 
+ What format should it have so we can actually process and
use it later?




