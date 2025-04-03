#' Cantor pairing number for unique mapping
#'
#' @param dir: target directory
#'
#' @return save function
#'
#' @export
cantor_pairing <- function(x, y) {
  (x + y) * (x + y + 1) / 2 + y
}
