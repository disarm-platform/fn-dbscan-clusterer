function(params) {
  # Individual check for each parameter

  # Handle `subject`
  download('subject', params)
  
  if (is.null(params[['subject']])) {
    stop('Missing `subject` parameter')
  }
  
  if (is.null(params[['max_num']])) {
    stop('Missing `max_num` parameter')
  }
  
  if (is.null(params[['max_dist_m']])) {
    stop('Missing `max_dist_m` parameter')
  }
  
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
  
  if (length(params[['max_dist_m']])>1) {
    stop("'max_dist_m' should single parameter")
  }
  
  if (length(params[['max_num']])>1) {
    stop("'max_dist_m' should single parameter")
  }
  
}


# Retrieve remote files, replace URL in params with local filename
# 
# Uses MD5 hash for a given URL for basic caching. 
# This does not check anything to do with the content of the 
# received file: so two different URLs to the same file would 
# be downloaded twice

# TODO: Only cache into a temporary file, to avoid maxing out storage
download = function(param_name, params) {
  # Extract the value from params
  param_value = params[[param_name]]
  
  # Check it's likely to be downloadable
  if (!is.character(param_value) || !startsWith(prefix = "http", param_value)) {
    stop(paste("Not a URL. Trying to retrieve remote file for", param_value))
  }
  
  hashed_filename = openssl::md5(param_value)
  
  # Only download if it doesn't already exist
  if (!file.exists(hashed_filename)){
    write(paste(">>> Starting to download file:", param_value), stderr())
    download.file(param_value, hashed_filename)
    write(paste(">>> Successfully downloaded file:", param_value), stderr())
  }
  
  # Store back in params
  params[[param_name]] = hashed_filename
}
