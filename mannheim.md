See chapter 1 in Data Science in R: A Case Studies Approach


Data files look like
```
# timestamp=2006-02-11 08:31:58
# usec=250
# minReadings=110
t=1139643118358;id=00:02:2D:21:0F:33;pos=0.0,0.0,0.0;degree=0.0;00:14:bf:b1:97:8a=-38,2437000000,3;00:14:bf:b1:97:90=-56,2427000000,3;00:0f:a3:39:e1:c0=-53,2462000000,3;00:14:bf:b1:97:8d=-65,2442000000,3;00:14:bf:b1:97:81=-65,2422000000,3;00:14:bf:3b:c7:c6=-66,2432000000,3;00:0f:a3:39:dd:cd=-75,2412000000,3;00:0f:a3:39:e0:4b=-78,2462000000,3;00:0f:a3:39:e2:10=-87,2437000000,3;02:64:fb:68:52:e6=-88,2447000000,1;02:00:42:55:31:00=-84,2457000000,1
t=1139643118744;id=00:02:2D:21:0F:33;pos=0.0,0.0,0.0;degree=0.0;00:14:bf:b1:97:8a=-38,2437000000,3;00:0f:a3:39:e1:c0=-54,2462000000,3;00:14:bf:b1:97:90=-56,2427000000,3;00:14:bf:3b:c7:c6=-67,2432000000,3;00:14:bf:b1:97:81=-66,2422000000,3;00:14:bf:b1:97:8d=-70,2442000000,3;00:0f:a3:39:e0:4b=-79,2462000000,3;00:0f:a3:39:dd:cd=-73,2412000000,3;00:0f:a3:39:e2:10=-83,2437000000,3;02:00:42:55:31:00=-85,2457000000,1
```
This shows 2 records. 
+ Each starts with t=...
+ Entire record on a single line.
+ Initial part consists of elements separated by ;
   + t=value
   + id=value
   + pos=x,y,z
   + degree=value
+ Then variable number of terms of the form
```
  00:14:bf:b1:97:8a=-38,2437000000,3
```
    + left hand side of `=` is a MAC address
    + right hand side has 3 values
	   + wireless signal value
	   + channel
	   + type of node (fixed or mobile)
	   

## Challenge
Read these data into R.

What format do we want?


For the fixed part of each record, we want 
the time (t), the MAC address of the recording device (id),
the x, y and z components of the recording device (pos),
and the orientation of the device (degree).
Time should be a POSIXt vector.
The id should be a factor.
The x, y and z vectors should be numeric,
as should the orientation/degree.

The interesting part comes for the measurements to the devices we detect in this record.  Each
record will have a potentially different set of detected devices.  Some devices are stationary while
others come and go.  Do we have a separate column for each of these devices with NA values for many
of them for each record.  Or do we have a single column that gives the MAC address for each detected
device along with the signal, channel and type.  If we use the latter, we have a separate row for
each detected device within a single record.  So each line of the file would give rise to to
multiple rows in the data frame.  The number of rows for each record in the file would be the number
of devices detected in that record.
```
t1, id, x, y, z, degree, MAC1, signal1, channel1, type1
t1, id, x, y, z, degree, MAC2, signal2, channel2, type2
 ...
t2, id, x, y, z, degree, MAC1, signal1, channel1, type1 
t2, id, x, y, z, degree, MAC2, signal2, channel2, type2
t2, id, x, y, z, degree, MAC3, signal3, channel3, type3
..
```

