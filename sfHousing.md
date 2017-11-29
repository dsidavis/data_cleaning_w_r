# Steps

1. Start with csv - read it in
1. summary(), check classes of each column
1. Check that NA occur together
  - 2 are trash, 2 are OK
  - OK ones are adjacent to eachother
  - Look up 3rd one, look at the zip
  - Check that cities are in the correct county
1. nchar of zip - table
1. check that zips are all in Bay area
1. zipcodestogo.com/California
  - Have 4 zip codes not in CA, e.g. 95434
1. table of each column - summary hides factors
1. sort(table(h$city)) 
  - have "XXX county", " ", "`XXX", 
1. Walnut Grove - is it part of the Bay area, check that Davis is not
   included
1. Street - how many have not letters, anticipate the worst. Think
   about what could have happened to corrupt the data. 
  - We know some are weird - saw there are 4 NAs. 
  - We want to go back and look for more


When we find an issue, should fix otherwise we will continue to find
it

1. Do reverse-lookup for the historical record, try to find the
   original data
1. Start looking at the relationships between them
1. range of dates
1. Year 
  - "99", is this missing, 1999, or 1899
  - plot the density of the year
  - Look at years before 1850, after 2010
1. Look at price and bedroom, lsqft, bsqft
  - are these reasonable values, e.g., lot sqft less than building
    sqft
  - How we check: Looking up the addresses, 
1. Year == 1
   
1. Is number of houses sold proportional to county size/population
1. Look at distribution of bdrm, etc.
1. adist on city - find ones that are likely to be spelling mistakes


We could use the Zillow API to fix these up. 
  
### Plotting

1. Look at joint distributions of variables
1. What proportion have the bsqft is more than lsqft (e.g., no yard,
   multi-story building), are they in dense cities? or in the
   country-side? 
1. Lat / Long - make map, make sure R's data is correct

## Zoonotics data

Get PDF from the sp$PDF 

Clean the "¥Ë_" out - 
(original) isolation

1. Find no numbers,
1. Find start with "E"
1. Look for the ones which have %d-%m-%Y,
1. programmatically generate month names (why? gets the locale correct)
1. Find pattern, grep for that, then look for the ones that don't match
1. that pattern.
1. Then look for second pattern. 
1. For the range, want to split and keep the other value and shove in to
1. the Year_End column.
1. Looking for day of month, should do properly - has to be between
   0-31, programmatically generate the alternation. 
1. 
