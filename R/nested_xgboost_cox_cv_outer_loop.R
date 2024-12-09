#'
#'
#' @param
#'
#' @return
#'
#' @export
nested_xgboost_cox_cv_outer_loop <- function(data,
                                             seed,
                                             iteration,
                                             interaction_list,
                                             event_incident,
                                             n_random = 6,
                                             n_outer_folds = 5,
                                             ...) {
  set.seed(seed + iteration)

  cols2ids <- function(object, col_names) {
    LUT <- seq_along(col_names) - 1
    names(LUT) <- col_names
    rapply(object, function(x) LUT[x], classes = "character", how = "replace")
  }


  data_with_groups <- data %>%
    add_random_number_columns(n_random) %>% 
    dplyr::mutate(group = caret::createFolds(factor(data[[event_incident]]), k = n_outer_folds, list = FALSE))

  interaction_list_fid <- cols2ids(interaction_list, colnames(data_with_groups))

  partial_nested_xgboost_cox_cv_inner_loop <- purrr::partial(nested_xgboost_cox_cv_inner_loop,
                                                             data = data_with_groups,
                                                             interaction_list = interaction_list_fid,
                                                             event_incident = event_incident,
                                                             ...)

  seq(n_outer_folds) %>%
    purrr::map(partial_nested_xgboost_cox_cv_inner_loop)
}
