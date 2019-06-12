# fn-dbscan-clusterer
Give us a bunch of GeoJSON polygons or points with some params, and we'll give you back clusters of them.

## Parameters

JSON object containing:

- `subject`: **Required** _{GeoJSON FeatureCollection or URL}_ Points/polygons to cluster. If URL, point to a file that contains GeoJSON or zipped Shapefile of polygons or points. Coordinates must be specified in decimal degrees. Note that polygons will be converted to points (centroids) for the purpose of clustering.
- `parcel_by`: **Optional** _{Array of string (URL) | GeoJSON FeatureCollection}_ A FeatureCollection for which no clusters should intersect. 
- `max_num`: **Required** _{integer}_ The maximum number of `subject` elements per cluster. Integer between 1 and number of features of `subject`. 
- `max_dist_m`: **Required** _{integer}_ The maximum distance in metres between any two `subject` elements in a cluster. (>= 0). If 0, every element will be a cluster. If greater than max distance between any pair of `subject` elements, will create a single cluster.
- `return_type`: **Optional** Defaults to 'both' _{string: 'hull' | 'subject' | 'both' }_ If `hull`, return convex hull for each cluster. If `subject`, return `subject` elements with additional property `cluster_id`. If `both`, include both `hull` and `subject` return types.

## Constraints

- Maximum size of `subject` is ~XX MB or contains maximum of ~XX features. Currently being determined.
- Timeout of 60 seconds

## Response

Depends on `return_type`. JSON object of GeoJSON FeatureCollection(s).

## Example input
An example JSON input can be found [here](https://raw.githubusercontent.com/disarm-platform/fn-dbscan-clusterer/master/fn-dbscan-clusterer/function/test_req.json)