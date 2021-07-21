library(googleway)
library(dplyr)

config <- config::get()
key <- config$gcp$gmaps_api_key
set_key(key = key)

paths <- yaml::read_yaml("data_prep/paths.yml")

customer_locations <- qs::qread("data_prep/cache/customer_locations") %>%
  mutate(
    title = paste0(customer_name, ": ", location_name),
    info = ifelse(is.na(place_id),
                  title,
                  paste0(
                    "<div id='bodyContent'>",
                    "<iframe width='450px' height='250px'",
                    "frameborder='0' style = 'border:0'",
                    "src=",
                    paste0(
                      "https://www.google.com/maps/embed/v1/place?q=place_id:",
                      place_id,
                      "&key=",
                      key
                    ),
                    "></iframe></div>"
                  ))
  )

google_map(
  data = customer_locations,
  location = c(customer_locations$lat, customer_locations$lon),
  zoom = 12,
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
  add_markers(
    lat = "lat",
    lon = "lon",
    title = "title",
    label = "customer_number",
    layer_id = "customer_locations",
    info_window = "info",
    mouse_over = "address",
    # cluster = TRUE,
    update_map_view = TRUE
  )

vendor_locations <- qs::qread("data_prep/cache/vendor_locations") %>%
  mutate(
    title = paste0(vendor_name, ": ", location_name),
    info = ifelse(is.na(place_id),
                  title,
                  HTML(paste0(
                    "<div id='bodyContent'>",
                    "<iframe width='450px' height='250px'",
                    "frameborder='0' style = 'border:0'",
                    "src=",
                    paste0(
                      "https://www.google.com/maps/embed/v1/place?q=place_id:",
                      place_id,
                      "&key=",
                      key
                    ),
                    "></iframe></div>"
                  )))
  )

vendor_regions <- c("https://www.google.com/maps/place/Tudor,+Mombasa,+Kenya/@-4.036894,39.6588812,16z/data=!3m1!4b1!4m5!3m4!1s0x184012bab94dd2f9:0x3fb0d5e8bbc88dc3!8m2!3d-4.034048!4d39.6647178",
                    "https://www.google.com/maps/place/Diani+Beach/@-4.2879123,39.5864009,14z/data=!4m13!1m7!3m6!1s0x1840463f2a0b107d:0xafa0063ab0f439ad!2sDiani+Beach!3b1!8m2!3d-4.2797626!4d39.5946958!3m4!1s0x1840463f2a0b107d:0xafa0063ab0f439ad!8m2!3d-4.2797626!4d39.5946958",
                    "https://www.google.com/maps/place/Ras+Makamaiwe,+Mombasa,+Kenya/@-4.0390177,39.6689158,17z/data=!3m1!4b1!4m13!1m7!3m6!1s0x0:0x0!2s6G7XXM69%2BX9!3b1!8m2!3d-4.0375625!4d39.6684375!3m4!1s0x184012bdc2334885:0x5c2a729417c9181d!8m2!3d-4.0387135!4d39.6711668",
                    "https://www.google.com/maps/place/Mtwapa,+Kenya/@-3.9378763,39.7427844,15z/data=!3m1!4b1!4m12!1m6!3m5!1s0x18400994861a3aad:0xee2c3537bca4ab67!2sDutch+Water+Limited!8m2!3d-3.9521513!4d39.7425022!3m4!1s0x18400eac030bbde5:0x274428e1ae084b7b!8m2!3d-3.938583!4d39.7498226",
                    "https://www.google.com/maps/place/Nyali,+Mombasa,+Kenya/@-4.0535345,39.6947065,16z/data=!3m1!4b1!4m5!3m4!1s0x1840125145c7147f:0x41a731ea7cc49bf!8m2!3d-4.0507256!4d39.6967843",
                    "https://www.google.com/maps/place/Bamburi,+Mombasa,+Kenya/@-3.9964046,39.6991943,14z/data=!3m1!4b1!4m5!3m4!1s0x18400dc9042093c7:0x9576d364a78e35d1!8m2!3d-4.0043208!4d39.7153199",
                    "https://www.google.com/maps/place/Mtwapa,+Kenya/@-3.9378763,39.7427844,15z/data=!3m1!4b1!4m5!3m4!1s0x18400eac030bbde5:0x274428e1ae084b7b!8m2!3d-3.9385695!4d39.7497984",
                    "https://www.google.com/maps/place/Likoni,+Mombasa,+Kenya/@-4.1056572,39.6650696,14.25z/data=!4m5!3m4!1s0x184013573f5d712d:0x8061b3db8f33346e!8m2!3d-4.0840986!4d39.6608103")

googleway::google_map(location = c())


google_map(
  data = vendor_locations,
  location = c(vendor_locations$lat, vendor_locations$lon),
  zoom = 12,
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
  add_markers(
    lat = "lat",
    lon = "lon",
    title = "title",
    label = "vendor_number",
    layer_id = "vendor_locations",
    info_window = "info",
    mouse_over = "address",
    draggable = TRUE,
    # cluster = TRUE,
    update_map_view = TRUE
  )
