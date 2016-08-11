#!/usr/bin/env Rscript
source("association.R")
source("errors.R")
source("general.R")

setwd(commandArgs(TRUE)[1])
dir.create("figures", showWarnings=F)
dir.create("tables", showWarnings=F)

builds <- read.csv("analyzed.csv", stringsAsFactors=F)

tool_chart(builds)
tools_present(builds)
status_chart(builds)

error_types(builds, "Gradle")
error_types(builds, "Maven")
error_types(builds, "Ant")
error_categories(builds)

tool_bar_chart(builds)
tool_association(builds)
all_associations(builds)
