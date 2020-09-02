#!/usr/bin/env Rscript
source("general.R")

stacked_barchart <- function(data, colors, textwidth) {
  par(mar=c(2, 4.5, 1.5, 1.5), mgp=c(3.5, 0.8, 0.1), xpd=T)

  barplot(data, horiz=T, col=colors, legend.text=row.names(data), ylab="execution", axes=F, las=1, border=F,
    args.legend=list(horiz=T, x="topleft", inset=c(-0.015, -0.45), text.width=textwidth, bty="n", border=F))
  labels <- seq(0, 1, by=0.25)
  axis(1, at=labels, labels=to_percent(labels))

  dev <- dev.off()
}

tool_comparison <- function(builds) {
  builds$tool[is.na(builds$tool)] <- "no/undetected"
  tools <- prop.table(table(builds$tool, builds$year), 2)
  tools <- tools[, ncol(tools):1]

  pdf("figures/tools-comp.pdf", 7, 1.4)
  stacked_barchart(tools, c("darkmagenta", "darkolivegreen3", "dodgerblue4", "gray50"), 0.18)
}

status_comparison <- function(builds) {
  builds <- builds[!is.na(builds$tool), ]
  builds$status[builds$status] <- "a"
  builds$status[builds$status %in% F] <- "b"
  builds$status[is.na(builds$status)] <- "c"
  states <- prop.table(table(builds$status, builds$year), 2)
  row.names(states) <- c("success", "failure", "timeout")
  states <- states[, ncol(states):1]

  pdf("figures/status-comp.pdf", 7, 1.4)
  stacked_barchart(states, c("darkseagreen3", "indianred", "lightblue"), 0.355)
}

pushed_status <- function(builds) {
  execution <- builds$year[1]
  builds$pushed_year <- sub("-.*", "", builds$pushed)
  builds <- builds[!is.na(builds$status), c("status", "pushed_year")]
  
  colors <- c("darkseagreen3", "indianred")

  if (execution == 2016) {
    for (y in 2017:2020)
      builds <- rbind(builds, c(NA, y))
    colors <- c(rep(colors, times=9), rep("white", times=8))
  }

  states <- table(builds$status, builds$pushed_year)
  states <- states[, ncol(states):1]
  row.names(states) <- rev(c("success", "failure"))

  barplot(states, horiz=T, beside=T, col=rev(colors), border=F, axes=F, las=1)
  axis(1, line=-0.5)
  title(xlab="project count", line=1.5)
  title(main=sprintf("%d execution", execution), font.main=1, cex.main=1, line=-0.1)

  if (execution == 2016)
    title(ylab="last pushed year")
  else
    legend("topright", legend=rev(row.names(states)), fill=colors, border=F, bty="n", inset=c(0, 0.02))
}

pushed_status_multiplot <- function(old, new) {
  pdf("figures/status-pushed.pdf", 8, 6)
  layout(matrix(c(1, 2), nrow=1), widths=c(1.1, 0.9))
  margins <- c(2.8, 4.5, 1, 1)
  par(mar=margins, mgp=c(3.5, 0.8, 0.1))
  pushed_status(old)
  
  par(mar=margins-c(0, 2.2, 0, 0))
  pushed_status(new)
  dev <- dev.off()
}

if (length(commandArgs(TRUE)) != 1)
  stop("Usage: comparison.R dir_with_2016_and_2020_results")

setwd(commandArgs(TRUE)[1])
dir.create("figures", showWarnings=F)

old <- read.csv("2016/builds.csv", stringsAsFactors=F)
new <- read.csv("2020/builds.csv", stringsAsFactors=F)

old$year <- 2016
new$year <- 2020
builds <- rbind(old, new)

tool_comparison(builds)
status_comparison(builds)
pushed_status_multiplot(old, new)
