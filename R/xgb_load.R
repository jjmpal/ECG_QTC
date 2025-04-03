#'
#'
#' @param
#'
#' @return
#'
#' @export
xgb_load <- function(x, group_column = "group") {
  load_model <- function(obj) {
    model_raw <- xgboost::xgb.load.raw(obj$model, as_booster = TRUE)
    feature_names <- obj$train_obj$matrix %>% colnames
    model_raw$feature_names <- feature_names
    model_raw
  }
  readRDS(x) %>%
    purrr::map(~purrr::list_modify(.x,
                                   train_obj = xgb_model_matrix(.x$data %>% dplyr::select(-dplyr::one_of({{group_column}})), .x$train_index, .x$outcome),
                                   test_obj = xgb_model_matrix(.x$data %>% dplyr::select(-dplyr::one_of({{group_column}})), -.x$train_index, .x$outcome))) %>%
    purrr::map(~purrr::list_modify(.x, model = load_model(.x)))
}
