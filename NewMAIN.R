##### This is the main code for Travel Cost Modeling (following Murdock 2006) #####
# This file was started April 19, 2022
# The goal of this file is to take in a DF for a discrete choice model, 
# and estimate travel cost ASCs.

# Required packages
require(haven) # reads .dta
require(dplyr) # Blessed are the plumbers
require(readxl)  # reads .xlsx
require(Rchoice) # pkg for choice modeling w/ random parameters.

###############################################################################
#### Data read-in ####

ProjectDirectory <- getwd()
setwd(ProjectDirectory)

if(!exists("DATAIMPORT_on")){ # Check if script is loaded.
  source("DataImport.R")
}

setwd(ProjectDirectory)

if(!exists("DATACLEANING_on")){ # Check if script is loaded.
  source("DataCleaning.R")
}

setwd(ProjectDirectory)
###############################################################################

# I think The next step is to attempt to get Roger's Gauss code to work
# ^ AKA dclGaussAttempt.R

#### Run the first stage discrete choice model ####

test <- T
