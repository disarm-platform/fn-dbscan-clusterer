# fn-nearest-neighbour-clusterer
Give us a bunch of GeoJSON polygons or points with some params, and we'll give you back clusters of them.

## Parameters

JSON object containing:

- `subject`: _{GeoJSON FeatureCollection or URL}_ if URL, point to a file that contains GeoJSON or zipped Shapefile of polygons or points. Coordinates must be specified in decimal degrees.
- `parcel_by`: _{Array of string (URL) | GeoJSON FeatureCollection}_ Features by which to do initial parcelling.
- `max_num`: _{integer}_ The maximum number of `subject` elements per cluster. Integer between 1 and number of features of `subject`. 
- `max_dist_m`: _{integer}_ The maximum distance in metres between any two `subject` elements in a cluster. (>= 0). If 0, every element will be a cluster. If greater than max distance between any pair of `subject` elements, will create a single cluster.
- 'return_type': _{string: 'hull' | 'subject' | 'both' }_ If `hull`, return convex hull for each cluster. If `subject`, return `subject` elements with additional property `cluster_id`. If `both`, include both `hull` and `subject` return types.

## Constraints

- maximum size of `subject` is ~XX MB or contains maximum of ~XX features
- timeout of XX seconds

## Response

Depends on `return_type`. GeoJSON FeatureCollection.