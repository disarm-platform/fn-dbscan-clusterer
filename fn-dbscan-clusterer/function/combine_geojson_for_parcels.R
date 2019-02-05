library(sf)
library(sp)

# Functino to combine geojsons for parceller
function(list_of_geojson) {
  n_layers <- length(list_of_geojson)
  
  lines_list <-
    lapply(list_of_geojson, function(x) {
      x_sf <- st_read(x, quiet=TRUE)
      x_sf <- x_sf[,-c(2:ncol(x_sf))] 
      names(x_sf)[1] <- "COL1"
      st_cast(x_sf, "LINESTRING")
    })
  
  merged <- do.call(rbind, lines_list)
  merged <- st_zm(merged)
  
  # Return sp object (required for parceller)
  as(merged, "Spatial")
  
  
}