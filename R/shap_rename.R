#'
#'
#' @param
#'
#' @return
#'
#' @export
shap_rename <- function(obj, dict) {
  features <- obj$X %>% colnames
  colnames(obj$X) <- ifelse(features %in% names(dict), dict[features], features)
  colnames(obj$S) <- ifelse(features %in% names(dict), dict[features], features)
  invisible(obj)
}
