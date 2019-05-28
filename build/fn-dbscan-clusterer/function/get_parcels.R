library(dbscan)
library(sp)
library(sf)
library(rgeos)
library(raster)

# Get chulls
get_chulls_for_parceller <- dget("function/get_chulls_for_parceller.R")


function(structure_points, parcel_lines){
  
  if(nrow(structure_points)<=2){
    #structure_points$parcel <- paste0("top_cluster", structure_points$cluster_id)
    return(structure_points)
  }
  # crop roads for computation
  parcel_lines_crop <- crop(parcel_lines, structure_points)
  if(is.null(parcel_lines_crop)){
    #structure_points$parcel <- paste0("top_cluster", structure_points$cluster_id)
    return(structure_points)
  }

  # Create buffers around structures
  structure_buffers <- get_chulls_for_parceller(structure_points)
  
  # If it intersects, split
  lpi <- gIntersection(structure_buffers, parcel_lines_crop)  # intersect your line with the polygon
  
  # IF there is no intersection, just return with parcel id
  if(is.null(lpi)){
    #structure_points$parcel <- paste0(structure_points$Adm2,1)
    return(structure_points)
  }
  blpi <- gBuffer(lpi, width = 0.0001)  # create a very thin polygon buffer of the intersected line
  dpi <- gDifference(structure_buffers, blpi)  
  dpi <- disaggregate(dpi)
  
  # Check which new buffer the structures lie in
  crs(dpi) <- crs(structure_points)
  structure_points$cluster <- #paste0("top_cluster", structure_points$cluster_id, "_",
                                    over(structure_points, dpi)
  
  # return
  return(structure_points)
}


