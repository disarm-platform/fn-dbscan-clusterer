dbscan_function = dget('function/dbscan_clusterer.R')


function(params) {
  # run function and catch result
  result = dbscan_function(params)

  return(result)
}
