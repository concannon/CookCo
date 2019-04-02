
pkgs <- c("tidyverse", "here", "DescTools", "skimr",
          "lubridate", "sjmisc", "tictoc", "feather")

options(scipen=1000)
#Report: https://www.cookcountystatesattorney.org/sites/default/files/files/documents/ccsao_2017_data_report_180220.pdf


lapply(pkgs, require, character.only = T)


print(tic())
##Sentencing
sen <- here::here("data","sentencing.csv")

s <- read.csv(sen)



###Sentences
s2 <- s %>% 
  filter(SENTENCE_PHASE == "Original Sentencing",
         PRIMARY_CHARGE == "true") %>% 
  mutate(class_order = case_when(CLASS == "X" ~ 1,
                                 CLASS == "1" ~ 2,
                                 CLASS == "2" ~ 3,
                                 CLASS == "3" ~ 4,
                                 CLASS == "4" ~ 5,
                                 TRUE ~ 9),
         sentenced = 1 
  ) %>% 
  select(CASE_PARTICIPANT_ID,
         CLASS,
         class_order,
         SENTENCE_TYPE,
         COMMITMENT_TYPE,
         COMMITMENT_TERM,
         COMMITMENT_UNIT,
         LENGTH_OF_CASE_in_Days
  ) %>% 
  group_by(CASE_PARTICIPANT_ID) %>% 
  arrange(class_order) %>% 
  filter(row_number()==1)


filename <- here::here("data", "clean", "sentences.feather")

write_feather(s2, filename)

print(toc())
rm(list=ls())
print('done!')
