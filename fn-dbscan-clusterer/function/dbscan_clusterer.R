library(sf)
library(dbscan)
library(spatstat)
library(cluster)

dbscan_clusterer_parallel = dget('function/dbscan_clusterer_parallel.R')
get_parcels = dget("function/get_parcels.R")
combine_geojson_for_parcels <- dget("function/combine_geojson_for_parcels.R")
get_chulls_for_parceller <- dget("function/get_chulls_for_parceller.R")
split_clusters = dget("function/split_clusters_parallel.R")
get_cluster_chulls = dget("function/get_cluster_chulls.R")

function(params){

  subject <- st_read(as.json(params[['subject']]), quiet = T) # Always with the :QUIET:

  max_dist_m = params[['max_dist_m']]
  max_num = params[['max_num']]
  return_type = ifelse(is.null(params[['return_type']]), "both",
                       params[['return_type']])
  parcel_lines_list <- params[['parcel_by']]
  
      # If 'subject' is polygons, calc centroid for clustering
      if(st_geometry_type(subject)[1] == "POLYGON"){
        subject <- st_centroid(subject)
      }

      # Convert m to decimal degrees (approx)
      max_dist <- max_dist_m / 111 / 1000
      
      # Parcel using input parcels
      
      # # Run dbscan to find neighbourhoods
      point_coords <- st_coordinates(subject)
      dbscan_cluster <- dbscan(point_coords,
                               eps = max_dist, # over 2 as radius not diameter
                               minPts = 1)
      

      # Split clusters by roads/rivers/other
      point_coords_sp <- SpatialPointsDataFrame(SpatialPoints(point_coords),
                                                                       data.frame(cluster=dbscan_cluster$cluster))
      
      # First merge parcel lines if necessary
      if(!is.null(parcel_lines_list)){
      parcel_lines <- combine_geojson_for_parcels(parcel_lines_list)
      point_coords_sp <- get_parcels(point_coords_sp, parcel_lines)
      }else{
        point_coords_sp$cluster <- 1
      }
      
      # split groups that are too large
      # # First ID which clusters are too big
      which_too_big <- which(table(point_coords_sp$cluster)>max_num)
      # 
      # Use dbscan clusters to create list of points
      # in each cluster
      point_coords <- as.data.frame(point_coords_sp@coords)
      point_coords$custom_id <- 1:nrow(point_coords)
      points_list <- split(point_coords, point_coords_sp$cluster)

      # # If no clusters contained too many points,
      # # return now
      if(length(which_too_big)==0){

        # Give each 'cluster' an ID
        points_with_cluster_id <- data.frame(custom_id=NULL,
                                             cluster_id=NULL)
        for(i in 1:length(points_list)){
          points_with_cluster_id <- rbind(points_with_cluster_id,
                                          data.frame(custom_id = points_list[[i]]$custom_id,
                                                     cluster_id = i))
        }

        # Use IDs to assign cluster ID to subject
        subject$cluster_id = NA
        subject$cluster_id[points_with_cluster_id$custom_id] <-
          points_with_cluster_id$cluster_id

        if(return_type == "subject"){
          return(list(thing = geojson_list(subject)))
        }

        if(return_type == "chull"){

          # Generate chulls
          chull_polys <- get_cluster_chulls(points_with_cluster_id)
          return(list(chull_polys = geojson_list(chull_polys)))

        }else{

            # Generate chulls
            chull_polys <- get_cluster_chulls(points_with_cluster_id, subject)
            chull_polys_geojson_list <- geojson_list(chull_polys)

            # Remove 'ID' field
            chull_polys_geojson_list$features <- lapply(chull_polys_geojson_list$features,
                                                        function(x) {x$id<-NULL; return(x)})

            return(list(subject = geojson_list(subject),
                        chull_polys = chull_polys_geojson_list))
          }
        }else{

      # Define list of complete and incomplete clusters
      return_id <- function(x){return(unlist(x$custom_id))}
      complete_clusters <- sapply(points_list[-which_too_big], return_id)
      incomplete_clusters <- points_list[which_too_big]
      rm(points_list) # Remove from memory

      # Apply splitting function
      sub_clusters <- sapply(incomplete_clusters,
                             split_clusters,
                             max_num = max_num)
                             #max_dist = max_dist)

      # Above function sometimes returns list of lists (must be something
      # to do with number of groups passed into mclapply)
      if(is.list(sub_clusters[[1]])){
      sub_clusters <- unlist(sub_clusters, recursive = FALSE)
      }

      # Add new sub clusters to complete_clusters
      final_clusters <- c(complete_clusters, sub_clusters)


      # Give each 'cluster' an ID
      points_with_cluster_id <- data.frame(custom_id=NULL,
                                           cluster_id=NULL)
      for(i in 1:length(final_clusters)){
        points_with_cluster_id <- rbind(points_with_cluster_id,
              data.frame(custom_id = final_clusters[[i]],
                         cluster_id = i))
      }

      subject$cluster_id = NA
      subject$cluster_id[points_with_cluster_id$custom_id] <-
        points_with_cluster_id$cluster_id

      # If return type includes goejson
      if(return_type %in% c("hull", "both")){

        # Get CHULL for each cluster of points
        chull_polys <- get_cluster_chulls(points_with_cluster_id, subject)

        return(list(subject = geojson_list(subject),
                    chull_polys = geojson_list(chull_polys)))
      }else{
      return(subject)
      }
    }
}

