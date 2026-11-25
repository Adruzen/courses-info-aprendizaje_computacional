RSS <- function(y) {
    if length.y == 0 
        return(0)
    sum((y - mean(y))^2)
}


dividePointSetWithRssCost <- function(set, point, dimension) {
    leftSet <- subset(set, set[,dimension] <= point)
    rightSet <- subset(set, set[,dimension] > point)
    cost = RSS(leftSet) + RSS(rightSet)
    return list(leftSet, rightSet, cost)
}


doBestRssDivision <- function(set) {
    bestCost <- Inf
    bestDimension <- 0
    bestPoint <- 0
    
    
}