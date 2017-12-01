<link rel="stylesheet" type="text/css" media="all" href="callout.css" />

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



When cleaning data, we spend a lot of time looking at individual observations.
We borrow information from many other observations to know what is typical.
This helps us to identify atypical observations and values, and also to fix them.


Clean the variables you are going to use. Don't waste time cleaning all variables some
of which are not relevant!


## The Data
The data are house sales in the San Francisco Bay Area in the early 2000s.
These are from Wickham et al.'s SF House Price Blues paper.
They are easy to understand.


|Variable Name|Description|
|-------------|-----------|
|county|Name of county|
|city|Name of city|
|zip|ZIP code|
|street|Street number and name|
|price|Sale price of the house ($)|
|br|number of bedrooms in the house|
|lsqft|lot size (square feet)|
|bsqft|interior building size (square feet)|
|year|year house was built|
|date|date house was recorded as sold|
|long|longitude|
|lat|latitude|
|quality|method for GeoLocation from street, city, county and ZIP|
|match|quality of geolocation match|

+ The data are submitted to county administrators when the sale of the house occurs.
+ These were collected in some way by SF Gate, the newspaper.
+ They were scraped from SF Gate's Web form
+ They were converted from HTML to DCF
+ They were read from DCF to R
+ Organized into a data frame
+ Written to a CSV file


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
The summary() function gives us a sanity check  on the values in each of the columns
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


<div class="inset">
<h4>How do we make a note? </h4>

<ul>
<li> Where do we put it? 
<li> What format should it have so we can actually process and
use it later?
</ul>
</div>

We can look at the 28 NAs in the zip column.
There are now 27 since we corrected one.
Two of these will be the 2nd and 4th rows above which are essentially useless.
So we should discard these first.
We can identify their row numbers (manually or programmatically).
But what happens if we add or remove other rows and then run this code again. Then these row numbers will become 
incorrect and we will potentially delete/modify valid rows.
We can modify the CSV file (and the Excel file if that is the origin of the CSV file).
Where to modify so that we have consistency and reproducability is an important decision.
When cleaning and writing code to clean, we can identify these rows in richer ways than
manually identifying them. We want the rows 


<!-- 
Writing general filters
-->
If the criterion is that all values in important columns are NAs, then we use this:
```
essentialVars = c("zip", "street", "price", "br", "lsqft", "bsqft", "date")
tmp = lapply(d[ essentialVars ], function(x) is.na(x)  | x == "")
tmp1 = Reduce(`&`, tmp)
```
If the criterion is the county name is a date, then we find it with some sort of way 
of finding a date. In this case, we'll say it doesn't contain the word County and we'll use
lower-case
```
!grepl("county", d$county, ignore.case = TRUE)
```
Or if we want no numbers
```
!grepl("[0-9]", d$county)
```
Both match our two rows. But they both work generally if the CSV file gets updated.
And they also are more general than the 

The number of NAs in the other columns are very large and we'll have to examine these during
the EDA (Exploratory Data Analysis) stages. Note that cleaning and EDA are very intertwined and
iterative.
We clean while we are exploring and we explore while we clean.




## Check the ZIP codes

Of course, there isn't much point in cleaning the ZIP codes if we aren't going to use them.
In our case, we may want to look at information such as the performance of schools at the ZIP code
level and how this may influence house prices.
We might be interested in household and individual income levels in these ZIP codes and how these
relate to house prices.



All ZIP codes in this data set should have 5 digits.
We can verify this with 
```
table(nchar(d$zip))
```
This just checks they have 5 characters, not necessarily numbers.

We might try converting the values to integers to see if they are valid
integers:
```
table(is.na(d$zip))
```
```
 FALSE   TRUE 
348165     28 
```

Let's look at these values in d$zip:
```
d$zip[is.na(d$zip)]
```
```
 [1] NA NA NA NA NA NA NA NA NA NA NA NA NA NA NA NA NA NA NA NA NA NA
[23] NA NA NA NA NA NA
```
They are all NAs to start with.
So the ZIP codes look okay as 5 digits.

