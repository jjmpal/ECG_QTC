library(magrittr)

options(repos = c(CRAN = "https://cloud.r-project.org"))

list_packages <- c("xgboost",
                   "pdp",
                   "smoof",
                   "mlrMBO",
                   "lhs",
                   "shapviz",
                   "ggfittext",
                   "gggenes",
                   "BBmisc",
                   "ParamHelpers",
                   "DiceKriging",
                   "broom",
                   "iml",
                   "Metrics",
                   "table1",
                   "ggpubr",
                   "ggpmisc")

dir.create("cran/source", showWarning = FALSE, recursive = TRUE)
all_packages <- miniCRAN::pkgDep(list_packages, repos = "https://cloud.r-project.org")
found_packages <- list.files("cran/source/", recursive = TRUE) %>%
  stringr::str_replace_all(c("_.*" = "", "src/contrib/" = ""))

missing_packages <- setdiff(all_packages, found_packages)

if (length(missing_packages) > 0) {
  miniCRAN::makeRepo(pkgs = missing_packages,
                     path = "cran/source/",
                     repos = "https://cran.r-project.org")
}

zip::zip("my_cran.zip", files = "cran", recurse = TRUE)
