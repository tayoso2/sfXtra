#' Load 2 sf objects, x and y
#'
#' Accepts two sf objects x and y and determines the nearest feature in y for
#' every feature in x.
#' @param x An sf object containing the features for which you want find the nearest features in y
#' @param y An sf object containing features to be assigned to x
#' @param y.name Characters prepended to the y features in the returned datatable
#' @return Returns a datatable containing all rows from x with the corresponding nearest
#' feature from y. A column representing the distance between the features is
#' also included. Note that this object contains no geometry.
#' @import sf
#' @import units
#' @export
FindNearest <- function(x, y, y.name = "y") {
  # Determine CRSs
  message(paste0("x Coordinate reference system is ESPG: ", st_crs(x)$epsg))
  message(paste0("y Coordinate reference system is ESPG: ", st_crs(y)$epsg))
  
  # Transform y CRS to x CRS if required
  if (st_crs(x) != st_crs(y)) {
    message(paste0(
      "Transforming y coordinate reference system to ESPG: ",
      st_crs(x)$epsg
    ))
    y <- st_transform(y, st_crs(x))
  }
  
  # Compute distance matrix
  dist.matrix <- st_distance(x, y)
  
  # Select y features which are shortest distance
  nearest.rows <- apply(dist.matrix, 1, which.min)
  # Determine shortest distances
  nearest.distance <-
    dist.matrix[cbind(seq(nearest.rows), nearest.rows)]
  
  # Report distance units
  distance.units <- deparse_unit(nearest.distance)
  message(paste0("Distance unit is: ", distance.units))
  
  # Build data table of nearest features
  nearest.features <- y[nearest.rows,]
  nearest.features$distance <- nearest.distance
  nearest.features$rowguid <- x$rowguid
  nearest.features$Reference.Number <- x$Reference.Number
  # Remove geometries
  st_geometry(x) <- NULL
  st_geometry(nearest.features) <- NULL
  
  # Prepend names to y columns
  names(nearest.features) <- paste0(y.name, ".", names(nearest.features))
  
  # Bind datatables and return
  #output <- cbind(x, nearest.features)
  output <- nearest.features
  return(output)
}

