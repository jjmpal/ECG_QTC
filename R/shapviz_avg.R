#' Add random number columns in data frame with specific seed to validate machine learning algorightms
#'
#' @param
#'
#' @return
#'
#' @export
#'
shapviz_avg <- function(model, train_obj, n = 5) {
  sv <- shapviz::shapviz(object = model, X_pred = train_obj$matrix)

  groups <- generage_pca_grouping(train_obj$df, n)

  shap_avg_n <- as.data.frame(sv$S) %>%
    tibble::add_column(groupid = groups) %>%
    dplyr::summarise(across(everything(), mean), .by = groupid) %>%
    dplyr::select(-groupid) %>%
    as.matrix()

  features_avg_five <- as.data.frame(sv$X) %>%
    tibble::add_column(groupid = groups) %>%
    dplyr::summarise(across(everything(), mean), .by = groupid) %>%
    dplyr::select(-groupid)

  shapviz::shapviz(shap_avg_n, features_avg_five)
}
