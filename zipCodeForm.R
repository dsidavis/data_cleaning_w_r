library(RCurl)
library(XML)
txt = getURL("https://tools.usps.com/go/ZipLookupAction!input.action?mode=1&refresh=true")
doc = htmlParse(txt, asText = TRUE)
docName(doc) = "https://tools.usps.com/go/ZipLookupAction!input.action"

library(RHTMLForms)
form = getHTMLFormDescription(doc)
form = form$ziplookup1

fun = createFunction(form)

o = fun(tAddress = "Stocking Lane", tCity = "Vacaville", sState = "CA - California", .opts = list(verbose = TRUE, followlocation = TRUE))
z = htmlParse(o)
xmlValue(getNodeSet(z, "//span[@class = 'zip']")[[1]])


reader = function(txt)
{
    z = htmlParse(txt)
    xmlValue(getNodeSet(z, "//span[@class = 'zip']")[[1]])
}

fun = createFunction(form, reader = reader)
o = fun(tAddress = "Stocking Lane", tCity = "Vacaville", sState = "CA - California", .opts = list(followlocation = TRUE))

