library(jsonlite)
library(geojsonio)

preprocess_params = dget('function/preprocess_params.R')
run_function = dget('function/function.R')

main = function () {
  tryCatch({
    # reads STDIN as JSON, return error if any problems
    params = fromJSON(readLines(file("stdin")))
    # params = fromJSON(readLines("function/test_req.json"))

    # checks for existence of required parameters, return error if any problems
    # checks types/structure of all parameters, return error if any problems
    # as required, replace any external URLs with data
    preprocess_params(params)
    
    # run the function with parameters, 
    # return error if any problems, return success if succeeds      
    function_response = run_function(params)
    return(handle_success(function_response))
  }, error = function(e) {
    return(handle_error(e))
  })
}

handle_error = function(error) {
  function_response = as.json(list(
    function_status = unbox('error'), 
    result = unbox(as.character(error)))
  )
  return(write(function_response, stdout()))
}

handle_success = function(result) {
  function_response = as.json(list(
    function_status = unbox('success'), 
    result = result)
  )
  return(write(function_response, stdout()))
}

main()