This second format seems to make the most sense for what
we want to do with the data afterwards.
It also means that we don't need to know the set of detected
devices before we create the data frame. 
If we were to have a column for each detected MAC device (and
associated columns for 


In fact, we do know that there are only 6 stationary devices
in the experiment and these are the ones in which we are interested.
So we could create a data frame of the form
```
t, id, x, y, z, degree, MAC1, signal1, channel1, type1, MAC2, signal2, channel2, type2, ..., MAC6, signal6, channel6, type6
```
We would have to know the MAC addresses for these 6 ahead of time
and we would remove  information about all the others.



So we will use the more general approach 
```
t1, id, x, y, z, degree, MAC1, signal1, channel1, type1
```
with as many rows for each record in the file as there are 
devices detected in that record.


## Reading the Records
We cannot use read.table() or any of its related functions.
The data are not in tabular form. We need to explicitly reorganize
them into rows in a data frame.

We'll process each line so we can start with readLines().
```
ll = readLines("Data/Mannheim/offline_subset")
```

We need to discard the comment lines.
We might be tempted to discard the first 3 lines since they start
with a #.
However, there are other lines in the file that also start with #.
In other words, the first three lines are not a header for the entire
file, but  just a part.
So we'll discard these with
```
ll = ll[ !grepl("^#", ll) ]
```
Alternatively, we could use
```
ll = ll[ grep("^#", ll, invert = TRUE) ]
```
or
```
ll = grep("^#", ll, value = TRUE, invert = TRUE) 
```


Let's look at a single record:
```
t=1139643118358;id=00:02:2D:21:0F:33;pos=0.0,0.0,0.0;degree=0.0;00:14:bf:b1:97:8a=-38,2437000000,3;00:14:bf:b1:97:90=-56,2427000000,3;00:0f:a3:39:e1:c0=-53,2462000000,3;00:14:bf:b1:97:8d=-65,2442000000,3;00:14:bf:b1:97:81=-65,2422000000,3;00:14:bf:3b:c7:c6=-66,2432000000,3;00:0f:a3:39:dd:cd=-75,2412000000,3;00:0f:a3:39:e0:4b=-78,2462000000,3;00:0f:a3:39:e2:10=-87,2437000000,3;02:64:fb:68:52:e6=-88,2447000000,1;02:00:42:55:31:00=-84,2457000000,1
```
We want this to map to 
```
                     t degree x y z               mac signal    channel devType
1  2006-02-10 23:31:58      0 0 0 0 00:14:bf:b1:97:8a    -38 2437000000  mobile
2  2006-02-10 23:31:58      0 0 0 0 00:14:bf:b1:97:90    -56 2427000000  mobile
3  2006-02-10 23:31:58      0 0 0 0 00:0f:a3:39:e1:c0    -53 2462000000  mobile
4  2006-02-10 23:31:58      0 0 0 0 00:14:bf:b1:97:8d    -65 2442000000  mobile
5  2006-02-10 23:31:58      0 0 0 0 00:14:bf:b1:97:81    -65 2422000000  mobile
6  2006-02-10 23:31:58      0 0 0 0 00:14:bf:3b:c7:c6    -66 2432000000  mobile
7  2006-02-10 23:31:58      0 0 0 0 00:0f:a3:39:dd:cd    -75 2412000000  mobile
8  2006-02-10 23:31:58      0 0 0 0 00:0f:a3:39:e0:4b    -78 2462000000  mobile
9  2006-02-10 23:31:58      0 0 0 0 00:0f:a3:39:e2:10    -87 2437000000  mobile
10 2006-02-10 23:31:58      0 0 0 0 02:64:fb:68:52:e6    -88 2447000000   fixed
11 2006-02-10 23:31:58      0 0 0 0 02:00:42:55:31:00    -84 2457000000   fixed
```
(Note that we have dropped the id column. It turns out that in this data set, 
only one measurement device was used.)


To get the fixed part that is repeated for each detected device, we
want the values from
```
t=1139643118358;id=00:02:2D:21:0F:33;pos=0.0,0.0,0.0;degree=0.0
```

Throughout the record we see that values are separated by ; and ,.
However each top-level element is separated by a ;.
So we might use
```
f = strsplit(ll[1], ";")[[1]]
```
We can then extract the first 4 elements corresponding to t, id, pos and degree.
Each of these are in the form `name=value(s)`. So we would
then extract the values
```
r1 = gsub(".*=", "", f[1:4])
```
giving us
```
[1] "1139643118358"     "00:02:2D:21:0F:33" "0.0,0.0,0.0"       "0.0"  
```

We can then split the third of these into x, y, and z values with
```
as.numeric(strsplit(r1[3], ",")[[1]])
```

We can then arrange these as a vector say, (dropping the id)
```
as.numeric(c(r1[c(1, 4)], strsplit(r1[3], ",")[[1]]))
```


Looking at the detected devices, again the element are separated by ;
So we can extract them with 
```
f[-(1:4)]
```
Then  we can process each of these into a row and then rbind them together.



## An Alternative Approach
The values we want are in reliable positions
and are either after a `=` characer, a `,` character or
a `;`.
So we can split the line wherever any of these occur and then
fetch the next element.
```
r1 = strsplit(ll[1], "[,;=]")[[1]]
```
giving
```
 [1] "t"                 "1139643118358"     "id"                "00:02:2D:21:0F:33"
 [5] "pos"               "0.0"               "0.0"               "0.0"              
 [9] "degree"            "0.0"               "00:14:bf:b1:97:8a" "-38"              
[13] "2437000000"        "3"                 "00:14:bf:b1:97:90" "-56"              
[17] "2427000000"        "3"                 "00:0f:a3:39:e1:c0" "-53"              
[21] "2462000000"        "3"                 "00:14:bf:b1:97:8d" "-65"              
[25] "2442000000"        "3"                 "00:14:bf:b1:97:81" "-65"              
[29] "2422000000"        "3"                 "00:14:bf:3b:c7:c6" "-66"              
[33] "2432000000"        "3"                 "00:0f:a3:39:dd:cd" "-75"              
[37] "2412000000"        "3"                 "00:0f:a3:39:e0:4b" "-78"              
[41] "2462000000"        "3"                 "00:0f:a3:39:e2:10" "-87"              
[45] "2437000000"        "3"                 "02:64:fb:68:52:e6" "-88"              
[49] "2447000000"        "1"                 "02:00:42:55:31:00" "-84"              
[53] "2457000000"        "1"                
```
For the fixed part of the record, we want elements 2, 4, 6, 7, 8 and 10
corresponding to the values of t, id, pos (x, y, z) and degree.

The values for the detected devices are all organized as 
MAC, signal, channel and type. We can arrange these into a matrix:
```
detected = matrix(r1[-(1:10)], , 4, byrow = TRUE)
```

Then, we can assemble the fixed part into a matrix with as many rows as 
there are in the detected device matri, repeating the fixed part that many times:
```
fixed = matrix(r1[c(2, 6, 7, 8, 10)], nrow(detected), 5, byrow = TRUE)
```
And finally, we can cbind() these together
```
cbind(fixed, detected)
```

We can do this for each record in the file with lapply()
and end up with a list of 9 columnn matrices:
```
matrices = lapply(ll, processRecord)
```
We can then stack these together with 
```
ans = do.call(cbind, matrices)
```

Finally, we add names to the columns and convert the columns
to numbers, factors and POSIXt types.
