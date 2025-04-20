#' Inner Nested-CV loop
#'
#' @param
#'
#' @return
#'
#' @export
xgb_inner_loop <- function(data,
                           group,
                           outcome,
                           seed = 42,
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
  stopifnot(!missing(data), !missing(group), !missing(outcome))
  set.seed(seed)

  train_index <- data %>%
    dplyr::mutate(index = group != !!group) %>%
    dplyr::pull(index)

  data <- data %>%
    dplyr::select(-group) %>%
    { if (!is.null(rands)) add_randomized_binom_column(., rands) else . }

  train_obj <- xgb_model_matrix(data, train_index, {{outcome}})

  params <- XGBoostHyperparameters$new(XGBmatrix = train_obj$dmatrix,
                                       eval_metric = eval_metric,
                                       booster = booster,
                                       objective = objective,
                                       cv_folds = n_inner_folds,
                                       early_stopping_rounds = early_stopping_rounds,
                                       design_steps = design_steps,
                                       opt_steps = opt_steps,
                                       n_threads = n_threads,
                                       debug = debug)$run()

  model_obj <- xgboost::xgboost(params = params %>% purrr::list_modify(nrounds = purrr::zap()),
                                data = train_obj$dmatrix,
                                nrounds = params$nrounds,
                                nthread = n_threads,
                                early_stopping_rounds = early_stopping_rounds,
                                verbose = FALSE,
                                maximize = FALSE,
                                print_every_n = 500)

  test_obj <- xgb_model_matrix(data, !train_index, {{outcome}})

  test_scores <- xgb_linear_scores(model_obj, test_obj$dmatrix)

  list(data = data,
       outcome = rlang::as_name(rlang::ensym(outcome)),
       train_index = train_index,
       test_index = !train_index,
       train_obj = train_obj,
       test_obj = test_obj,
       params = params,
       model = model_obj,
       seed = seed,
       scores = test_scores)
}





