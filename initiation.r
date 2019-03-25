pkgs <- c("tidyverse", "here", "DescTools", "skimr",
          "lubridate", "sjmisc", "tictoc", "feather")

options(scipen=1000)
#Report: https://www.cookcountystatesattorney.org/sites/default/files/files/documents/ccsao_2017_data_report_180220.pdf


lapply(pkgs, require, character.only = T)


##Initiation - all people charged
init <- here::here("data", "initiation.csv")

i <- read.csv(init)



###Initiation
i2 <- i %>% 
  dplyr::filter(PRIMARY_CHARGE == "true") %>% 
  mutate(EVENT_DATE = mdy_hms(EVENT_DATE),
         event_year = as.character(year(EVENT_DATE))) %>% 
  filter(EVENT_DATE <= today(),event_year >= 2012) %>% 
  dplyr::select(CASE_PARTICIPANT_ID,
                OFFENSE_TITLE,
                EVENT,
                EVENT_DATE,
                event_year
  )




filename <- here::here("data", "clean", "initiation.feather")

write_feather(i2, filename)


rm(list=ls())