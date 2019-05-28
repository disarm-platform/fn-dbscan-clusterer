
# Test
# Combine geojsons to form a single SpatialLines object
roads <- st_read("https://www.dropbox.com/s/dshv5wmqqrfiphx/roads_swz.geojson?dl=1")
poly <- st_read("https://www.dropbox.com/s/w1g7iez5lqr3fch/adm2_swz.geojson?dl=1")
rivers <- st_read("https://www.dropbox.com/s/2e1p5yuqej4mq9t/swz_rivers.geojson?dl=1")
list_of_geojson <- list(roads, rivers, poly)

merged <- combine_geojson_for_parcels(list_of_geojson)

# Create fake buildings 
buildings <- as_Spatial(st_read("https://www.dropbox.com/s/i8ksgqknyjtpzkm/test_coords_swazi.geojson?dl=1"))

# Put into 'top' clusters
buildings$cluster_id <- dbscan(buildings@coords, 0.05, minPts = 1)$cluster

# Parcel
parcelled <- parcel_structures(buildings, merged)
plot(parcelled@coords, col = parcelled$parcel)