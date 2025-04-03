#' Add random number columns in data frame with specific seed to validate machine learning algorightms
#'
#' @param
#'
#' @return
#'
#' @export
add_randomized_binom_column <- function(df, n, prob) {
  random_values <- function(n, prob = runif(1, min = 0, max = 1)) {
    factor(rbinom(n = nrow(df), size = 1, prob = prob))
  }
  stringr::str_c("rbinom_", seq_len(n)) %>%
    purrr::reduce(~tibble::add_column(.x, '{.y}' := random_values(nrow(df))), .init = df)
}
