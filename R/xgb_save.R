#'
#'
#' @param
#'
#' @return
#'
#' @export
xgb_save <- function(x, name = "nested_xgboost", dir = "rds") {
  dir.create(dir, showWarnings = FALSE)
  x %>%
    purrr::map(~purrr::list_modify(.x, train_obj = purrr::zap(), test_obj = purrr::zap())) %>%
    purrr::map(~purrr::list_modify(.x, model = xgboost::xgb.save.raw(.x$model, raw_format = "json"))) %>%
    saveRDS(file = glue::glue("{dir}/{name}.rds"))
}
