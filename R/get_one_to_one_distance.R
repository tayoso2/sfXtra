
#' Load 1 sf object which contains the spatial feature of both the 'x geometry' and the 'y geometry' columns
#'
#' This function will calculate the distance between the 2 spatial features in each row
#' @param x The sf object with both the x geometry and the y geometry
#' @param x_geom The geometry of the object on the lhs
#' @param y_geom The geometry of the object on the rhs
#' @param splits The number of lists so as to speed up the calculation
#' @param centroid Default is TRUE. If TRUE, convert x_geom and y_geom to centroids
#' @return Returns the sf object with additional column, geom_distance_m in meters
#' @importFrom plyr rbind.fill
#' @import sf
#' @import lwgeom
#' @export

get_one_to_one_distance <- function(x, x_geom = "geometry.x", y_geom = "geometry.y", splits = 50, centroid = TRUE) {

  # duplicate x
  y <- x

  # assign the active geometry on the lhs and rhs
  sf::st_geometry(x) <- x_geom
  sf::st_geometry(y) <- y_geom

  # Transform x CRS to EPSG 4326 if required
  if (sf::st_crs(x) != 4326) {
    message(paste0(
      "Transforming x coordinate reference system to ESPG: 4326"
    ))
    x <- sf::st_transform(x, crs = 4326)
  }

  # Transform y CRS to x CRS if required
  if (sf::st_crs(x) != sf::st_crs(y)) {
    message(paste0(
      "Transforming y coordinate reference system to ESPG: ",
      sf::st_crs(x)$epsg
    ))
    y <- sf::st_transform(y, sf::st_crs(x))
  }

  # Transform x_geom and y_geom to centroid
  if (isTRUE(centroid)) {
    message("Converting x_geom and y_geom to centroid")
    x <- sf::st_centroid(x)
    y <- sf::st_centroid(y)
  } else{
    message("Convert to centroid for faster processing")
  }

  # create a list of dataframes for x
  my_split <- base::rep(1:splits, each = 1, length = nrow(x))
  my_split2 <- dplyr::mutate(x, my_split = my_split)
  list_x <- base::split(my_split2, my_split2$my_split)

  # create a list of dataframes for y
  my_split <- base::rep(1:splits, each = 1, length = nrow(y))
  my_split2 <- dplyr::mutate(y, my_split = my_split)
  list_y <- base::split(my_split2, my_split2$my_split)

  # loop through each list and compute the distance
  for (i in 1:length(list_x)) {
    # message for progress
    message(paste0((i/length(list_x))*100,"% at ",Sys.time()))

    x_1 <- list_x[[i]]
    y_1 <- list_y[[i]]
    for (j in 1:nrow(list_x[[i]])) {
      # calculate the distance
      x_1$geom_distance_m[j] <- as.numeric(lwgeom::st_geod_distance(x_1[j, x_geom], y_1[j, y_geom]))
    }
    if (i == 1) {
      output_final <- x_1
    } else {
      output_final <- plyr::rbind.fill(output_final, x_1)
    }
  }
  return(as.data.frame(output_final))
}




