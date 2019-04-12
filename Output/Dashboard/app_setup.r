
## Setup ----------------------------------------------------------------------
pkgs <- c("shinydashboard","dplyr","tidyr","here", "tidyverse",
          "feather", "stringr", "DT", "scales", "leaflet", "plotly")
lapply(pkgs, require, character.only = T)


infile <- here::here("data", "dataset.feather")

df <- read_feather(infile)

df$Offense_Category <- as.character(df$Offense_Category)
df$disp <- as.character(df$disp)

## Baseline Metrics -----------------------------------------------------------

overall_n <- nrow(df)
overall_median_age <- median(df$AGE_AT_INCIDENT)

## Colors ---------------------------------------------------------------------
colors <- c(
  `blue`       = "#236192",
  `green`      = "#789D4A",
  `purple`     = "#45308A",
  `light blue` = "#0073BC",
  `kellygreen` = "#078754",
  `red` 	   = "#D52C27")

col_scheme <- function(...) {
  cols <- c(...)
  
  if (is.null(cols))
    return (colors)
  
  colors[cols]
}



palettes <- list(
  `main`  = col_scheme("blue", "green", "purple"),
  
  `cool`  = col_scheme("blue", "green"),
  
  `hot`   = col_scheme("purple", "orange", "red")
)


my_pal <- function(palette = "main", reverse = FALSE, ...) {
  pal <- palettes[[palette]]
  
  if (reverse) pal <- rev(pal)
  
  colorRampPalette(pal, ...)
}

my_pal("cool")(10)


scale_color_ltcu <- function(palette = "main", discrete = TRUE, reverse = FALSE, ...) {
  pal <- my_pal(palette = palette, reverse = reverse)
  
  if (discrete) {
    discrete_scale("colour", paste0("ltcu_", palette), palette = pal, ...)
  } else {
    scale_color_gradientn(colours = pal(256), ...)
  }
}


scale_fill_ltcu <- function(palette = "main", discrete = TRUE, reverse = FALSE, ...) {
  pal <- my_pal(palette = palette, reverse = reverse)
  
  if (discrete) {
    discrete_scale("fill", paste0("ltcu_", palette), palette = pal, ...)
  } else {
    scale_fill_gradientn(colours = pal(256), ...)
  }
}