But are the values legitimate ZIP codes.
We need a full list of all the ZIP codes, at least in California or the Bay Area.
So we need to get auxiliary data.
Again, this will be very context-specific. So let's not worry about the details
about how we get the set of legitimate ZIP codes.
However, it is quite easy:
```
library(XML)
zips = readHTMLTable("http://www.zipcodestogo.com/California/", which = 2, header = TRUE)
```
(Of course, these may not be correct either. But it is a good start.)

So now we can compare our values to this set of ZIP code values:
```
table(as.character(d$zip) %in% zips[[1]])
```
```
 FALSE   TRUE 
    49 348144 
```
So only 49 are not in our set of valid ZIP codes.
Of course, just because a ZIP code value is a valid ZIP code
doesn't mean it is correct for this observation. We may have a ZIP code
that is valid but for a different city, county or even state.
Indeed, we should check the first two digits of the observed ZIP codes:
```
table(substring(d$zip, 1, 2))
```
```
    94     95 
252428  95737 
```
These look like legitimate California ZIP codes.


So let's look at these ZIP code values that are not in our database of valid ZIP codes:
```
w = !(as.character(d$zip) %in% zips[[1]])
as.character(d$zip[w])
```
```
 [1] NA      NA      "94400" "94400" "94400" "94400" "94400" "94909"
 [9] "94400" NA      NA      NA      "94380" "94400" "94400" "94300"
[17] "94400" "94400" "94461" "94400" "94400" "95434" NA      "95434"
[25] "95434" "95434" NA      NA      "94307" NA      NA      NA     
[33] NA      NA      NA      NA      NA      NA      NA      NA     
[41] NA      NA      NA      NA      NA      NA      NA      NA     
[49] NA     
```

Using table() on these would be better so we can see the repeats more readily.
```
sort(table(as.character(h$zip[w])))
```
```94300 94307 94380 94461 94909 95434 94400 
    1     1     1     1     1     4    12 
```
Unfortuantely, this omits the NAs.


