function(params) {
  # Individual check for each parameter
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