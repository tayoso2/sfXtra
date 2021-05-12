

# install dependencies for *split_my_linestrings()* function --------------
devtools::install_github("jmt2080ad/polylineSplitter")

# install from git ---------------------------------------------------------
devtools::install_github("tayoso2/sfXtra", ref = "tayodev")

# Install all required packages for this example
required_packages <- c("devtools",
                       "testthat",
                       "elevatr",
                       "units",
                       "dplyr",
                       "sp",
                       "sf",
                       "rgdal",
                       "lwgeom",
                       "plyr",
                       "magrittr")
installed_packages <- installed.packages()[,1]
to_install <- setdiff(required_packages, installed_packages)

if (length(to_install) > 0) {
  print("Installing required packages")
  install.packages(to_install,
                   repos = "https://cloud.r-project.org")
} else {
  print("Required packages already installed")
}


# load the libraries -------------------------------------------------------
library(devtools)
library(elevatr)
library(testthat)
library(dplyr)
library(plyr)
library(magrittr)
library(units)
library(sp)
library(sf)
library(rgdal)
library(lwgeom)