We can look these up on the Web and see if they were previously valid ZIP codes.
Also, we look at the observations:
```
d[w,]
```
```
                    county            city   zip                      street   price     br  lsqft bsqft year       date      long      lat
27204          Napa County American Canyon    NA              53 Palazzo Way  518000     NA   5663    NA   NA 2003-08-03        NA       NA
37087           2003-09-07                    NA                                  NA     NA     NA    NA   NA       <NA>        NA       NA
38271     San Mateo County       San Mateo 94400       161 Blossom Circle #2  255000     NA     NA    NA   NA 2003-09-07        NA       NA
38295     San Mateo County       San Mateo 94400          1060 Myrtle Street  180000     NA     NA    NA   NA 2003-09-07 -122.3148 37.54703
38296     San Mateo County       San Mateo 94400           308 Nelson Avenue  485000     NA     NA    NA   NA 2003-09-07 -122.3130 37.55429
50297     San Mateo County       San Mateo 94400          1060 Myrtle Street  180000     NA     NA    NA   NA 2003-10-19 -122.3148 37.54703
54537     San Mateo County       San Mateo 94400               3918 Kent Way  586000     NA     NA    NA   NA 2003-11-02 -122.3130 37.55429
56316  Contra Costa County       San Pablo 94909        101 San Miguel Court  424500     NA     NA    NA   NA 2003-11-09 -122.3398 37.96428
61572     San Mateo County       San Mateo 94400               3918 Kent Way  586000     NA     NA    NA   NA 2003-11-23 -122.3130 37.55429
75407        Solano County       Rio Vista    NA     319 Crystal Downs Drive  320000     NA   5850    NA   NA 2004-01-04 -121.6958 38.16391
75529        Sonoma County        Petaluma    NA         978 Hogwarts Circle  497000     NA   4491    NA   NA 2004-01-04        NA       NA
75530        Sonoma County        Petaluma    NA         980 Hogwarts Circle  400000     NA   3459    NA   NA 2004-01-04        NA       NA
87543       Alameda County     San Lorenzo 94380            471 Crespi Place  421500     NA     NA    NA   NA 2004-02-15 -122.1338 37.67518
100015    San Mateo County       San Mateo 94400       1 Baldwin Avenue #715  240000     NA     NA    NA   NA 2004-04-04        NA       NA
100016    San Mateo County       San Mateo 94400       1 Baldwin Avenue #808  475000     NA     NA    NA   NA 2004-04-04        NA       NA
109045  Santa Clara County       Palo Alto 94300       315 Homer Avenue #105  900000     NA     NA    NA   NA 2004-05-02        NA       NA
126512    San Mateo County       San Mateo 94400       1 Baldwin Avenue #718  295000     NA     NA    NA   NA 2004-06-27        NA       NA
128941    San Mateo County       San Mateo 94400       1 Baldwin Avenue #222  435000     NA     NA    NA   NA 2004-07-04        NA       NA
140606 Contra Costa County          Oakley 94461           505 Arrowhead Way  400000     NA     NA    NA   NA 2004-08-08 -121.7183 37.99347
152652    San Mateo County       San Mateo 94400       1 Baldwin Avenue #402  285000     NA     NA    NA   NA 2004-09-05        NA       NA
158586    San Mateo County       San Mateo 94400       1 Baldwin Avenue #509  615000     NA     NA    NA   NA 2004-09-19        NA       NA
162639       Solano County       Fairfield 95434     5322 Laurel Ridge Court  410000     NA  30114    NA   NA 2004-09-26 -122.0543 38.25776
164380        Marin County      San Rafael    NA         22 Montezuma Avenue  555000      3   5550  1023 1963 2004-10-03 -122.5325 37.97457
165523       Solano County       Fairfield 95434         5302 Bayridge Drive  322500     NA  29510    NA   NA 2004-10-03 -122.0543 38.25776
165563       Solano County       Fairfield 95434     5315 Laurel Ridge Court  451000     NA  37154    NA   NA 2004-10-03 -122.0543 38.25776
165564       Solano County       Fairfield 95434     5326 Laurel Ridge Court  375000     NA  37941    NA   NA 2004-10-03 -122.0543 38.25776
166921 Contra Costa County       Brentwood    NA            2405 Sunset Road 1164000     NA 415606    NA   NA 2004-10-10 -121.7095 37.93531
166922 Contra Costa County       Brentwood    NA              1901 Tule Lane  325000     NA     NA    NA   NA 2004-10-10 -121.7095 37.93531
196800    San Mateo County         Montara 94307           1100 Birch Street  649000      3   5000  1330 1963 2004-12-26 -122.5044 37.54183
201170 Contra Costa County        Crockett    NA 7000 Carquinez Scenic Drive  620000      2  14810  1100 1951 2005-01-09 -122.2234 38.05282
203500 Contra Costa County   Discovery Bay    NA           3154 Hosie Avenue  411500      3   5308  1381 1989 2005-01-16        NA       NA
206245 Contra Costa County    Walnut Creek    NA      975 Bancroft Road #104  220000      1     NA   570 1971 2005-01-23        NA       NA
207429       Solano County       Rio Vista    NA    606 American Falls Drive  301000     NA   4950    NA   NA 2005-01-23 -121.6958 38.16391
207433       Solano County       Rio Vista    NA       628 Birch Ridge Drive  276500     NA   4242    NA   NA 2005-01-23        NA       NA
207435       Solano County       Rio Vista    NA       633 Birch Ridge Drive  277000     NA   4347    NA   NA 2005-01-23        NA       NA
207436       Solano County       Rio Vista    NA       641 Birch Ridge Drive  275500     NA   4447    NA   NA 2005-01-23        NA       NA
207696       Sonoma County      Santa Rosa    NA           3715 Giorno Court 1350000     NA  15246    NA   NA 2005-01-23 -122.7046 38.44861
208171 Contra Costa County           Alamo    NA              100 Via Canada 1625000      4  20909  1917 1973 2005-01-30 -122.0327 37.85899
208579         Napa County          Angwin    NA     1350 Staples Ridge Road 1350000     NA 521413    NA   NA 2005-01-30 -122.4481 38.57451
208600         Napa County            Napa    NA        240 Sugar Loaf Drive  363000     NA  10454  1484 1978 2005-01-30 -122.2989 38.30476
209240       Solano County       Rio Vista    NA       644 Birch Ridge Drive  297000     NA   4637    NA   NA 2005-01-30        NA       NA
209241       Solano County       Rio Vista    NA       649 Birch Ridge Drive  280000     NA   5413    NA   NA 2005-01-30        NA       NA
210090 Contra Costa County        Martinez    NA   4225 Franklin Canyon Road  480000     NA  45564    NA   NA 2005-02-06 -122.1201 38.00059
211202       Solano County       Rio Vista    NA    602 American Falls Drive  367500     NA   5873    NA   NA 2005-02-06        NA       NA
251205  Santa Clara County       Cupertino    NA                       95037      NA 790000     NA    NA   NA       <NA> -122.0419 37.31749
251206          2005-06-26                    NA                                  NA     NA     NA    NA   NA       <NA>        NA       NA
335312    San Mateo County      Moss Beach    NA           1 Reef Point Road 1800000     NA   7667    NA   NA 2006-04-16        NA       NA
337655       Solano County       Vacaville    NA          7449 Stocking Lane  100000     NA 216493    NA   NA 2006-04-23 -121.9727 38.35381
337656       Solano County       Vacaville    NA          7450 Stocking Lane  100000     NA 216493    NA   NA 2006-04-23 -121.9727 38.35381
```

