to_percent <- function(number) {
  paste0(round(number * 100, 2), "%")
}

pie_chart <- function(values, file_name) {
  tab <- prop.table(table(values))
  name <- names(tab)
  percent <- to_percent(as.vector(tab))
  captions <- sprintf("%s (%s)", name, percent)
  
  cat(sprintf("\n%s:\n", file_name))
  latex <- cbind(name, sub("%", "\\%", percent, fixed=T))
  write.table(latex, quote=F, sep=" & ", eol=" \\\\\n", col.names=F, row.names=F)
  cat("\n")
  
  pdf(sprintf("figures/%s.pdf", file_name), 4.7, 2)
  par(mai=c(0, 0, 0, 0))
  pie(tab, labels=captions)
  dev <- dev.off()
}

tool_chart <- function(builds) {
  tools <- builds$tool
  tools[is.na(tools)] <- "no/undetected"
  
  pie_chart(tools, "tools")
}

tools_present <- function(builds) {
  total <- nrow(builds)
  in_root <- builds[!is.na(builds$tool), ]
  cat(sprintf("Tool in root: %s\n", to_percent(nrow(in_root) / total)))
  
  anywhere <- builds[builds$Ant | builds$Gradle | builds$Maven, ]
  nonroot_count <- nrow(anywhere) - nrow(in_root)
  cat(sprintf("Tool in subdir: %s\n", to_percent(nonroot_count / total)))
  
  other <- builds[builds$Buildr | builds$Make | builds$SBT, ]
  cat(sprintf("Other tools: %s\n", to_percent(nrow(other) / total)))
  
  ant <- builds[builds$tool %in% "Ant", ]
  ivy <- ant[ant$Ivy, ]
  cat(sprintf("Ivy for Ant: %s\n", to_percent(nrow(ivy) / nrow(ant))))
  
  travis_ci <- builds[builds$Travis.CI, ]
  cat(sprintf("Travis CI: %s\n", to_percent(nrow(travis_ci) / total)))
}

status_chart <- function(builds) {
  builds <- builds[!is.na(builds$tool), ]
  status <- builds$status
  status[status] <- "success"
  status[status %in% F] <- "failure"
  status[is.na(status)] <- "timeout"
  
  cat("\n")
  print(table(status))
  pie_chart(status, "status")
}
