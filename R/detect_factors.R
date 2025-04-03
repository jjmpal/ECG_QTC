#'
#'
#' @param
#'
#' @return
#'
#' @export
detect_factors <- function(df, max_distinct = 10, debug = FALSE) {
  c_factors <- df %>%
    dplyr::select(-ends_with("_YEAR"), -ends_with("_NEVT")) %>%
    dplyr::summarise_all(dplyr::n_distinct) %>%
    tidyr::gather(column, n_distinct) %>%
    dplyr::filter(n_distinct <= max_distinct) %>%
    dplyr::pull(column)

  if (debug) purrr::map(c_factors, ~message(glue::glue("Defining {.x} as factor.")))

  dplyr::mutate(df, across(c_factors, as.factor))
}

