library(sp)

function(points_with_cluster_id, subject){

        # Get CHULL for each cluster of points
        get_chull_poly <- function(points_to_chull){
          chull_coords <- points_to_chull[chull(points_to_chull),]
          polys <- Polygons(list(Polygon(chull_coords)), "ID")
        }

        chull_polys <- by(st_coordinates(subject[points_with_cluster_id$custom_id,]),
                          points_with_cluster_id$cluster_id, get_chull_poly)
        
        # Force chull_polys to be a list class not by class
        class(chull_polys) <- "list"
        
        for (i in 1:length(chull_polys)){
          slot(chull_polys[[i]], "ID") = as.character(i)
        }

        SpatialPolygonsDataFrame(SpatialPolygons(chull_polys),
                                                   data = data.frame(cluster_id = 1:length(chull_polys)))
        
}