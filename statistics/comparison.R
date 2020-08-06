#!/usr/bin/env Rscript
source("general.R")

stacked_barchart <- function(data, filename, colors, textwidth) {
  pdf(filename, 7, 1.4)
  par(mar=c(2, 4.5, 1.5, 1.5), mgp=c(3.5, 0.8, 0.1), xpd=T)

  barplot(data, horiz=T, col=colors, legend.text=row.names(data), ylab="year", axes=F, las=1,
    args.legend=list(horiz=T, x="topleft", inset=c(-0.015, -0.45), text.width=textwidth, bty="n"))
  labels <- seq(0, 1, by=0.25)
  axis(1, at=labels, labels=to_percent(labels))

  dev <- dev.off()
}

tool_comparison <- function(builds) {
  builds$tool[is.na(builds$tool)] <- "no/undetected"
  tools <- prop.table(table(builds$tool, builds$year), 2)
  tools <- tools[, ncol(tools):1]

  stacked_barchart(tools, "figures/tools-comp.pdf", c("darkmagenta", "darkolivegreen3", "dodgerblue4", "gray50"), 0.18)
}

status_comparison <- function(builds) {
  builds <- builds[!is.na(builds$tool), ]
  builds$status[builds$status] <- "a"
  builds$status[builds$status %in% F] <- "b"
  builds$status[is.na(builds$status)] <- "c"
  states <- prop.table(table(builds$status, builds$year), 2)
  row.names(states) <- c("success", "failure", "timeout")
  states <- states[, ncol(states):1]

  stacked_barchart(states, "figures/status-comp.pdf", c("darkseagreen2", "indianred", "lightblue1"), 0.355)
}

if (length(commandArgs(TRUE)) != 1)
  print("Usage: comparison.R dir_with_2016_and_2020_results")

setwd(commandArgs(TRUE)[1])
dir.create("figures", showWarnings=F)

old <- read.csv("2016/builds.csv", stringsAsFactors=F)
new <- read.csv("2020/builds.csv", stringsAsFactors=F)

old$year <- 2016
new$year <- 2020
builds <- rbind(old, new)

tool_comparison(builds)
status_comparison(builds)
