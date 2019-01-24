# Takes XX
# Returns YY
function(cluster_points, max_num) {
  max_num_per_cluster <- max_num + 1
  diff <- max_num_per_cluster - max_num
  target_num_clusters <- ceiling(nrow(cluster_points) / max_num)
  target_num_clusters <-
    target_num_clusters + ceiling((diff - 10) / 10) # This might be too aggresive but speeds things up
  
  # While there are too many points per cluster,
  # keep adding a new cluster
  complete_sub_clusters <- list()
  
  while (max_num_per_cluster > max_num) {
    sub_clusters <-
      kmeans(cluster_points[, c("X", "Y")], target_num_clusters)
    max_num_per_cluster <- max(table(sub_clusters$cluster))
    
    # Identify which satisfy and which don't
    complete <- which(table(sub_clusters$cluster) <= max_num)
    
    # Add complete clusters to list
    complete_sub_clusters <- c(complete_sub_clusters,
                               split(cluster_points[sub_clusters$cluster %in% complete, "custom_id"],
                                     sub_clusters$cluster[sub_clusters$cluster %in% complete]))
    
    # Remove those in compelte clusters and redo
    cluster_points <-
      cluster_points[-which(sub_clusters$cluster %in% complete), ]
    diff <- max_num_per_cluster - max_num
    target_num_clusters <- ceiling(nrow(cluster_points) / max_num)
    target_num_clusters <- target_num_clusters + ceiling(diff / 10)
    
    # Make sure you're not asking
    if (target_num_clusters == nrow(cluster_points)) {
      target_num_clusters <- target_num_clusters - 1
    }
  }
  
  return(complete_sub_clusters)
}
