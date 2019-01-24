library(RANN)
library(parallel)

split_clusters_parallel = dget('function/split_clusters_parallel.R')

function(cluster_points, max_num, max_dist) {
  # Kmeans doesn'l like having to find large numbers of groups
  # so, first split into small number of large clusters
  # and take advantage of mclapply to run splitting function
  # for each large (top) cluster

  #num_top_clusters <- ceiling(nrow(cluster_points) / 5000)
  top_clusters <- dbscan(cluster_points[,c("X", "Y")], 
                         eps = max_dist / 2,
                         minPts = 1)
  cluster_points_split <- split(cluster_points,
                                top_clusters)
          #kmeans(cluster_points[,c("X", "Y")], num_top_clusters)$cluster)

  # Run function in parallel and remove hierarchy of list
  split_clusters <-
    mclapply(cluster_points_split, 
             FUN = split_clusters_parallel, 
             max_num = max_num,
             mc.cores = 4)
  unlist(split_clusters, recursive = FALSE)
}


