

# Get chulls
function(points_with_cluster_id){
  
  # Get CHULL for each cluster of points
  get_chull_poly <- function(points_to_chull){
    chull_coords <- points_to_chull[chull(points_to_chull),]
    polys <- Polygons(list(Polygon(chull_coords)), "ID")
  }
  
  chull_polys <- by(points_with_cluster_id@coords,
                    points_with_cluster_id$cluster, get_chull_poly)
  
  # Force chull_polys to be a list class not by class
  class(chull_polys) <- "list"
  
  for (i in 1:length(chull_polys)){
    slot(chull_polys[[i]], "ID") = as.character(i)
  }
  
  spdf <- SpatialPolygonsDataFrame(SpatialPolygons(chull_polys),
                                   data = data.frame(cluster_id = 1:length(chull_polys)))
  
  gBuffer(spdf, width=0.0001, byid=T)
  
}