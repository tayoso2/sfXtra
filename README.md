# sfXtra

## Summary

'GetElevation' takes your R Object consiting of assetid, latitude and longitude. Most importantly, the function removes rows of latitude and longitude with NA, calculates the elevation of the other rows and merges them all back. The output is your input dataframe and the elevation column.

'FindNearest' accepts two sf objects x and y and determines the nearest feature in y for every feature in x. Then it returns a datatable containing all rows from x with the corresponding nearest feature from y. A column representing the distance between the features is also included.


### Installation

There are a variety of methods for installing packages directly from gitlab. You may want to research these and find the most appropriate for you. 

You can try running the following code from within R Studio (assuming you know your gitlab username and password and your account has access to the repo):

    cred <- git2r::cred_user_pass(username = "Username", 
                                  password = rstudioapi::askForPassword("Password"))
                                  
    devtools::install_git("https://gitlab.com/arcadis-code-repository/arcadisgen/sfxtra.git",credentials = cred)


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
* R installation and R packages (dplyr,elevatr,magrittr,units,sf)


--------------------------------------------------------------------------------------

## Copyright and metadata 

### **Copyright** 
Copyright (c) 2020 Arcadis Nederland B.V. 

Without prior written consent of Arcadis Nederland B.V., this code may not be published or duplicated. 
