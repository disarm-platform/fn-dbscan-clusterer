library(sf)
library(sp)

# Functino to combine geojsons for parceller
function(list_of_geojson) {
  n_layers <- length(list_of_geojson)
  
  lines_list <-
    lapply(list_of_geojson, function(x) {
      x <- x[,-c(2:ncol(x))] 
      names(x)[1] <- "COL1"
      st_cast(x, "LINESTRING")
    })
  
  merged <- do.call(rbind, lines_list)
  merged <- st_zm(merged)
  
  # Return sp object (required for parceller)
  as(merged, "Spatial")
  
  
}