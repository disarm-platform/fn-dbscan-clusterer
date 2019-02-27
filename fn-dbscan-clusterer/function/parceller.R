library(dbscan)
library(sp)
library(sf)
library(rgeos)


# Get chulls
get_chulls_for_parceller <- function(points_with_cluster_id){
  
      # Get CHULL for each cluster of points
      get_chull_poly <- function(points_to_chull){
        chull_coords <- points_to_chull[chull(points_to_chull),]
        polys <- Polygons(list(Polygon(chull_coords)), "ID")
      }
      
      chull_polys <- by(points_with_cluster_id@coords,
                        points_with_cluster_id$cluster_id, get_chull_poly)
      
      # Force chull_polys to be a list class not by class
      class(chull_polys) <- "list"
      
      for (i in 1:length(chull_polys)){
        slot(chull_polys[[i]], "ID") = as.character(i)
      }
      
      spdf <- SpatialPolygonsDataFrame(SpatialPolygons(chull_polys),
                               data = data.frame(cluster_id = 1:length(chull_polys)))
      
      gBuffer(spdf, width=0.0001, byid=T)
  
}

parcel_structures <- function(structure_points, parcel_lines){
  
  if(nrow(structure_points)<=2){
    structure_points$parcel <- paste0("top_cluster", structure_points$cluster_id)
    return(structure_points)
  }
  # crop roads for computation
  parcel_lines_crop <- crop(parcel_lines, structure_points)
  if(is.null(parcel_lines_crop)){
    structure_points$parcel <- paste0("top_cluster", structure_points$cluster_id)
    return(structure_points)
  }
  
  # Create buffers around structures
  structure_buffers <- get_chulls_for_parceller(points_with_cluster_id)
  
  # If it intersects, split
  lpi <- gIntersection(structure_buffers, parcel_lines_crop)  # intersect your line with the polygon
  
  # IF there is no intersection, just return with parcel id
  if(is.null(lpi)){
    structure_points$parcel <- paste0(structure_points$Adm2,1)
    return(structure_points)
  }
  blpi <- gBuffer(lpi, width = 0.0001)  # create a very thin polygon buffer of the intersected line
  dpi <- gDifference(structure_buffers, blpi)  
  dpi <- disaggregate(dpi)
  
  # Check which new buffer the structures lie in
  crs(dpi) <- crs(structure_points)
  structure_points$parcel <- paste0("top_cluster", structure_points$cluster_id, "_",
                                    over(structure_points, dpi))
  
  # return
  return(structure_points)
}




for (layer_name in layer_names) {
  points = load_layer(points, layer_name)
}


# Functino to combine geojsons for parceller
combine_geojson_for_parcels <- function(list_of_geojson) {
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

# Test
# Combine geojsons to form a single SpatialLines object
roads <- st_read("https://www.dropbox.com/s/dshv5wmqqrfiphx/roads_swz.geojson?dl=1")
poly <- st_read("https://www.dropbox.com/s/w1g7iez5lqr3fch/adm2_swz.geojson?dl=1")
rivers <- st_read("https://www.dropbox.com/s/2e1p5yuqej4mq9t/swz_rivers.geojson?dl=1")
list_of_geojson <- list(roads, rivers, poly)

merged <- combine_geojson_for_parcels(list_of_geojson)

# Create fake buildings 
buildings <- as_Spatial(st_read("https://www.dropbox.com/s/i8ksgqknyjtpzkm/test_coords_swazi.geojson?dl=1"))

# Put into 'top' clusters
buildings$cluster_id <- dbscan(buildings@coords, 0.05, minPts = 1)$cluster

# Parcel
parcelled <- parcel_structures(buildings, merged)
plot(parcelled@coords, col = parcelled$parcel)
