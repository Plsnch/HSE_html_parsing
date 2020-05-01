library("tibble")

publication_data <- read.csv("publicationData.csv")

# Читаем доступные базы данных по квартилям
wos_data <- read.csv2("wosDB.csv", stringsAsFactors = FALSE)
scopus_data <- read.csv2("scopusDB.csv", stringsAsFactors = FALSE)
additional_data <- read.csv2("additionalDB.csv", stringsAsFactors = FALSE)

# Создаём будущую группирующую переменную для общей таблицы квартилей
# и создаём "дополнительный" квартиль для дополнительного списка
# подгоняем количество столбцов
wos_data$typeOfDB <- factor(c(rep("WoS", length(wos_data$Название.журнала.в.WoS))))
wos_data <- add_column(wos_data, eISSN = c(rep(NA, length(wos_data$Название.журнала.в.WoS))), .after = 2)
scopus_data$typeOfDB <- factor(c(rep("Scopus", length(scopus_data$Название.журнала))))
additional_data$Quartile <- c(rep("additional", length(additional_data$Оригинальное.название)))
additional_data$typeOfDB <- factor(c(rep("Additional", length(additional_data$Оригинальное.название))))

# приводим названия к общему виду
colnames(wos_data) <- c("JournalName", "ISSN", "eISSN", "Quartile", "typeOfDB")
colnames(scopus_data) <- c("JournalName", "ISSN", "eISSN", "Quartile", "typeOfDB")
colnames(additional_data) <- c("JournalName", "ISSN", "eISSN", "Quartile", "typeOfDB")

# приводим к единому виду регистр названий журналов
publication_data$source <- toupper(publication_data$source)
wos_data$JournalName <- toupper(wos_data$JournalName)
scopus_data$JournalName <- toupper(scopus_data$JournalName)
additional_data$JournalName <- toupper(additional_data$JournalName)

# если вдруг нужен большой справочник
megaDB <- rbind(wos_data, scopus_data, additional_data)

# расставляем значения квартилей из баз по столбцам таблицы публикаций
for (j in 1:length(publication_data$title)) {
  publication_data$QuartileWoS[j] <- wos_data$Quartile[which(publication_data$source[j] == wos_data$JournalName)] %>% check_data()
  publication_data$QuartileScopus[j] <- scopus_data$Quartile[which(publication_data$source[j] == scopus_data$JournalName)] %>% check_data()
  publication_data$QuartileAdditional[j] <- additional_data$Quartile[which(publication_data$source[j] == additional_data$JournalName)] %>% check_data()
  
  # проверяем на наличие пропусков
  check_data <- function(x){
    if(length(x)==0) NA
    else if(x=="") NA
    else x}
}

# пишем в файл
write.csv2(publication_data, "publicationDataQ.csv", row.names = FALSE, fileEncoding = "UTF-8")



