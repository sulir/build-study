plot_errors <- function(builds, column, filename, label) {
  errors <- prop.table(table(builds[, column])) * 100
  errors <- sort(errors, decreasing=T)
  
  write.csv(errors, sprintf("tables/%s.csv", column))
  latex <- round(errors, 2)
  write.table(latex, sprintf("tables/%s.tex", filename),
    quote=F, sep=" & ", eol=" \\\\\n", col.names=F)
  
  pdf(sprintf("figures/%s.pdf", filename), 7, 3.8)
  par(mai=c(0.7, 3, 0, 0.2), mgp=c(2.2, 1, 0))
  label <- sprintf("Failure by %s [%%]", label)
  errors <- errors[row.names(errors) != 'uncategorized']
  barplot(rev(head(errors, 15)), horiz=T, las=1, xlab=label)
  dev <- dev.off()
}

error_types <- function(builds, tool) {
  builds <- builds[builds$status %in% F, ]
  filename <- sprintf("types-%s", tolower(tool))
  plot_errors(builds[builds$tool %in% tool, ], "error", filename, "type")
}

error_categories <- function(builds) {
  builds <- builds[builds$status %in% F, ]
  cat(sprintf("types: %d\n", length(unique(builds$error))))
  cat(sprintf("categories: %d\n", length(unique(builds$category)) - 1))
  categorized = 1 - (nrow(builds[builds$category == 'uncategorized', ]) / nrow(builds))
  cat(sprintf("categorized: %s\n", to_percent(categorized)))

  plot_errors(builds, "category", "categories", "category")
}