
library(shiny)
library(googleway)
library(dplyr)

config <- config::get()
key <- config$gcp$gmaps_api_key
set_key(key = key)

vendor_locations <- readr::read_csv("shiny_app/data/vendor_locations.csv")

dat <- vendor_locations %>%
  mutate(
    title = paste0(vendor_name, ": ", location_name),
    info = ifelse(is.na(location_id), title,
                  paste0(
                    "<div id='bodyContent'>",
                    "<iframe width='450px' height='250px'",
                    "frameborder='0' style = 'border:0'",
                    "src=",
                    paste0(
                      "https://www.google.com/maps/embed/v1/place?q=place_id:",
                      location_id,
                      "&key=",
                      key
                    ),
                    "></iframe></div>"
                  ))
  )

kml <- fs::path("data_prep/geodata/gadm36_KEN_3/gadm36_KEN_3.kml")

google_map() %>% add_kml(kml)

google_map(dat,
           # location = c(dat$lat, dat$lon),
           # zoom = 12,
           width = "100%",
           height = "300px",
           search_box = TRUE,
           update_map_view = TRUE,
           geolocation = TRUE,
           map_type_control = TRUE,
           zoom_control = TRUE,
           street_view_control = TRUE,
           scale_control = TRUE,
           rotate_control = TRUE,
           fullscreen_control = TRUE,
           event_return_type = c("list", "json")
) %>%
  # add_markers(
  #   lat = "lat",
  #   lon = "lon",
  #   title = "title",
  #   label = "vendor_name",
  #   layer_id = "vendor_locations",
  #   info_window = "info",
  #   mouse_over = "address",
  #   draggable = TRUE,
  #   cluster = TRUE,
  #   cluster_options = list(
#     minimumClusterSize = 3
#   ),
#   update_map_view = TRUE
# ) %>%
add_circles(
  lat = "lat",
  lon = "lon"
)
