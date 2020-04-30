library("XML")

# Подгружаем сохранённую страницу
content <- htmlParse("квартилиWoS.html")

tableNodes <- getNodeSet(content, '//tbody')
tbList <- lapply(tableNodes, readHTMLTable)
wosDB <- as.data.frame(tbList)

write.csv2(wosDB,"wosDS.csv",row.names=FALSE)
