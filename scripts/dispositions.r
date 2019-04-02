pkgs <- c("tidyverse", "here", "DescTools", "skimr",
          "lubridate", "sjmisc", "tictoc", "feather")

options(scipen=1000)
#Report: https://www.cookcountystatesattorney.org/sites/default/files/files/documents/ccsao_2017_data_report_180220.pdf


lapply(pkgs, require, character.only = T)




##Dispositions
disp <- here::here("data", "dispositions.csv")

d <- read.csv(disp)




###Dispositions
d2 <- d %>% 
  mutate(class_order = case_when(CLASS == "X" ~ 1,
                                 CLASS == "1" ~ 2,
                                 CLASS == "2" ~ 3,
                                 CLASS == "3" ~ 4,
                                 CLASS == "4" ~ 5,
                                 TRUE ~ 9),
         disp = forcats::fct_lump(CHARGE_DISPOSITION, prop = .005),
         disposed = 1,
         gbp = case_when(disp %in% c("Plea Of Guilty", "Finding Guilty", "Verdict Guilty") ~ 1, 
                         TRUE ~ 0),
         race2 = case_when(RACE %in% c("Asian", "ASIAN") ~ "Asian",
                           RACE %in% c("Black") ~ "Black",
                           RACE %in% c("White", "CAUCASIAN") ~ "White",
                           RACE %in% c("HISPANIC", "White [Hispanic or Latino]", "White/Black [Hispanic or Latino]") ~ "Latino",
                           
                           TRUE ~ "Other")
  ) %>% 
  dplyr::select(CASE_PARTICIPANT_ID,
                race2,
                PRIMARY_CHARGE,
                disposed,
                disp,
                gbp,
                CHARGE_DISPOSITION,
                CHARGE_DISPOSITION_REASON,
                JUDGE,
                OFFENSE_TITLE,
                CLASS,
                class_order) 



d3 <- d2 %>% 
  group_by(CASE_PARTICIPANT_ID) %>% 
  arrange(class_order) %>% 
  filter(row_number()==1)


###Guilty Charges
gbp <- d2 %>% 
  filter(gbp == 1) %>% 
  select(-race2) %>% 
  rename(gbp_disp = disp) 



gbp2 <- gbp %>% 
  group_by(CASE_PARTICIPANT_ID) %>% 
  arrange(class_order) %>% 
  filter(row_number()==1)



filename <- here::here("data", "clean", "dispositions.feather")

write_feather(d2, filename)



filename <- here::here("data", "clean", "gbp.feather")

write_feather(gbp2, filename)

rm(list=ls())