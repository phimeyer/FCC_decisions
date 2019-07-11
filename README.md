---
title: "Scraping Decision Texts from the German Federal Constitutional Court"
author: "Philipp Meyer"
date: "11/07/2019"
output: 
html_document
---

## Description

This script is for scraping the online aviable court decisions of the Federal Constitutional Court in Germany. 

```{r}
# packages
library(rvest)
library(magrittr)
library(stringr)
```

## Start

Our target website is http://www.bundesverfassungsgericht.de/SiteGlobals/Forms/Suche/Entscheidungensuche_Formular.html?nn=5399828&language_=de

```{r}
# set an sample for sys.sleep and avoid to be kicked out
l <- sample(12:18, 1)  
```

```{r}
# set the number of website pages pages; unfortunately this needs to be updated manually
pages <- c(1:719)
```


```{r}
# Test whether we use the exact html node (html_node was extracted with the help of selector gadget)
html <- read_html("http://www.bundesverfassungsgericht.de/SiteGlobals/Forms/Suche/Entscheidungensuche_Formular.html?nn=5399828&language_=de")
html
html  %>% html_nodes(".relevance100+a") %>% html_attr("href")
```

```{r}
# select the court decisions' links
decisions <- links[grep("^SharedDocs/Entscheidungen/",links)] %>% strsplit(";") %>% sapply("[", 1)

# and saving the list for backup
write.csv(decisions, file = "decisions.txt", row.names = FALSE)
```

```{r}
# extract the filenames
filenames <- decisions %>% strsplit("Entscheidungen/") %>% sapply("[", 2) %>% 
  strsplit("\\.") %>% sapply("[", 1)
  
# and saving the list for backup
write.csv(filenames, file = "filenames.txt", row.names = FALSE)
```

```{r}
# extract the first two characters from the filenames
filenames <- str_sub(filenames, start= -19)
```

```{r}
# getting the full text of the court decisions
#  first testing for one text
case <- read_html("http://www.bundesverfassungsgericht.de/SharedDocs/Entscheidungen/DE/2017/10/rk20171011_2bvr175817.html")
casetext <- case %>% html_nodes("#wrapperContent") %>% html_text()
cat(casetext, file="testing.txt", sep="", append=FALSE)

# second getting all texts by using a for-loop
for (i in 1:length(decisions)) {
  case <- read_html(paste("http://www.bundesverfassungsgericht.de/", decisions[i], sep = "", Sys.sleep(l)))
  case %>% html_nodes("#wrapperContent") %>% html_text() %>%
    cat(file=paste(filenames[i], ".txt", sep = ""), sep="", append=FALSE)
 }
```
