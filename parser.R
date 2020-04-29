library(rvest)
library(xml2)
library(dplyr)
library(stringr)

#Парсим сайт
URL <- "https://scr.hse.ru/publications/?search=15a2d174e97e87863dd28c8cfacb3ee1"
site <- read_html(URL)

#Смотрим сколько страниц есть в поиске
pagesVisible <- html_nodes(site,".pages__page") %>% html_text() %>% str_extract_all("\\d{1,9999}",simplify=T)
pages <- 1:max(as.numeric(pagesVisible))

#Читаем данные по каждой странице поиска
#Hello World
publication_data <- NULL

for(i in pages){
    
    #Подставляем номер страницы поиска
    search_page <- read_html(paste0("https://scr.hse.ru/publications/search/page",
                                    i,
                                    ".html?search=15a2d174e97e87863dd28c8cfacb3ee1"))
    
    #Вытаскиваем тип публикации
    type <- html_nodes(search_page,".pubs-item__category") %>% html_text()
    
    #Вытаскиваем название публикации
    title <- html_nodes(search_page,".pubs-item__title") %>% html_text()
    
    #Вытаскиваем ссылку на страницу публикации
    link <- html_nodes(search_page,".pubs-item__title .link_dark") %>% html_attr("href")
    
    #Эта функция проверяет есть ли нужная информация, и возвращает NA если её нет
    check_data <- function(x){
        if(length(x)==0) NA
        else if(x=="") NA
        else x
    }
    
    #Общая база, в которую будет подтягиваться информация из цикла
    publication_info <- NULL
    
    #Этот цикл проходит по каждой ссылке на публикацию чтобы вытащить оттуда данные (авторы, журнал и т.д.)
    for(k in link){
        
        #Читаем страницу публикации
        publication_page <- read_html(k)
        
        #Вытаскиваем мета-параметры, в которых записана информация
        info <- data.frame(name=html_nodes(publication_page,"meta") %>% html_attr("name"),
                            content=html_nodes(publication_page,"meta") %>% html_attr("content"),
                            stringsAsFactors = FALSE,
                            row.names=NULL)
        
        #Вытаскиваем все данные о публикации - автора, журнал, дату, выходные данные, ключевые слова
        parsed_info <- data.frame(authors=paste(info$content[which(info$name=="citation_author")],collapse="; ") %>% check_data(),
                                  source=(c(info$content[which(info$name=="citation_journal_title")],
                                            info$content[which(info$name=="citation_inbook_title")],
                                            ((html_nodes(publication_page,".pubs-page .pubs-item__info") %>% html_text())[1] %>% 
                                                 str_remove_all("\n|\t") %>% 
                                                 str_split(",",simplify=T))[1]) %>% 
                                      check_data())[1],
                                  date=info$content[which(info$name=="citation_publication_date")] %>% check_data(),
                                  issue=info$content[which(info$name=="citation_issue")] %>% check_data(),
                                  volume=info$content[which(info$name=="citation_volume")] %>% check_data(),
                                  pages=paste(c(info$content[which(info$name=="citation_firstpage")],
                                                info$content[which(info$name=="citation_lastpage")]),
                                              collapse=" - ") %>% check_data(),
                                  doi=info$content[which(info$name=="citation_doi")] %>% check_data(),
                                  keywords=info$content[which(info$name=="citation_keywords")] %>% check_data(),
                                  stringsAsFactors=FALSE,
                                  row.names=NULL)
       
        publication_info <- rbind(publication_info,parsed_info)
        
    }
    
    #Делаем единую базу данных по странице
    page_data <- data.frame(page_num=i,type=type,title=title,link=link,stringsAsFactors=FALSE,row.names=NULL) %>% 
        cbind(publication_info)
    
    #Сшиваем данные по странице с общим пуллом
    publication_data <- rbind(publication_data,page_data)
}

# Пишем полученные данные на всякий случай
write.csv2(publication_data,"publication_data.csv",row.names=FALSE)



