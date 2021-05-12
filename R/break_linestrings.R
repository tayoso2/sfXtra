


#' Load an sf object with l feature consisting of a multilinestring geometry. This function is used in break_to_smallest()
#'
#' This function loads a sf object with 1 feature, the active geometry "multilinestring"
#' and breaks each of these lines to many points that make up the lines and stitches them back up
#' to linestrings.
#' @param line An sf object or sf dataframe with 1 multilinestring row/feature
#' @param geom Field containing the active geometry
#' @param crs Default is 27700
#' @return Returns the same sf object with the multilinestring replaced with smaller linestrings
#' @import sf
#' @import units
#' @import magrittr
#' @export

break_one_line <- function(line, geom = "geometry", crs = 27700) {
  # cast the geometry from multiline to points
  points <- st_cast(st_geometry(line), "POINT")

  # pair the points and cast back to linestrings
  n <- length(points) - 1
  x <- lapply(
    X = 1:n,
    FUN = function(p) {
      x_pair <- st_combine(c(points[p], points[p + 1]))
      x <- st_cast(x_pair, "LINESTRING")
    }
  )
  for (i in 1:length(x)) {
    if (i == 1) {
      x2 <- x[[i]]
    } else{
      x2 <- c(x2, x[[i]])
    }
  }

  # transform to sf dataframe and set crs
  x2 <- as.data.frame(x2)
  x2 <- st_sf(x2)
  x2 <- st_set_crs(x2, crs)

  # add on the length
  x2$length_m <- st_length(x2$geometry)
  x2$length_m <- round(as.numeric(x2$length_m), 4)

  # remove old geometries
  line[, c("geometry")] <- NULL

  # add on the original columns
  x2 <- merge(as.data.frame(x2), line, by = NULL)
  return(x2)
}


#' Load an sf object with linestring geometry.
#'
#' This function loads an sf object with the active geometry "linestring" and breaks each of these larger lines to many lines.
#' @param lines An sf object or sf dataframe
#' @param messaging Progress indicator displaying in Percentages.
#' @return Returns the same sf object with the addition of line geometries gotten from the broken larger linestrings
#' @import plyr
#' @export

break_to_smallest <- function(lines, messaging = 5) {
  # iterate through all rows in the sf object using break_one_line()
  for (i in 1:nrow(lines)) {
    # message for progress
    if (i %% (nrow(lines) / messaging) == 0) {
      message(paste0((i / nrow(lines)) * 100), "% at ", Sys.time())
    }

    if (i == 1) {
      lines_2 <- break_one_line(lines[i,])
    } else{
      lines_2 <- plyr::rbind.fill(break_one_line(lines[i,]), lines_2)
    }
  }
  return(lines_2)
}



#' Calculate the number of times to split/divide each linestring.
#'
#' This function loads an R object with the active geometry "linestring" and a column denoting the
#' minimum value to split large lines with.
#' @param x An sf object or sf dataframe consisting of a column denoting the length of geometry
#' @param max_length Maximum length for each linestring. Can also be a floating value.
#' @param length_col The field with the length variable
#' @param messaging Progress indicator displaying in Percentages
#' @return Returns the same R object with the addition of "splits_in_meters" column
#' @import sf
#' @export

split_lines_using_rules <-
  function(x,
           max_length = 20,
           length_col = "length_m",
           messaging = 5) {
    # nullify the active geometry
    if ("sf" %in% class(x)) {
      message(paste0("Nullifying the active geometry"))
      st_geometry(x) <- NULL
    }
    for (i in 1:nrow(x)) {
      # message for progress
      if (i %% (nrow(x) / messaging) == 0) {
        message(paste0((i / nrow(x)) * 100), "% at ", Sys.time())
      }

      row_length = x[i, "length_m"]

      # calculate number of splits required
      if (row_length > max_length) {
        my_mulitiplier = ceiling(row_length / max_length)
        no_of_splits = my_mulitiplier
        x[i, "splits_in_meters"] <- row_length / no_of_splits
      }
      else{
        x[i, "splits_in_meters"] <- row_length
      }
    }
    return(x)
  }


