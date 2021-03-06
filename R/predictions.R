#' Add predictions to a data frame
#'
#' @param data A data frame used to generate the predictions.
#' @param model,var `add_predictions` takes a single `model`; the
#'   output column will be called `pred`
#' @param ... `gather_predictions` and `spread_predictions` take
#'   multiple models. The name will be taken from either the argument
#'   name of the name of the model.
#' @param .pred,.model The variable names used by `gather_predictions`.
#' @return A data frame. `add_prediction` adds a single new column,
#'   `.pred`, to the input `data`. `spread_predictions` adds
#'   one column for each model. `gather_predictions` adds two columns
#'   `.model` and `.pred`, and repeats the input rows for
#'   each model.
#' @export
#' @examples
#' df <- tibble::data_frame(
#'   x = sort(runif(100)),
#'   y = 5 * x + 0.5 * x ^ 2 + 3 + rnorm(length(x))
#' )
#' plot(df)
#'
#' m1 <- lm(y ~ x, data = df)
#' grid <- data.frame(x = seq(0, 1, length = 10))
#' grid %>% add_predictions(m1)
#'
#' m2 <- lm(y ~ poly(x, 2), data = df)
#' grid %>% spread_predictions(m1, m2)
#' grid %>% gather_predictions(m1, m2)
add_predictions <- function(data, model, var = "pred") {
  data[[var]] <- stats::predict(model, data)
  data
}

#' @rdname add_predictions
#' @export
spread_predictions <- function(data, ...) {
  models <- tibble::lst(...)
  for (nm in names(models)) {
    data[[nm]] <- stats::predict(models[[nm]], data)
  }
  data
}

#' @rdname add_predictions
#' @export
gather_predictions <- function(data, ..., .pred = "pred", .model = "model") {
  models <- tibble::lst(...)

  df <- purrr::map2(models, .pred, add_predictions, data = data)
  names(df) <- names(models)

  dplyr::bind_rows(df, .id = .model)
}
