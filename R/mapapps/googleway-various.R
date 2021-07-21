map_key <- config::get()$gcp$gmaps_api_key
pl_outer <- encode_pl(lat = c(25.774, 18.466,32.321),
                      lon = c(-80.190, -66.118, -64.757))

pl_inner <- encode_pl(lat = c(28.745, 29.570, 27.339),
                      lon = c(-70.579, -67.514, -66.668))

pl_other <- encode_pl(c(21,23,22), c(-50, -49, -51))

## using encoded polylines
df <- data.frame(id = c(1,1,2),
                 colour = c("#00FF00", "#00FF00", "#FFFF00"),
                 polyline = c(pl_outer, pl_inner, pl_other),
                 stringsAsFactors = FALSE)

google_map(key = map_key) %>%
  add_polygons(data = df, polyline = 'polyline', id = 'id', fill_colour = 'colour')

df_update <- df[, c("id", "colour")]
df_update$colour <- c("#FFFFFF", "#FFFFFF", "#000000")

google_map(key = map_key) %>%
  add_polygons(data = df, polyline = 'polyline', id = 'id', fill_colour = 'colour') %>%
  update_polygons(data = df_update, id = 'id', fill_colour = 'colour')


df <- aggregate(polyline ~ id + colour, data = df, list)

google_map(key = map_key) %>%
  add_polygons(data = df, polyline = 'polyline', fill_colour = 'colour')

google_map(key = map_key) %>%
  add_polygons(data = df, polyline = 'polyline', id = 'id', fill_colour = 'colour') %>%
  update_polygons(data = df_update, id = 'id', fill_colour = 'colour')


## using coordinates
df <- data.frame(id = c(rep(1, 6), rep(2, 3)),
                 lineId = c(rep(1, 3), rep(2, 3), rep(1, 3)),
                 lat = c(25.774, 18.466, 32.321, 28.745, 29.570, 27.339, 21, 23, 22),
                 lon = c(-80.190, -66.118, -64.757, -70.579, -67.514, -66.668, -50, -49, -51))

google_map(key = map_key) %>%
  add_polygons(data = df, lat = 'lat', lon = 'lon', id = 'id', pathId = 'lineId')

google_map(key = map_key) %>%
  add_polygons(data = df, lat = 'lat', lon = 'lon', id = 'id', pathId = 'lineId') %>%
  update_polygons(data = df_update, id = 'id', fill_colour = 'colour')
