
#' Load 2 sf objects, x and y and the fields you want to add from y to x
#'
#' Accepts two sf objects x and y and appends the columns of the nearest feature in y to
#' every feature in x. I use "fields" and "columns" interchangeably.
#' @param x An sf object containing the features for which you want find the nearest fields in y
#' @param y An sf object containing fields to be assigned to x
#' @param col The column(s) to add from y to x. Default is "column_1"
#' @return Returns the same sf object in x with the addition of the column(s) from y
#' @import sf
#' @export

get_nearest_feature_column <- function(x, y, col = "column_1") {
  res <- y[st_nearest_feature(x, y), col]
  x[, col] <- res[, col]
  return(x)
}
