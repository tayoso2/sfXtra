
# install dependencies for *split_my_linestrings()* function --------------
devtools::install_github("jmt2080ad/polylineSplitter")

# install from git ---------------------------------------------------------
devtools::install_github("tayoso2/sfXtra")

# load the libraries -------------------------------------------------------
library(sfXtra)

# install package from CRAN only if not installed, and load the library
if (!require(testthat)) install.packages('testthat')
library(testthat)

# first set the current WD using the below, then load the data
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# check to ensure the above worked
getwd()

# load datasets
base::load("./test_data/sfXtra_data.rdata")

# Before testing each function, pass each function to a df/object
#  and test on previously saved df or object -------------------------------

# function 1
elevation_df <-
  get_elevation(x = ele1_load, AssetID = "Asset_Number", src = "aws")

# function 2
nearest_df <- find_nearest(blockage_sf_load, pipe_sf_load)

# function 3
out1 <- east_north_to_long_lat(295189, 305193)

# function 4
out2 <- long_lat_to_east_north(out1$long, out1$lat)

# function 5
out3 <- east_north_to_long_lat(out2$easting, out2$northing)

# function 6
nearest_columns_df <-
  get_nearest_feature_column(blockage_sf_load, pipe_sf_load, c("id", "length.x"))

# function 7
one_to_one_distance_df <-
  get_one_to_one_distance(blockage_pipe_sf,
                          "geometry.x",
                          "geometry.y",
                          splits = 2,
                          centroid = FALSE)

# function 8
break_pipe_sf_load_df <- break_to_smallest(pipe_sf_load)

# function 9
split_pipe_sf_load_using_rules_df <-
  split_lines_using_rules(
    break_pipe_sf_load_df,
    max_length = 20,
    length_col = "length_m",
    messaging = 5
  )

# function 10
split_pipe_sf_load_using_rules_fixed_df <-
  fix_xymax(split_pipe_sf_load_using_rules_df)

# function 11
split_pipe_sf_load_df <-
  split_my_linestrings(
    split_pipe_sf_load_using_rules_fixed_df,
    length_col = "length_m",
    splits_number = "splits_in_meters",
    uid = "id"
  )


# Unit Testing ------------------------------------------------------------

test_that("check dataframes for get_elevation() test are equal", {
  expect_equal(elevation_df_test, elevation_df)
})

test_that("check dataframes for find_nearest() test are equal", {
  expect_equal(nearest_df_test, nearest_df)
})

test_that("check dataframes for get_nearest_feature_column() test are equal",
          {
            expect_equal(nearest_columns_df_test, nearest_columns_df)
          })

test_that("check dataframes for get_one_to_one_distance() test are equal",
          {
            expect_equal(one_to_one_distance_df_test, one_to_one_distance_df)
          })

test_that("check dataframes for break_to_smallest() test are equal", {
  expect_equal(elevation_df_test, elevation_df)
})

test_that("check dataframes for split_lines_using_rules() test are equal",
          {
            expect_equal(
              split_pipe_sf_load_using_rules_df_test,
              split_pipe_sf_load_using_rules_df
            )
          })

test_that("check dataframes for fix_xymax() test are equal", {
  expect_equal(
    split_pipe_sf_load_using_rules_fixed_df_test,
    split_pipe_sf_load_using_rules_fixed_df
  )
})

test_that("check dataframes for split_my_linestrings() test are equal", {
  expect_equal(split_pipe_sf_load_df_test, split_pipe_sf_load_df)
})

test_that("test that out1 and out3 are equal", {
  expect_equal(out1, out3)
})

test_that("test that convertcoordinate functions are not empty", {
  expect_output(print(out1), NULL)
  expect_output(print(out2), NULL)
  expect_output(print(out3), NULL)
})

