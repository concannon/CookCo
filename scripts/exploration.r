
pkgs <- c("tidyverse", "here", "DescTools", "skimr",
          "lubridate", "sjmisc", "tictoc", "feather")

options(scipen=1000)
#Report: https://www.cookcountystatesattorney.org/sites/default/files/files/documents/ccsao_2017_data_report_180220.pdf


lapply(pkgs, require, character.only = T)
tic()

##Intake - all people arrested
int <- here::here("data", "intake.csv")

int <- read.csv(int)


##Initiation - all people charged
init <- here::here("data", "initiation.csv")

i <- read.csv(init)



##Dispositions
disp <- here::here("data", "dispositions.csv")

d <- read.csv(disp)



##Sentencing
sen <- here::here("data","sentencing.csv")

s <- read.csv(sen)


##Cleanup

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

rm(int)


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

rm(i)

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


rm(d)

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


rm(gbp)

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

rm(s)

###Joining final dataset
df <- int2 %>% 
  left_join(i2, by = "CASE_PARTICIPANT_ID") %>% 
  left_join(d3, by = "CASE_PARTICIPANT_ID") %>% 
  left_join(gbp2, by = "CASE_PARTICIPANT_ID") %>% 
  left_join(s2, by = "CASE_PARTICIPANT_ID")



df2 <- df %>%
  #head() %>% 
  to_dummy(EVENT, disp, race2, suffix = "label") %>% 
  bind_cols(df) %>% 
  replace_na(`EVENT_Indictment`:CASE_PARTICIPANT_ID, disposed.x, gbp.x,
             value = 0)



glimpse(df2)

#   mutate(CasesCommenced = ifelse(is.na(DefendantID)==F,1,0),
#          CasesDeclined = ifelse(IsDP==1,1,0),
#          CasesCharged = ifelse(IsDP==0,1,0),
#          CasesArraignSupreme = ifelse(is.na(ARCSurvive) & Indicted==1,1,0),
#          CasesArraigned = ifelse(IsDP==0 & is.na(ARCSurvive)==F,1,0),
#          CasesDisposedArraignment = ifelse(ARCSurvive==0,1,0),
#          CasesSurvivingArraignment = ifelse(ARCSurvive==1,1,0),
#          CasesIndicted = ifelse(Indicted==1,1,0),
#          CasesDisposed = ifelse(is.na(DspCondensed)==F,1,0),
#          CasesSentenced = ifelse(DspCondensed %in% c("Plea","Convicted"),1,0),
#          CasesDismissed = ifelse(DspCondensed %in% c("Evidence Dismissal","30.30 Speedy",
#                                                      "Other Non ACD/M Dismissal","ACD/M Dismissal"),1,0),
#          CasesDismissedACD = ifelse(DspCondensed %in% c("ACD/M Dismissal"),1,0),
#          CasesDismissedNONACD = ifelse(DspCondensed %in% c("Evidence Dismissal","30.30 Speedy",
#                                                            "Other Non ACD/M Dismissal"),1,0),
#          CasesBWO = ifelse(CaseStatus=="Outstanding Bench Warrant", 1,0))

table(duplicated(df2$CASE_PARTICIPANT_ID))
library(feather)


outfile <- here::here("data", "dataset.feather")
write_feather(df2, outfile)


qplot(df2$event_year)


toc()
