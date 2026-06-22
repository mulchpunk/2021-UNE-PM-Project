# Shared helper functions for 2021_UNE_PM_Comp.Rmd and 2021_UNE_LeafSEM.Rmd

data_summary <- function(data, varname, groupnames) {
  varname <- as.character(varname)
  data %>%
    dplyr::summarise(
      n       = sum(!is.na(.data[[varname]])),
      mean_val = mean(.data[[varname]], na.rm = TRUE),
      sd_val  = sd(.data[[varname]], na.rm = TRUE),
      .by = all_of(groupnames)
    ) %>%
    dplyr::mutate(se = sd_val / sqrt(n)) %>%
    dplyr::select(-sd_val, -n) %>%
    dplyr::rename(!!varname := mean_val)
}

stderr <- function(x) {
  se <- sd(x) / sqrt(length(x))
  print(se)
}

ci95_median_boot <- function(x, conf = 0.95, R = 5000, na.rm = TRUE) {
  if (na.rm) x <- x[!is.na(x)]
  if (length(x) == 0) return(c(median = NA_real_, lower = NA_real_, upper = NA_real_))
  boot_medians <- replicate(R, median(sample(x, replace = TRUE)))
  alpha <- 1 - conf
  lower <- quantile(boot_medians, alpha / 2)
  upper <- quantile(boot_medians, 1 - alpha / 2)
  return(c(median = median(x), lower = lower, upper = upper))
}

fmt_p <- function(p) {
  if (is.na(p)) return(NA_character_)
  if (p < 0.001) return("< 0.001")
  paste0("p = ", signif(p, 3))
}

fmt_r2 <- function(r2) {
  if (is.na(r2)) return(NA_character_)
  paste0("R² = ", signif(r2, 3))
}

# Summarize a variable by group using ci95_median_boot, returning a tidy data frame.
# group_vars: character vector of grouping column names (become the first columns)
# col_names: full column name vector including group columns, then "var","lower","upper"
make_median_summary <- function(data, var, group_vars, col_names) {
  out <- cbind(aggregate(data[[var]], data[group_vars], FUN = ci95_median_boot))
  out <- as.data.frame(as.matrix(out))
  colnames(out) <- col_names
  numeric_cols <- col_names[seq(length(group_vars) + 1, length(col_names))]
  out[numeric_cols] <- lapply(out[numeric_cols], as.numeric)
  out
}
