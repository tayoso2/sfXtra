.onAttach <- function(libname, pkgname) {
  packageStartupMessage("You have loaded sfXtra ------------------------------------>>")
}

#' Get the elevation from a dataframe with longitude and latitude.
#'
#' This function loads a dataframe. It accepts an R object with unique asset
#' identifier (default set as "AssetID"), longitude and latitude to calculate elevation.
#' @param x An R object or a dataframe
#' @param AssetID An asset base containing the AssetID, Longitude and Latitude
#' @param Longitude numerical string(s) consisting geographic coordinate specific to the east-west
#' position of a point on the Earth's surface
#' @param Latitude numerical string(s) consisting geographic coordinate specific to the north-south
#' position of a point on the Earth's surface
#' @param unit elevation unit in "meters" or "feet"
#' @param src this selects which API to use. "epqs"is best for US only, "aws" for large number of points (>500)
#' @return Returns the same dataframe with the addition of the "elevation" column
#' @import sf
#' @import units
#' @import elevatr
#' @import magrittr
#' @import dplyr
#' @import rgdal
#' @export
get_elevation <- function(x,
                          AssetID = "AssetID",
                          Longitude = "Longitude",
                          Latitude = "Latitude",
                          unit = "meters",
                          src = "epqs") {
  # Accepts an asset with unique asset identifier, longitude and latitude to calculate elevation regardless
  # of NAs in Latitude, Longitude columns.
  #
  # Returns:
  #   The same dataframe with all rows and an additional "elevation" column.
  #   This column represents the point elevation using x(long) and y(lat) as input.
  #   Note that this object contains no geometry.

  # convert unique id column name to standard "AssetID". Select the important colnames
  colnames(x)[which(names(x) == AssetID)] <- "AssetID"
  colnames(x)[which(names(x) == Longitude)] <- "Longitude"
  colnames(x)[which(names(x) == Latitude)] <- "Latitude"

  # extract the rows for which altitude cannot be calculated

  if (isTRUE(mean(x$Latitude, na.rm = T)) < 180 &
      (mean(x$Longitude, na.rm = T) < 180)) {
    y <- dplyr::select(x, AssetID, Longitude, Latitude) %>%
      dplyr::mutate(Longitude = as.numeric(Longitude),
                    Latitude = as.numeric(Latitude))

    # use this to exclude rows without longitude and latitude
    ele_na <-
      x %>% dplyr::filter(is.na(Longitude)) %>% dplyr::filter(is.na(Latitude)) %>% dplyr::select(AssetID, Longitude, Latitude)
    ele <- x %>% dplyr::anti_join(ele_na, by = colnames(ele_na)[1])

    #set crs to global 4326
    ele <-
      st_as_sf(ele,
               coords = c("Longitude", "Latitude"),
               crs = 4326)
    prj_dd <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"

    # get_elev_point calculates the altitude
    elevate <-
      get_elev_point(ele,
                     unit = "meters",
                     prj = prj_dd,
                     src = src)
    output <- data.frame(elevate)
    output$elev_units <-
      NULL
    elevate <- NULL
    ele_na <- NULL
    output$geometry <- NULL

    # merge both the new altitudes and original data using AssetID
    output <- dplyr::select(output, AssetID, elevation)
    output <- dplyr::full_join(x, output, by = colnames(y)[1])

    # revert unique id column name and other column names
    colnames(output)[which(names(output) == "AssetID")] <- AssetID
    colnames(output)[which(names(output) == "Longitude")] <-
      Longitude
    colnames(output)[which(names(output) == "Latitude")] <- Latitude
    return(output)

  } else {
    message("Error: Convert to WGS84 longlat")
  }
}

