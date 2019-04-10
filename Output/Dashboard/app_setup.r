
## Setup ----------------------------------------------------------------------
pkgs <- c("shinydashboard","dplyr","tidyr","here", "tidyverse",
          "feather", "stringr", "DT", "scales", "leaflet", "plotly")
lapply(pkgs, require, character.only = T)


infile <- here::here("data", "dataset.feather")

df <- read_feather(infile)

df$Offense_Category <- as.character(df$Offense_Category)


glimpse(df)
## Baseline Metrics -----------------------------------------------------------
overall_n <- nrow(df)
overall_median_age <- median(df$AGE_AT_INCIDENT)

# 
# 
# branch_metrics <- 
#   
#   df %>% 
#   filter(!str_detect(`Home Branch`, 
#                      paste(c("Lake Trust Cre","Spare Branch", "Admin"),
#                            collapse = "|"))) %>% 
#   group_by(`Home Branch`) %>% 
#   summarise(Members = n(),
#             `Total Balance` = sum(sum_bal, na.rm = T)/1000000,
#             `Average Balance` = mean(avg_bal, na.rm = T)/1000,
#             `Products` = mean(cnt_prod, na.rm = T),
#             `External Products` = mean(EXT, na.rm = T),
#             `Average Tenure` = mean(tenure, na.rm = T),
#             `Opened External Product within 1 year` = sum(ifelse(`1yr_EXT`>0, 1, 0), na.rm = T),
#             `Checking` = sum(ifelse(CK > 0 ,1, 0), na.rm = T),
#             `Savings` = sum(ifelse(SAV > 0 ,1, 0), na.rm = T),
#             `External` = sum(ifelse(EXT > 0 ,1, 0), na.rm = T),
#             `CD's` = sum(ifelse(TD > 0 ,1, 0), na.rm = T)
#             
#             
#   ) %>% 
#   mutate(#`Percent External Product <1 year` = (`Opened External Product within 1 year`/ Members)*100,
#     `Percent Checking` = Checking/Members,
#     `Percent Savings` = Savings/Members,
#     `Percent External` = External/Members,
#     `Percent CD's` = `CD's`/Members
#   )
# 
# 
# 
# 
# ## Create Plots ---------------------------------------------------------------
# 
# base_plot_age  <- 
#   df %>% 
#   ggplot(aes(`Age in Years`))+
#   geom_density(fill = "grey80")+
#   geom_vline(aes(xintercept = mean(`Age in Years`, na.rm = T)),
#              colour = "grey80", size = 1)
# 
# 
# base_plot_income  <- 
#   df %>% 
#   filter(!is.na(`Income Display`)) %>% 
#   ggplot(aes(`Income Display`))+
#   geom_histogram(stat = "count", fill = "grey80", aes(y=..count../sum(..count..)))


## LTCU corporate colors ------------------------------------------------------
ltcu_colors <- c(
  `blue`       = "#236192",
  `green`      = "#789D4A",
  `purple`     = "#45308A",
  `light blue` = "#0073BC",
  `kellygreen` = "#078754",
  `red` 	   = "#D52C27")

ltcu_cols <- function(...) {
  cols <- c(...)
  
  if (is.null(cols))
    return (ltcu_colors)
  
  ltcu_colors[cols]
}



ltcu_palettes <- list(
  `main`  = ltcu_cols("blue", "green", "purple"),
  
  `cool`  = ltcu_cols("blue", "green"),
  
  `hot`   = ltcu_cols("purple", "orange", "red")
)


ltcu_pal <- function(palette = "main", reverse = FALSE, ...) {
  pal <- ltcu_palettes[[palette]]
  
  if (reverse) pal <- rev(pal)
  
  colorRampPalette(pal, ...)
}

ltcu_pal("cool")(10)


scale_color_ltcu <- function(palette = "main", discrete = TRUE, reverse = FALSE, ...) {
  pal <- ltcu_pal(palette = palette, reverse = reverse)
  
  if (discrete) {
    discrete_scale("colour", paste0("ltcu_", palette), palette = pal, ...)
  } else {
    scale_color_gradientn(colours = pal(256), ...)
  }
}


scale_fill_ltcu <- function(palette = "main", discrete = TRUE, reverse = FALSE, ...) {
  pal <- ltcu_pal(palette = palette, reverse = reverse)
  
  if (discrete) {
    discrete_scale("fill", paste0("ltcu_", palette), palette = pal, ...)
  } else {
    scale_fill_gradientn(colours = pal(256), ...)
  }
}
