

#' Calculate the number of times to split/divide each linestring.
#'
#' This function loads an R object with the active geometry "linestring" and breaks each of these multilines to many lines.
#' @param x An sf object or sf dataframe consisting of a column denoting the length of geometry
#' @param max_length Maximum length for each linestring. Can also be a floating value.
#' @param length_col The field with the length variable
#' @param messaging Progress indicator displaying in Percentages
#' @return Returns the same R object with the addition of "splits_in_meters" columns
#' @import magrittr
#' @import dplyr

get_bearing_per_row <- function(df = df) {
  df_2 <- df %>%
    dplyr::mutate(from_geom = start_point,
           to_geom = end_point)

  # iterate through each row
  for (i in 1:nrow(df_2)) {

    # get the 4 important coords for calculating the bearing
    x_to <- as.matrix(df_2$from_geom[[i]], col = 2)[1, 1]
    y_to <- as.matrix(df_2$from_geom[[i]], col = 2)[1, 2]
    x_from <- as.matrix(df_2$to_geom[[i]], col = 2)[1, 1]
    y_from <- as.matrix(df_2$to_geom[[i]], col = 2)[1, 2]

    # add bearing for each row
    df_2$bearing[[i]] <-
      (360 + (90 - ((180 / pi) * atan2(y_to - y_from, x_to - x_from)
      ))) %% 360
    df_2$x_from[[i]] <- x_from
    df_2$y_from[[i]] <- y_from
    df_2$x_to[[i]] <- x_to
    df_2$y_to[[i]] <- y_to
  }
  return(df_2)
}