Let's look at 94400 which seems to be associated with San Mateo city in the data frame.
Looking up San Mateo, we see (e.g. https://www.zip-codes.com/city/ca-san-mateo.asp)
94401-4 and 94497. Also, we get 94010 from another site.  But no 94400.

Looking up American Canyon, we get a ZIP code of 94503. So we can fix this.

What about the ZIP 95434 code?
In the data set, this is associated with Fairfield city.
So let's look that up. We find 94534. So this is a typo. with the 4 and 5 transposed.
Let's fix this:
```
d$zip[ !is.na(d$zip) & d$zip == "95434 ] == "94534"
```

Similarly, Oakley is recorded as 94461 but should be 94561.

We can look up the street name and city combinations and find the ZIP code.
For example, searching "Stocking Lane, Vacaville ZIP code", we get 95688


We can use the Web form at
https://tools.usps.com/go/ZipLookupAction!input.action?mode=1&refresh=true.
And the file [zipCodeForm.R](zipCodeForm.R) contains code to create an R function
to programmatically query this form.


## County Names
We check the names of the counties:
```
unique(d$county)
```
```
 [1] Alameda County       Contra Costa County  Marin County         Napa County         
 [5] San Francisco County San Mateo County     Santa Clara County   Solano County       
 [9] Sonoma County        2003-09-07           2005-06-26          
11 Levels: 2003-09-07 2005-06-26 Alameda County Contra Costa County Marin County ... Sonoma County
```
We see the odd ones we identified earlier that are dates.
Having dropped those rows, we can use droplevels() to omit these from the factor.

Otherwise, the county names look correct. (Again, looks can be deceiving so try to verify
values programmatically.)

## City Names

We can look at the unique names of the cities to see if there are any odd ones.
However, since there are many, let's also compute how many there are of each and sort
them from most common to least common. This makes it easier to see unusual ones
and also see how close they are to common ones:
```
tt = sort(table(d$city), decreasing = TRUE)
tt
```
```
              San Francisco                     Oakland                  Santa Rosa 
                      22213                       17195                       11229 
                    Fremont                   Evergreen                     Antioch 
                      10782                        8930                        8636 
                    Vallejo                     Hayward                   Fairfield 
                       8632                        7986                        7985 
                    Concord                   Brentwood                    Richmond 
                       7717                        6881                        6560 
                  San Ramon                   Vacaville                   Livermore 
                       6214                        6079                        5989 
              West San Jose                Walnut Creek                 Santa Clara 
                       5524                        5347                        5197 
                  Berryessa                        Napa                   Sunnyvale 
                       4943                        4729                        4598 
                  San Mateo                 San Leandro                   Pittsburg 
                       4399                        4342                        4300 
                 Pleasanton                    Cambrian                      Novato 
                       4191                        4142                        3719 
                   Danville                      Dublin                Blossom Hill 
                       3620                        3614                        3568 
               Redwood City                   Daly City                  Union City 
                       3494                        3381                        3323 
                   Petaluma                      Gilroy                    Milpitas 
                       3239                        3113                        2913 
                     Oakley                 Willow Glen               Mountain View 
                       2907                        2881                        2869 
                   Berkeley Greater Downtown-metro Area                 Morgan Hill 
                       2823                        2810                        2810 
             Blossom Valley                     Alameda               East San Jose 
                       2780                        2727                        2642 
                   Martinez                  San Rafael               Castro Valley 
                       2628                        2624                        2589 
                   Hercules              South San Jose                   Cupertino 
                       2587                        2511                        2281 
        South San Francisco                   San Pablo                 Suisun City 
                       2236                        2215                        2200 
              Discovery Bay                      Newark                Rohnert Park 
                       2190                        2145                        2108 
                  Los Gatos                    Campbell               Pleasant Hill 
                       2087                        2073                        2017 
             North San Jose                   San Bruno                      Sonoma 
                       1973                        1892                        1860 
                    Benicia                     Almaden                     Windsor 
                       1813                        1766                        1667 
            American Canyon                 Mill Valley                    San Jose 
                       1643                        1595                        1592 
                 San Carlos                 Foster City                   Palo Alto 
                       1572                        1516                        1494 
                   Pacifica                       Dixon                   Bay Point 
                       1448                        1420                        1405 
                  Los Altos                    Saratoga                 San Lorenzo 
                       1396                        1376                        1364 
                  Rio Vista                  Menlo Park                     Belmont 
                       1302                        1183                        1133 
                 Burlingame                   Lafayette                  El Cerrito 
                       1112                        1097                        1070 
                 Sebastopol                Santa Teresa                  Emeryville 
                       1016                         968                         966 
                     Orinda                      Pinole                      Moraga 
                        915                         910                         884 
                El Sobrante                     Clayton                       Alamo 
                        860                         849                         822 
                 Cloverdale              East Palo Alto               Half Moon Bay 
                        811                         801                         801 
                 Healdsburg                    Millbrae                 San Anselmo 
                        701                         700                         694 
                     Albany                      Cotati                 Guerneville 
                        682                         664                         567 
                  Kentfield                   Sausalito                    Piedmont 
                        493                         493                         472 
          Belvedere/tiburon                Hillsborough                Corte Madera 
                        471                         462                         436 
                      Rodeo                   St Helena                     Fairfax 
                        429                         375                         352 
                   Larkspur                    Brisbane                 Forestville 
                        308                         296                         288 
                 Bodega Bay                  Kensington                   Calistoga 
                        256                         249                         246 
            Los Altos Hills                  San Martin                    Crockett 
                        222                         212                         173 
              Emerald Hills                     Pacheco                    Woodside 
                        172                         169                         148 
                 Yountville                  El Granada                   Penngrove 
                        142                         140                         135 
                Rose Garden                Monte Sereno                   Monte Rio 
                        130                         129                         115 
                    Montara                    Cazadero                    Atherton 
                        113                         112                         110 
                 Moss Beach                  Glen Ellen                      Angwin 
                        109                         107                          86 
                    Kenwood                    La Honda                     Tiburon 
                         79                          76                          71 
                  Inverness                   Sea Ranch              Portola Valley 
                         68                          66                          63 
                  Greenbrae                 Geyserville               Bethel Island 
                         59                          58                          57 
          Belvedere/Tiburon                  Occidental                 Pope Valley 
                         49                          48                          45 
                      Sunol                      Graton               Stinson Beach 
                         39                          38                          35 
                    Bolinas                        Ross                      Jenner 
                         33                          32                          30 
                   Woodacre                      Diablo                     Winters 
                         29                          27                          26 
               Dillon Beach               Forest Knolls                     Nicasio 
                         24                          24                          23 
                     Fulton                   Belvedere                   Lagunitas 
                         19                          17                          14 
                 Muir Beach                       Colma         Point Reyes Station 
                         13                          12                          11 
               San Geronimo              Unincorporated                 Point Reyes 
                         11                           8                           7 
                Camp Meeker                    Loma Mar                   Deer Park 
                          6                           6                           5 
                  Knightsen              Alameda County                   Annapolis 
                          5                           4                           4 
                 Port Costa                      Alviso               The Sea Ranch 
                          4                           3                           3 
                                      Boyes Hot Springs              Discoverey Bay 
                          2                           2                           2 
                  El Verano                      Elmira                    Stanford 
                          2                           2                           2 
                    Tomales                Walnut Grove                 `san Rafael 
                          2                           2                           1 
                   `vallejo                      Bodega                     Briones 
                          1                           1                           1 
                   Marshall                   Pescadero                    Rio Nido 
                          1                           1                           1 
                San Quentin         San Quentin Village                    Stockton 
                          1                           1                           1 
                      Tracy                 Watsonville 
                          1                           1 
```


Can you spot some problems?
More pairs of eyes is better than one - crowdsourcing this with colleagues helps if you are going to
do this visually.

A good thing to check for is NA and "", the empty string.
```
table(is.na(d$city) | d$city == "")
```
```
 FALSE   TRUE 
348191      2 
```
So there are two and these are "".  There are no NA values for the city.

We can find these records:
```
d[d$city == "",]
```
These are the records with NA values for all of the variables except county.
We should have discarded (or fixed) these rows when we found them.
We are refinding problems in different variables that we found earlier.

Again, like the ZIP codes, we can get a list of all city names in California or the Bay Area
and compare these. This will be harder than ZIP codes. ZIP codes are very structured. Names
of cities can be spelled differently, organized in different ways (Suisun and Suisun City,
Belvedere/Tiburon and Belvedere/tiburon and with a - rather than /).


It can be helpful to also sort the unique names alphabetically:
```
sort(names(tt))
```
```
  [1] ""                            "`san Rafael"                 "`vallejo"                   
  [4] "Alameda"                     "Alameda County"              "Alamo"                      
  [7] "Albany"                      "Almaden"                     "Alviso"                     
 [10] "American Canyon"             "Angwin"                      "Annapolis"                  
 [13] "Antioch"                     "Atherton"                    "Bay Point"                  
 [16] "Belmont"                     "Belvedere"                   "Belvedere/tiburon"          
 [19] "Belvedere/Tiburon"           "Benicia"                     "Berkeley"                   
 [22] "Berryessa"                   "Bethel Island"               "Blossom Hill"               
 [25] "Blossom Valley"              "Bodega"                      "Bodega Bay"                 
 [28] "Bolinas"                     "Boyes Hot Springs"           "Brentwood"                  
 [31] "Briones"                     "Brisbane"                    "Burlingame"                 
 [34] "Calistoga"                   "Cambrian"                    "Camp Meeker"                
 [37] "Campbell"                    "Castro Valley"               "Cazadero"                   
 [40] "Clayton"                     "Cloverdale"                  "Colma"                      
 [43] "Concord"                     "Corte Madera"                "Cotati"                     
 [46] "Crockett"                    "Cupertino"                   "Daly City"                  
 [49] "Danville"                    "Deer Park"                   "Diablo"                     
 [52] "Dillon Beach"                "Discoverey Bay"              "Discovery Bay"              
 [55] "Dixon"                       "Dublin"                      "East Palo Alto"             
 [58] "East San Jose"               "El Cerrito"                  "El Granada"                 
 [61] "El Sobrante"                 "El Verano"                   "Elmira"                     
 [64] "Emerald Hills"               "Emeryville"                  "Evergreen"                  
 [67] "Fairfax"                     "Fairfield"                   "Forest Knolls"              
 [70] "Forestville"                 "Foster City"                 "Fremont"                    
 [73] "Fulton"                      "Geyserville"                 "Gilroy"                     
 [76] "Glen Ellen"                  "Graton"                      "Greater Downtown-metro Area"
 [79] "Greenbrae"                   "Guerneville"                 "Half Moon Bay"              
 [82] "Hayward"                     "Healdsburg"                  "Hercules"                   
 [85] "Hillsborough"                "Inverness"                   "Jenner"                     
 [88] "Kensington"                  "Kentfield"                   "Kenwood"                    
 [91] "Knightsen"                   "La Honda"                    "Lafayette"                  
 [94] "Lagunitas"                   "Larkspur"                    "Livermore"                  
 [97] "Loma Mar"                    "Los Altos"                   "Los Altos Hills"            
[100] "Los Gatos"                   "Marshall"                    "Martinez"                   
[103] "Menlo Park"                  "Mill Valley"                 "Millbrae"                   
[106] "Milpitas"                    "Montara"                     "Monte Rio"                  
[109] "Monte Sereno"                "Moraga"                      "Morgan Hill"                
[112] "Moss Beach"                  "Mountain View"               "Muir Beach"                 
[115] "Napa"                        "Newark"                      "Nicasio"                    
[118] "North San Jose"              "Novato"                      "Oakland"                    
[121] "Oakley"                      "Occidental"                  "Orinda"                     
[124] "Pacheco"                     "Pacifica"                    "Palo Alto"                  
[127] "Penngrove"                   "Pescadero"                   "Petaluma"                   
[130] "Piedmont"                    "Pinole"                      "Pittsburg"                  
[133] "Pleasant Hill"               "Pleasanton"                  "Point Reyes"                
[136] "Point Reyes Station"         "Pope Valley"                 "Port Costa"                 
[139] "Portola Valley"              "Redwood City"                "Richmond"                   
[142] "Rio Nido"                    "Rio Vista"                   "Rodeo"                      
[145] "Rohnert Park"                "Rose Garden"                 "Ross"                       
[148] "San Anselmo"                 "San Bruno"                   "San Carlos"                 
[151] "San Francisco"               "San Geronimo"                "San Jose"                   
[154] "San Leandro"                 "San Lorenzo"                 "San Martin"                 
[157] "San Mateo"                   "San Pablo"                   "San Quentin"                
[160] "San Quentin Village"         "San Rafael"                  "San Ramon"                  
[163] "Santa Clara"                 "Santa Rosa"                  "Santa Teresa"               
[166] "Saratoga"                    "Sausalito"                   "Sea Ranch"                  
[169] "Sebastopol"                  "Sonoma"                      "South San Francisco"        
[172] "South San Jose"              "St Helena"                   "Stanford"                   
[175] "Stinson Beach"               "Stockton"                    "Suisun City"                
[178] "Sunnyvale"                   "Sunol"                       "The Sea Ranch"              
[181] "Tiburon"                     "Tomales"                     "Tracy"                      
[184] "Unincorporated"              "Union City"                  "Vacaville"                  
[187] "Vallejo"                     "Walnut Creek"                "Walnut Grove"               
[190] "Watsonville"                 "West San Jose"               "Willow Glen"                
[193] "Windsor"                     "Winters"                     "Woodacre"                   
[196] "Woodside"                    "Yountville"                 
```
Note the elements 2 and 3 - `san Rafael and `vallejo.
Firstly, they have a ` as a prefix.
Secondly, parts are lower case and would match another name in the vector!

Let's get rid of the ` in these.
We can use substring(), e.g.,
```
substring(c("`san Rafael", "`vallejo"), 2)
```
But we have to find these first in the d$city:
```
w = d$city %in% c("`san Rafael", "`vallejo")
d$city[w] = substring(d$city[w], 2)
```
However, we can use a  regular expression to clean these and this is much more general:
```
d$city = gsub("^`", "", d$city)
```


Did you find any other anomalies? 
What about Alameda County - element number 5.
That is a county name, not a city name. Let's see if there are others.
```
grep("County", d$city)
```
Let's look at these observations. Perhaps there is something else wrong with them, e.g. the county
was moved to the city and there was no county, or other columns/fields were permuted also.
```
d[grep("County", d$city),]
```
These are all Alameda County. The city is called Alameda. So we should change this:
```
d$city[d$city == "Alameda County"] = "Alameda"
```



We see Walnut Grove. I'm familiar with Walnut Creek and suspect that "Walnut Grove" should be Creek.
Let's look up Walnut Grove and also look at the obsevation(s).
```
d[d$city == "Walnut Grove",]
```
Sure enough Walnut Grove is a legitimate city name in Sacramento County.
Hang on, the observations say Solano County!
Which should it be.


