library("XML")

# Подгружаем сохранённую страницу
content <- htmlParse("additionalList.html")

tableNodes <- getNodeSet(content, '//tbody')
tbList <- lapply(tableNodes, readHTMLTable)
additionalList <- as.data.frame(tbList)

write.csv2(additionalList,"additionalDB.csv",row.names=FALSE)
