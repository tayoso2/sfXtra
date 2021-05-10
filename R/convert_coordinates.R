
#' Load a list consisting easting and northing
#'
#' This function loads a list or dataframe containing easting and northing and outputs longitude and latitude using the provided crs.
#' @param easting Easting is the eastward-measured distance (or the x-coordinate)
#' @param northing Northing is the northward-measured distance (or the y-coordinate)
#' @param crs Default is 27700 for United Kingdom
#' @return Returns a dataframe with easting and northing converted to longitude and latitude
#' @import sp
#' @import rgdal
#' @export
east_north_to_long_lat <- function(easting, northing, crs = 27700) {
  wgs84 = paste0("+init=epsg:",crs)
  proj =  "+init=epsg:4326"
  output =  cbind(easting,northing)
  no_na = !is.na(easting)
  spatialobject <- sp::spTransform(sp::SpatialPoints(list(easting[no_na],northing[no_na]),proj4string=sp::CRS(wgs84)),sp::CRS(proj))
  output[no_na,] =  spatialobject@coords
  output <- as.data.frame(output)
  colnames(output)[which(names(output) == "easting")] <- "long"
  colnames(output)[which(names(output) == "northing")] <- "lat"
  return(output)
}



#' Load a list consisting long (longitude) and lat (latitude)
#'
#' This function loads a list or dataframe containing easting and northing and outputs longitude and latitude using the provided crs.
#' @param long numerical string(s) consisting geographic coordinate specific to the east-west
#' position of a point on the Earth's surface
#' @param lat numerical string(s) consisting geographic coordinate specific to the north-south
#' position of a point on the Earth's surface
#' @param crs Default is 27700 for United Kingdom
#' @return Returns a dataframe with longitude and latitude converted to easting and northing
#' @import sp
#' @export
long_lat_to_east_north <- function(long, lat, crs= 27700) {
  wgs84 =  "+init=epsg:4326"
  proj =  paste0("+init=epsg:",crs)
  output =  cbind(long,lat)
  no_na = !is.na(long)
  spatialobject <- sp::spTransform(sp::SpatialPoints(list(long[no_na],lat[no_na]),proj4string=sp::CRS(wgs84)),sp::CRS(proj))
  output[no_na,] =  spatialobject@coords
  output <- as.data.frame(output)
  colnames(output)[which(names(output) == "long")] <- "easting"
  colnames(output)[which(names(output) == "lat")] <- "northing"
  return(output)
}



