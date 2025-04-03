XGBoostHyperparameters <-
  R6::R6Class(
    "optimize_xgboost_hyperparameters",
    list(
      plink_location = NULL,
      cv_folds = NULL,
      XGBmatrix = NULL,
      early_stopping_rounds = NULL,
      eval_metric = NULL,
      booster = NULL,
      objective = NULL,
      design_steps = NULL,
      opt_steps = NULL,
      n_threads = NULL,
      debug = NULL,
      initialize = function(XGBmatrix,
                            eval_metric = "rmse",
                            booster = "gbtree",
                            objective = "reg:squarederror",
                            cv_folds = 4,
                            early_stopping_rounds = 100,
                            design_steps = 50,
                            opt_steps = 150,
                            n_threads = 4,
                            debug = FALSE) {
        stopifnot(!missing(XGBmatrix))
        self$XGBmatrix <- XGBmatrix
        self$cv_folds <- cv_folds
        self$early_stopping_rounds <- early_stopping_rounds
        self$eval_metric <- eval_metric
        self$booster <- booster
        self$objective <- objective
        self$design_steps <- design_steps
        self$opt_steps <- opt_steps
        self$n_threads <- n_threads
        self$debug <- debug
        invisible(self)
      },
      smoof_func = function(x) {
        xgbcv <- xgboost::xgb.cv(params = list(
          booster = self$booster,
          objective = self$objective,
          eval_metric = self$eval_metric,
          eta = x["eta"],
          max_depth = x["max_depth"],
          min_child_weight = x["min_child_weight"],
          gamma = x["gamma"],
          alpha = x["alpha"],
          lambda = x ["lambda"],
          subsample = x["subsample"],
          colsample_bytree = x["colsample_bytree"]),
          data =  self$XGBmatrix ,
          nround = x["nrounds"],
          nfold = self$cv_folds,
          stratified = FALSE,
          early_stopping_rounds = self$early_stopping_rounds,
          nthread = self$n_threads,
          maximize = FALSE,
          verbose = self$debug)
        xgbcv$evaluation_log[,glue::glue("test_{self$eval_metric}_mean")] %>% min()
      },
      smoof_params = ParamHelpers::makeParamSet(
        ParamHelpers::makeIntegerParam("nrounds", lower = 10, upper = 500),
        ParamHelpers::makeNumericParam("eta", lower = 0.001, upper = 0.1, trafo = function(x) round(x, 3)),
        ParamHelpers::makeNumericParam("gamma", lower = 0, upper = 5, trafo = function(x) round(x, 3)),
        ParamHelpers::makeNumericParam("lambda", lower = 0, upper = 10, trafo = function(x) round(x, 3)),
        ParamHelpers::makeNumericParam("alpha", lower = 0, upper = 10, trafo = function(x) round(x, 3)),
        ParamHelpers::makeIntegerParam("max_depth", lower = 2, upper = 5),
        ParamHelpers::makeIntegerParam("min_child_weight", lower = 5, upper = 100),
        ParamHelpers::makeNumericParam("subsample", lower = 0.6, upper = 0.9, trafo = function(x) round(x, 3)),
        ParamHelpers::makeNumericParam("colsample_bytree", lower = 0.6, upper = 0.9, trafo = function(x) round(x, 3))),
      smoof_obj = function() {
        smoof::makeSingleObjectiveFunction(
          name = "optimize_xgboost_hyperparameters",
          fn = self$smoof_func,
          par.set = self$smoof_params,
          minimize = TRUE)
      },
      smoof_design = function() {
        ParamHelpers::generateDesign(n = self$design_steps,
                                     par.set = ParamHelpers::getParamSet(self$smoof_obj()),
                                     trafo = FALSE,
                                     fun = lhs::randomLHS)
      },
      smoof_control = function() {
        mlrMBO::setMBOControlTermination(mlrMBO::makeMBOControl(), iters = self$opt_steps)
      },
      run = function() {
        mlr_run <- mlrMBO::mbo(fun = self$smoof_obj(),
                               design = self$smoof_design(),
                               control = self$smoof_control(),
                               show.info = TRUE)
        mlr_run[["x"]] %>%
          purrr::list_modify(eval_metric =  self$eval_metric,
                             booster = self$booster,
                             objective = self$objective)
      }
    )
  )
