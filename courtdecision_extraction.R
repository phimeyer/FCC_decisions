# ---
# title: "Scraping Decision Texts from the German Federal Constitutional Court"
# author: "Philipp Meyer"
# date: "11/07/2019"
# ---

## Disclaimer
# This project is still a "work in progress". Unfortunately, not all steps are very efficient. Please contact me if you have ideas for a smoother workflow and also befor using it (p.meyer@ipw.uni-hannover.de)

## Description
# The target website is http://www.bundesverfassungsgericht.de/SiteGlobals/Forms/Suche/Entscheidungensuche_Formular.html?nn=5399828&language_=de.

# The Court also provides english translations of selected decisions (https://www.bundesverfassungsgericht.de/SiteGlobals/Forms/Suche/EN/Entscheidungensuche_Formular.html?language_=en). Since the basic structure of the english version is the same, this script should also work on the english text.

# We start by loading some relevant packages.

# packages
library(rvest)
library(magrittr)
library(stringr)

# Next we set a system sleep time in order to avoid to be kicked out

l <- sample(12:18, 1)  

## Start

# The court decision texts are stored in seperate pages with 10 decisions on one page. We need to set a factor with the range of the total page numbers. Unfortunatly, this needs to be done manually.

pages <- c(1:719)

# Next we text whether the identified html_node (extracted with the help of the selector gadget program) works. Each decision text is stored in a seperate link (e.g. https://www.bundesverfassungsgericht.de/SharedDocs/Entscheidungen/DE/2019/06/qs20190619_2bvq002319.html;jsessionid=831EF403AE825778FE0CC90940A4C6FE.1_cid393).

html <- read_html("http://www.bundesverfassungsgericht.de/SiteGlobals/Forms/Suche/Entscheidungensuche_Formular.html?nn=5399828&language_=de")
html
html  %>% html_nodes(".relevance100+a") %>% html_attr("href")
Since it works fine, we select all individual court decision links.

decisions <- links[grep("^SharedDocs/Entscheidungen/",links)] %>% strsplit(";") %>% sapply("[", 1)

# save the list for backup
write.csv(decisions, file = "decisions.txt", row.names = FALSE)

# Now we extract basic information to create filenames for each decision text. Since the Court provides general information on each decision in its links (20190619_2bvq002319), we extract these information to create the filenames. The decision information are the date of the decision (20190619) and the docket number of the decision (2bvq002319).

filenames <- decisions %>% strsplit("Entscheidungen/") %>% sapply("[", 2) %>% 
  strsplit("\\.") %>% sapply("[", 1)

# save the list for backup
write.csv(filenames, file = "filenames.txt", row.names = FALSE)

# extract the first two characters from the filenames
filenames <- str_sub(filenames, start= -19)

# Finally we can extract the full texts of each decision and store them as as .txt-file.

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