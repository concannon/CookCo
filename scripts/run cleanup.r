here::here()


setwd('/home/connor/CookCo/scripts')
      #dir <- here::here("scripts")

file.sources = list.files(getwd(), pattern="*.r")


print(file.sources[-2])




sapply(file.sources[-2], source)
