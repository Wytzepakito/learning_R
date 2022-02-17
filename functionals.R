# A functional is a function that takes a function as an input and returns a vector
# as otuput. Here's a simple functional: it calls the function provided as input with
# 1000 random uniform numbers

randomise <- function(f) f(runif(1e3))

randomise(mean)
randomise(sum)

# Some functionals include the for loop replacements such as lapply(), apply() and
# tapply(); or map()

# For loops are generally avoided in R because many people believe they are slow
# But the main downside is that they are not very flexible.

install.packages("purr")
library(purr)
