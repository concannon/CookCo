
library(feather)

tic()
dir <- here::here("data", "clean")


files <- list.files(dir)


for (i in files){
  f <- here::here("data", "clean", i)
  nm <- gsub(".feather", "", i)
  print(nm)
  ?gsub
  print(f)
  print(i)
  assign(nm, read_feather(f))
}



df <- intake %>% 
  left_join(initiation, by = "CASE_PARTICIPANT_ID") %>% 
  left_join(dispositions, by = "CASE_PARTICIPANT_ID") %>% 
  left_join(gbp, by = "CASE_PARTICIPANT_ID") %>% 
  left_join(sentences, by = "CASE_PARTICIPANT_ID")



df2 <- df %>%
  #head() %>% 
  to_dummy(EVENT, disp, race2, suffix = "label") %>% 
  bind_cols(df) %>% 
  replace_na(`EVENT_Indictment`:CASE_PARTICIPANT_ID, disposed.x, gbp.x,
             value = 0) %>% 
  dplyr::select(-OFFENSE_TITLE.y, -PRIMARY_CHARGE.y, -disposed.y, -gbp.y, 
                -CHARGE_DISPOSITION.y, -CHARGE_DISPOSITION_REASON.y, 
                -JUDGE.y, -CLASS.y, -class_order.y)




glimpse(df2)

outfile <- here::here("data", "dataset.feather")
write_feather(df2, outfile)


qplot(df2$event_year)


toc()