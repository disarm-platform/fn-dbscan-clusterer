dbscan_function = dget('function/dbscan.R')


function(params) {
  # run function and catch result
  result = dbscan_function(params)

  # wrap up result to match output structure from docs
  response = list(result = result)

  return(response)
}
