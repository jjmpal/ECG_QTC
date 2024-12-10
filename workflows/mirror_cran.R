library(magrittr)

options(repos = c(CRAN = "https://cloud.r-project.org"))

list_packages <- c("xgboost", "pdp", "smoof", "mlrMBO", "lhs", "shapviz", "ggfittext", "gggenes", "BBmisc", "ParamHelpers", "DiceKriging")

dir.create("cran/sources", showWarning = FALSE, recursive = TRUE)

miniCRAN::pkgDep(list_packages) %>%
  miniCRAN::makeRepo(path = "cran/sources", repos = "https://cran.r-project.org")

zip::zip("my_cran.zip", files = "cran", recurse = TRUE)
