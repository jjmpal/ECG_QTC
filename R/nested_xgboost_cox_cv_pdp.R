#'
#'
#' @param
#'
#' @return
#'
#' @export
nested_xgboost_cox_cv_pdp <- function(results, pred_vars) {
  pdp_data_function <- function(x) {
    feature <- x[[1]]
    model_number <- x[[2]]
    model <- flatten_results[[model_number]]$model
    vars <- flatten_results[[model_number]]$vars

    data <- flatten_results[[model_number]]$data %>%
      dplyr::select(one_of(vars))

    knitrProgressBar::update_progress(pb)

    pdp::partial(model,
                 pred.var = feature,
                 train =  data,
                 type = "regression",
                 parallel = TRUE,
                 plot = FALSE) %>%
      dplyr::select(abundance = {{feature}}, yhat) %>%
      dplyr::mutate(model = model_number, Feature = feature)
  }

  flatten_results <- results %>%
    purrr::list_flatten(name_spec = "{outer}_{inner}")

  pb <- knitrProgressBar::progress_estimated(length(pred_vars) * length(results))

  purrr::cross2(pred_vars, seq_along(flatten_results)) %>%
    purrr::map_df(pdp_data_function)
}
