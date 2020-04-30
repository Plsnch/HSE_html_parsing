library("XML")

# записываем несколько скачанных html файлов в лист
temp <- list.files(pattern="*toread.html")

# читаем файлы
content <- lapply(temp, htmlParse)

# ищем в файлах признаки таблиц
tableNodes <- lapply(content, getNodeSet, '//tbody')

# читаем таблицы из листов
tbList <- lapply(unlist(tableNodes), readHTMLTable)
# объединяем несколько таблиц в одну и пишем в датафрейм
scopusDB <- as.data.frame(list.rbind(tbList))

# пишем в файл
write.csv2(scopusDB,"scopusDB.csv",row.names=FALSE)