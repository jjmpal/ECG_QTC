#' Add random number columns in data frame with specific seed to validate machine learning algorightms
#'
#' @param
#'
#' @return
#'
#' @export
xgb_outer_loop <- function(data,
                           outcome,
                           seed = 20241216,
                           iteration = 1,
                           n_outer_folds = 3,
                           n_inner_folds = 3,
                           eval_metric = "rmse",
                           booster = "gbtree",
                           objective = "reg:squarederror",
                           early_stopping_rounds = 100,
                           design_steps = 50,
                           opt_steps = 150,
                           n_threads = 16,
                           rands = NULL,
                           debug = FALSE) {
  stopifnot(!missing(data), !missing(outcome), n_outer_folds >= 2)

  data_with_groups <- data %>%
    dplyr::filter(!is.na({{outcome}})) %>%
    dplyr::mutate(group = caret::createFolds(data %>% dplyr::pull({{outcome}}), k = n_outer_folds, list = FALSE))

  purrr::map(seq(n_outer_folds),
             ~xgb_inner_loop(data = data_with_groups,
                             group = .x,
                             outcome = {{outcome}},
                             seed = seed + cantor_pairing(.x, iteration),
                             n_inner_folds = n_inner_folds,
                             eval_metric = eval_metric,
                             booster = booster,
                             objective = objective,
                             early_stopping_rounds = early_stopping_rounds,
                             design_steps = design_steps,
                             opt_steps = opt_steps,
                             n_threads = n_threads,
                             rands = rands,
                             debug = debug))
}
