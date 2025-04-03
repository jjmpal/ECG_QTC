#'
#'
#' @param
#'
#' @return
#'
#' @export
generage_pca_grouping <- function(df, size, seed = 2024) {
  set.seed(seed)
  n_centers <- nrow(df) %/% size
  pca_result <- df %>%
    dplyr::mutate(dplyr::across(dplyr::everything(), ~ ifelse(is.na(.), mean(., na.rm = TRUE), .))) %>%
    prcomp()
  pca_data <- as.data.frame(pca_result$x[, 1:2])
  kmeans(pca_data, centers = n_centers)$cluster
}
