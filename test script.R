cred <- git2r::cred_user_pass(rstudioapi::askForPassword("username"), 
                              rstudioapi::askForPassword("Password"))

devtools::install_git("https://gitlab.com/tayoso2/sfxtra.git",credentials = cred)

library(sfXtra)

# load the data
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
ele1_load <- readRDS("test/ele1.rds")
blockage_sf_load <- readRDS("test/blockage_sf.rds")
pipe_sf_load <- readRDS("test/pipe_sf.rds")

# test the functions
GetElevation(x = ele1_load,AssetID = "Asset_Number",src = "aws")
FindNearest(blockage_sf_load,pipe_sf_load[1:10,])
