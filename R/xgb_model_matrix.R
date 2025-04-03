#'
#'
#' @param
#'
#' @return
#'
#' @export
xgb_model_matrix <- function(x, index, outcome) {
  dset <- x[index,]
  labels <- dset %>% dplyr::pull({{outcome}})
  matrix <- dset %>%
    dplyr::select(-{{outcome}}) %>%
    data.matrix()
  dmatrix <- xgboost::xgb.DMatrix(matrix, label = labels)
  list(dmatrix = dmatrix, df = dset, matrix = matrix, labels = labels)
}
