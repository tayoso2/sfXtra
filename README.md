# sfXtra

## Summary

'GetElevation' takes your R Object consisting of assetid, latitude, longitude and other columns. Most importantly, the function removes rows of latitude NA, calculates the elevation of the other rows and merges them all back. The output is your input dataframe and the 'elevation' column.

'FindNearest' accepts two sf objects x and y and determines the nearest feature in y for every feature in x. Then it returns a dataframe containing all rows from x with the corresponding nearest feature from y. A column representing the distance between the features is also included.

'Convert Coordinates' contains 2 functions, east_north_to_long_lat and long_lat_to_east_north. These functions convert easting and northing to longitude and latitude and vice versa.

There are new functions as well added to this package which have not been summarised here.

### Installation

There are a variety of methods for installing packages directly from github. You may want to research these and find the most appropriate for you. 

You can try running the following code from within R Studio or running "install.R"

```R
# install devtools libraries from cran
install.packages("devtools")

# install dependencies for *split_my_linestrings()* function
devtools::install_github("jmt2080ad/polylineSplitter")

# install sfXtra package
devtools::install_github("tayoso2/sfXtra.git")
```


## Usage
Download the repo and run "test script.R"

## Project information

### **Status**
`WORKING PROTOTYPE`

### **Authors**
* Tayo Ososanya (tayo.ososanya@arcadisgen.com)
* David Smith (david.smith@arcadisgen.com)

### **Maintainer**
* Tayo Ososanya (tayo.ososanya@arcadisgen.com)

### **Requirements**
* R installation and R packages (dplyr,elevatr,magrittr,units,sf,sp,rgdal,plyr,polylineSplitter)


--------------------------------------------------------------------------------------

## Copyright and metadata 

### **Copyright** 
Copyright (c) 2020 Arcadis Nederland B.V. 

Without prior written consent of Arcadis Nederland B.V., this code may not be published or duplicated. 