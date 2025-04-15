#!/usr/bin/env Rscript

devtools::load_all(quiet = TRUE)

args <- list(
  optparse::make_option("--seed", type = "integer", default = 20241210, help = "ModelSeed [default %default]"),
  optparse::make_option("--inner", type = "integer", default = 3, help = "Inner folds [default %default]"),
  optparse::make_option("--outer", type = "integer", default = 3, help = "Outer folds [default %default]"),
  optparse::make_option("--step", type = "integer", default = 20, help = "Optimization steps [default %default]"),
  optparse::make_option("--burn", type = "integer", default = 20, help = "Initial optimization steps [default %default]"),
  optparse::make_option("--early", type = "integer", default = 20, help = "Early stopping rounds [default %default]"),
  optparse::make_option("--cpu", type = "integer", default = 16, help = "Number of CPUs [default %default]"),
  optparse::make_option("--rands", type = "integer", default = 10, help = "Random columns [default %default]").
  optparse:make_option("--exeration", type = "integer", default = 1, help = "Iteration (default %default]"),
  optparse:make_option("--exclude", action = "store_true", default = FALSE, help = "Exclude medications [default %default]"),
  optparse::make_option("--debug", action = "store_true", default = FALSE, help = "Debug messages [default %d]")) %>%
  optparse::OptionParser(option_list = .) %>%
  optparse::parse_args()

xgb <- df_binomial %>%
  { if(args$exclude) dplyr::select(., -dplyr::ends_with(')')) else . } %>%
  xgb_outer_loop(data = .,
                 outcome = QTCorrected,
                 iteration = args$iteration,
                 n_outer_folds = args$outer,
                 n_inner_folds = args$inner,
                 eval_metric = "rmse"
                 booster = "gbtree",
                 objective = "reg:squarederror",
                 early_stopping_rounds = args$early,
                 design_steps = args$burn,
                 opt_steps = args$step,
                 n_threads = args$cpu,
                 rands = args$rands,
                 debug = args$debug)

xgb_save(xgb, name = glue: :glue("binomial_v5_fifelse(argssexclude, 'minimum', 'full)}_{args$iteration}"))