#' Fix the xmax and/or ymax when the xmax and xmin are the same and/or the ymax and ymin are the same.
#'
#' This function loads an sf object with the active geometry type "linestring" and adds 0.1 to at least one of the xmax or ymax if the xmax and xmin are the same or the ymax and ymin are the same.
#' @param x An sf object with the active geometry type "linestring" which is a pair of points and a matrix of 4 values representing 2 points.
#' @return Returns the same sf object with the fixed xmax and/or ymax.
#' @import sf
#' @export

fix_xymax <- function(x) {
  # Transform x to an sf object if necessary
  if ("sf" %in% class(x)) {
    message(paste0("You have loaded an sf object"))
  }
  else{
    x <- st_sf(x)
    message(paste0("Your input data has been transformed to an sf dataframe"))
  }

  # add 0.1 to the x and/or y if the min and max are the same
  for (i in 1:nrow(x)) {
    x$geometry[[i]][4] <-
      ifelse(round(as.numeric(x[["geometry"]][[i]][3]), 1) == round(as.numeric(x[["geometry"]][[i]][4]), 1),
             as.numeric(x[["geometry"]][[i]][4]) + 0.1,
             x[["geometry"]][[i]][4])
    x$geometry[[i]][2] <-
      ifelse(round(as.numeric(x[["geometry"]][[i]][1]), 1) == round(as.numeric(x[["geometry"]][[i]][2]), 1),
             as.numeric(x[["geometry"]][[i]][2]) + 0.1,
             x[["geometry"]][[i]][2])
  }
  return(x)
}



#' Split the geometry using the splits_number column
#'
#' This function loads an sf object with the active geometry "linestring" and breaks each of these large lines to many lines.
#' @param x An sf object or sf dataframe with a length column (length_col), splits_number, and a unique idenifier.
#' @param length_col The field with the continuous "length" variable which denotes the length of the geometry.
#' @param splits_number The field with the length(in meters) to split the geometry with.
#' @param uid This column represents the unique identifier to identify the geometries which have or have not been split.
#' @return Returns a dataframe with the addition of "new_length" column
#' @import dplyr
#' @import magrittr
#' @import polylineSplitter
#' @import sp
#' @import sf
#' @export

split_my_linestrings <-
  function(x,
           length_col = "length_m",
           splits_number = "splits_in_meters",
           uid = "pipe_id") {
    x <- x %>% as.data.frame()
    x$splits_no <- x[, length_col] / x[, splits_number]

    # iterate over all the rows
    for (i in 1:nrow(x)) {
      # transform each feature to a spatial object
      x1_sp <- as_Spatial(x$geometry[i])

      # meter selection
      row_meter = x[i, splits_number]
      splits_no = x[i, "splits_no"]

      # split the linestrings
      x1_splitted <- polylineSplitter::splitLines(x1_sp, row_meter)

      # set the projection of the spatial data
      proj4string(x1_splitted) <-
        CRS(
          "+proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +ellps=airy +towgs84"
        )
      x1_splitted_sf <- st_as_sf(as(x1_splitted, "SpatialLines"))

      # add on the unique id
      x1_splitted_sf[, uid] <- x[i, uid]

      # ensure the crs is unchanged
      crs_27700 <- sp::CRS(SRS_string = "EPSG:27700")
      x1_splitted_sf <-
        st_transform(x1_splitted_sf, crs = crs_27700)

      if (i == 1) {
        out <- x1_splitted_sf
      } else{
        out <- rbind(out, x1_splitted_sf)
      }
    }

    # add a length column, exclude really small lengths
    out <- out %>%
      st_sf() %>% st_set_crs(27700) %>%
      dplyr::mutate(new_length = st_length(.),
                    new_length = as.numeric(new_length)) %>%
      dplyr::filter(new_length > 0.01)

    return(as.data.frame(out))
  }
