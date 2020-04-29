library(rvest)
library(xml2)
library(dplyr)
library(stringr)

#Парсим сайт
URL <- "https://scr.hse.ru/publications/?search=15a2d174e97e87863dd28c8cfacb3ee1"
site <- read_html(URL)

#Смотрим сколько страниц есть в поиске
pages <- html_nodes(site,".pages__page") %>% html_text() %>% str_extract_all("\\d{1,9999}",simplify=T)

#Читаем данные по каждой странице поиска

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
    
    #Вытаскиваем информацию о публикации - авторы, ресурс, год, выходные данные
    info <- html_nodes(search_page,".pubs-item__info") %>% html_text() %>% str_remove_all("\n|\t")
    
    #Вытаскиваем ссылку на страницу публикации
    link <- html_nodes(search_page,".pubs-item__title .link_dark") %>% html_attr( "href")
    
    #Делаем единую базу данных по странице
    page_data <- data.frame(page_num=i,type=type,title=title,info=info,link=link,row.names=NULL)
    
    #Сшиваем данные по странице с общим пуллом
    publication_data <- rbind(publication_data,page_data)
}

# Пишем полученные данные на всякий случай
write.csv2(publication_data,"publication_data.csv",row.names=FALSE)
