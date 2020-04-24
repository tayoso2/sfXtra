cred <- git2r::cred_user_pass(rstudioapi::askForPassword("username"), 
                              rstudioapi::askForPassword("Password"))

devtools::install_git("https://gitlab.com/tayoso2/sfxtra.git",credentials = cred)
#devtools::install_git("https://gitlab.com/arcadis-code-repository/arcadisgen/sfxtra.git",credentials = cred)

library(sfXtra)

# load the data
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# check to ensure the above worked
getwd()

ele1_load <- readRDS("test/ele1.rds")
blockage_sf_load <- readRDS("test/blockage_sf.rds")
pipe_sf_load <- readRDS("test/pipe_sf.rds")

# test the functions

## GetElevation()
GetElevation(x = ele1_load,AssetID = "Asset_Number",src = "aws")

## FindNearest()
FindNearest(blockage_sf_load,pipe_sf_load[1:10,])

## ConvertCoordinates
out1 <- east_north_to_long_lat(295189,305193)
out1
out2 <- long_lat_to_east_north(out1$long,out1$lat)
out2
out3 <- east_north_to_long_lat(out2$easting,out2$northing)
out3 #out3 and out1 should be same

