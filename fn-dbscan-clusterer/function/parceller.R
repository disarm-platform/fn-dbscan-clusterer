library(dbscan)
# Create fake buildings 
buildings <- as.data.frame(cbind(runif(500, 30, 31),
                         runif(500, -22, -21)))


buildings$cluster_id <- dbscan(buildings, 0.05, minPts = 1)$cluster
structure_points <- SpatialPointsDataFrame(SpatialPoints(buildings[,1:2]),
                                           data.frame(buildings$cluster_id))
#buildings_by_cluster <- split(buildings, clusters$cluster)


# Get chulls
get_chulls_for_parceller <- function(points_with_cluster_id){
  
      # Get CHULL for each cluster of points
      get_chull_poly <- function(points_to_chull){
        chull_coords <- points_to_chull[chull(points_to_chull),]
        polys <- Polygons(list(Polygon(chull_coords)), "ID")
      }
      
      chull_polys <- by(points_with_cluster_id[,1:2],
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

parcel_structures <- function(points_with_cluster_id, roads){
  
  if(nrow(structure_points)<=2){
    structure_points$parcel <- paste0(structure_points$Adm2,1)
    return(structure_points)
  }
  # crop roads for computation
  roads_crop <- crop(roads, structure_points)
  if(is.null(roads_crop)){
    structure_points$parcel <- paste0(structure_points$Adm2,1)
    return(structure_points)
  }
  
  # Create buffers around structures
  structure_buffers <- get_chulls_for_parceller(points_with_cluster_id)
  
  # If it intersects, split
  lpi <- gIntersection(structure_buffers, roads_crop)  # intersect your line with the polygon
  
  # IF there is no intersection, just return with parcel id
  if(is.null(lpi)){
    structure_points$parcel <- paste0(structure_points$Adm2,1)
    return(structure_points)
  }
  blpi <- gBuffer(lpi, width = 0.000001)  # create a very thin polygon buffer of the intersected line
  dpi <- gDifference(structure_buffers, blpi)  
  dpi <- disaggregate(dpi)
  
  # Check which new buffer the structures lie in
  crs(dpi) <- crs(structure_points)
  structure_points$parcel <- paste0(structure_points$Adm2, 
                                    over(structure_points, dpi))
  
  # return
  return(structure_points)
}


# Combine geojsons to form a single SpatialLines object
lines <- st_read("/Users/hughsturrock/Downloads/lines.geojson")
poly <- st_read("/Users/hughsturrock/Downloads/poly.geojson")

list_of_geojson <- list(lines, poly)

combine_geojson_for_parcels <- function(list_of_geojson){
  
  n_layers <- length(list_of_geojson)
  
  lines_list <- lapply(list_of_geojson, function(x){st_cast(x, "LINESTRING")})
  lines_merged <- do.call(rbind, lines_list)
  as(lines_merged, "Spatial")
}

# Test
parcel_structures(structure_points)
