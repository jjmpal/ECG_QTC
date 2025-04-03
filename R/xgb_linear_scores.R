#'
#'
#' @param
#'
#' @return
#'
#' @export
xgb_linear_scores <- function(model, matrix) {
  yhat <- predict(model, matrix)
  y <- xgboost::getinfo(matrix, "label")
  rmse <- sqrt(mean((y - yhat)^2))
  mae <- mean(abs(y - yhat))
  r2 <- 1 - sum((y - yhat)^2) / sum((y - mean(y))^2)
  tibble::tibble(RMSE = rmse, MA = mae, R2 = max(r2, 0))
}
