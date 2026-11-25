# ── CART: Classification and Regression Trees ────────────────────────────────

# Impurity measures

#' Gini impurity of a class label vector.
#' Returns 0 for a pure node, approaches 1 as classes become equally mixed.
#' @param y factor or character vector of class labels
#' @return scalar in [0, 1)
gini <- function(y) {
  p <- table(y) / length(y)
  1 - sum(p^2)
}

#' Variance (MSE around the mean) of a numeric vector.
#' Used as the impurity measure for regression nodes.
#' A pure node where all values are equal returns 0.
#' @param y numeric vector of target values
#' @return scalar >= 0
mse <- function(y) {
  if (length(y) == 0) return(0)
  mean((y - mean(y))^2)
}

#' Weighted impurity of a binary split.
#' Each child's impurity is weighted by its proportion of total samples.
#' @param left        y values that went to the left child
#' @param right       y values that went to the right child
#' @param impurity_fn function to compute impurity (gini or mse)
#' @return scalar weighted impurity
split_cost <- function(left, right, impurity_fn) {
  n <- length(left) + length(right)
  (length(left) / n) * impurity_fn(left) +
    (length(right) / n) * impurity_fn(right)
}

#' Find the best axis-aligned split across all features and thresholds.
#' Tries all midpoints between consecutive unique values for each feature.
#' @param X    numeric matrix (n x d)
#' @param y    response vector (class labels or numeric)
#' @param task "classification" or "regression"
#' @return list with fields: cost, feature (column index), threshold
best_split <- function(X, y, task) {
  impurity_fn <- if (task == "classification") gini else mse
  best <- list(cost = Inf, feature = NULL, threshold = NULL)

  for (j in seq_len(ncol(X))) {
    vals <- sort(unique(X[, j]))
    thresholds <- (vals[-length(vals)] + vals[-1]) / 2

    for (thr in thresholds) {
      left  <- y[X[, j] <= thr]
      right <- y[X[, j] >  thr]
      if (length(left) == 0 || length(right) == 0) next

      cost <- split_cost(left, right, impurity_fn)
      if (cost < best$cost) {
        best <- list(cost = cost, feature = j, threshold = thr)
      }
    }
  }
  best
}

#' Recursively build a CART tree.
#' Stops when max_depth is reached, node has <= min_samples points, or node is pure.
#' @param X           numeric matrix of features for current node
#' @param y           response vector for current node
#' @param task        "classification" or "regression"
#' @param max_depth   maximum allowed depth
#' @param min_samples minimum samples required to attempt a split
#' @param depth       current depth (internal, starts at 0)
#' @return nested list representing the tree node (leaf or internal)
build_tree <- function(X, y, task, max_depth, min_samples, depth = 0) {
  # Leaf conditions
  leaf_val <- if (task == "classification") {
    names(which.max(table(y)))
  } else {
    mean(y)
  }

  if (depth >= max_depth || length(y) <= min_samples ||
      length(unique(y)) == 1) {
    return(list(leaf = TRUE, value = leaf_val))
  }

  sp <- best_split(X, y, task)
  if (is.null(sp$feature)) return(list(leaf = TRUE, value = leaf_val))

  mask <- X[, sp$feature] <= sp$threshold
  list(
    leaf      = FALSE,
    feature   = sp$feature,
    threshold = sp$threshold,
    left      = build_tree(X[mask, , drop = FALSE],  y[mask],  task, max_depth, min_samples, depth + 1),
    right     = build_tree(X[!mask, , drop = FALSE], y[!mask], task, max_depth, min_samples, depth + 1)
  )
}

#' Traverse the tree for a single sample and return its prediction.
#' @param node current tree node (list)
#' @param x    numeric vector of length d (one sample)
#' @return predicted class label (character) or value (numeric)
predict_one <- function(node, x) {
  if (node$leaf) return(node$value)
  if (x[node$feature] <= node$threshold) predict_one(node$left,  x)
  else                                    predict_one(node$right, x)
}

# ── Public API ────────────────────────────────────────────────────────────────

#' Train a CART tree
#' @param X         numeric matrix of features
#' @param y         response vector (factor or numeric)
#' @param task      "classification" or "regression"
#' @param max_depth maximum tree depth (default 5)
#' @param min_samples minimum samples to attempt a split (default 2)
cart_train <- function(X, y, task = c("classification", "regression"),
                       max_depth = 5, min_samples = 2) {
  task <- match.arg(task)
  X <- as.matrix(X)
  structure(
    list(tree = build_tree(X, y, task, max_depth, min_samples), task = task),
    class = "CART"
  )
}

#' Predict with a trained CART model
predict.CART <- function(model, X) {
  X <- as.matrix(X)
  preds <- apply(X, 1, function(x) predict_one(model$tree, x))
  if (model$task == "classification") factor(preds) else as.numeric(preds)
}

# ── Demo ──────────────────────────────────────────────────────────────────────

set.seed(42)

# Classification: iris
cat("=== Classification (iris) ===\n")
X_cls <- as.matrix(iris[, 1:4])
y_cls <- iris$Species
model_cls <- cart_train(X_cls, y_cls, task = "classification", max_depth = 4)
preds_cls <- predict.CART(model_cls, X_cls)
cat("Accuracy:", mean(preds_cls == y_cls), "\n\n")

# Regression: synthetic
cat("=== Regression (synthetic) ===\n")
n <- 100
X_reg <- matrix(runif(n * 2), ncol = 2)
y_reg <- 3 * X_reg[, 1] - 2 * X_reg[, 2] + rnorm(n, sd = 0.1)
model_reg <- cart_train(X_reg, y_reg, task = "regression", max_depth = 5)
preds_reg <- predict.CART(model_reg, X_reg)
cat("RMSE:", sqrt(mean((preds_reg - y_reg)^2)), "\n")
