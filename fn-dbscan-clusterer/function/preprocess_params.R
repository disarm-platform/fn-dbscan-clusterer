function(params) {
  
  
  retrieve_and_replace_for = function(param) {
    if (!is.character(param) || !startsWith(prefix = "http", param)) {
      stop(paste("Not a URL. Trying to retrieve remote file for", param))
    }
    #hashed_filename =
    #return(param)
    # Check if we're passing in a string starting 'http'
    # If we are, try to get the ETag
    # tryCatch retrieve that file,
    #   stop() if problems,
    #   otherwise, write to temp disk, replace parameter with temp filename
  }
  
  must_have = function(param, params) {
    if (is.null(params[[param]])) {
      stop(paste0('Missing `', param, '` parameter'))
    }
  }
  
  # Individual check for each parameter
  
  # Handle `subject`
  #retrieve_and_replace_for(property_name='subject', params=params, filetype='geojson')
  #retrieve_and_replace_for(property_name='subject', params=params, read_function="st_read")
  
  must_have('subject', params)
  must_have('max_num', params)
  must_have('max_dist_m', params)
  
  if (params[['max_num']] <= 0) {
    stop("'max_num' should be > 0")
  }
  
  if (params[['max_dist_m']] < 0) {
    stop("'max_dist_m' should be >= 0")
  }
  
  if (!is.numeric(params[['max_num']])) {
    stop("'max_num' should numeric integer")
  }
  
  if (!is.numeric(params[['max_dist_m']])) {
    stop("'max_num' should numeric")
  }
  
  if (length(params[['max_dist_m']]) > 1) {
    stop("'max_dist_m' should single parameter")
  }
  
  if (length(params[['max_num']]) > 1) {
    stop("'max_dist_m' should single parameter")
  }
  

  
}
