
pkgs <- c("tidyverse", "here", "DescTools", "skimr",
          "lubridate", "sjmisc", "tictoc", "feather")

options(scipen=1000)


lapply(pkgs, require, character.only = T)




##Intake - all people arrested
int <- here::here("data", "intake.csv")

int <- read.csv(int)


###Intake
int2 <- int %>% 
  mutate(ARREST_DATE = mdy_hms(ARREST_DATE),
         arrest_year = as.character(year(ARREST_DATE))) %>% 
  filter(ARREST_DATE <= today(),arrest_year >= 2012) %>% 
  dplyr::select(CASE_PARTICIPANT_ID,
                Offense_Category,
                PARTICIPANT_STATUS,
                ARREST_DATE,
                arrest_year,
                Offense_Category,
                AGE_AT_INCIDENT,
                GENDER,
                RACE,
                LAW_ENFORCEMENT_AGENCY
  )


filename <- here::here("data", "clean", "intake.feather")

write_feather(int2, filename)


rm(list=ls())
