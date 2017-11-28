
Consider the Minnesota barley data set with data from
6 farm sites, 2 growing seasons - 1931 and 1932 - and 10 different varieties of barley.

Are there any anomolies?

library(lattice)
data(barley)


class(barley)
nrow(barley)
sapply(barley, class)
summary(barley)

densityplot( ~ yield, data = barley)


densityplot( ~ yield, data = barley, groups = site)

densityplot( ~ yield, data = barley, groups = year)


dotplot(variety ~ yield | year, groups = site, data=barley)


dotplot(variety ~ yield | site, groups = year, data=barley)
	 

http://blog.revolutionanalytics.com/2014/07/theres-no-mistake-in-the-barley-data.html
