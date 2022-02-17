library("sloop")

# 13.4.4
# 1



# 2
s3_methods_class("table")

#3
s3_methods_class("ecdf")


s3_methods_generic("print")


data(mtcars)
mod <- lm(mpg ~ wt, data = mtcars)
class(unclass(mod))




class(ordered("x"))
class("x")


new_secret <- function(x = double()){
  stopifnot(is.double(x))
  structure(x, class = "secret")
}

print.secret <- function(x, ...) {
  print(strrep("x", nchar(x)))
  invisible(x)
}

x <- new_secret(c(15, 1, 456))
x

# x is now secret, however this does not work when indexing
s3_dispatch(x[1])

x[1]

# To fix this write:

`[.secret` <- function(x, i) {
  new_secret(NextMethod())
}

x[1]


# To allow subclassing the constructor needs ... and a class argument

new_secret <- function(x, ..., class = character()) {
  stopifnot(is.double(x))

  structure(
    x,
    ...,
    class = c(class, "secret")
  )
}

#This allows the subclass constructor to call the parent class constructor with additional arguments.
# For example a supersecret class might also hide the number of characters.

new_supersecret <- function(x) {
  new_secret(x, class = "supersecret")
}

print.supersecret <- function(x, ...) {
  print(rep("xxxxx", length(x)))
  invisible(x)
}


x2 <- new_supersecret(c(15, 1, 456))
x2

# Careful thought has to be put into revising the methods since if we now run:

x2[1:3]

# The original secret class is returned
# A solution is given in the vctrs package
library("vctrs")

vec_restore.secret <- function(x, to, ...) new_secret(x)
vec_restore.supersecret <- function(x, to, ...) new_supersecret(x)

# now vec_Restore can be used in the [.secret method

`[.secret` <- function(x, ...) {
  vctrs::vec_restore(NextMethod(),x)
}

x2[1:3]


# q2
s3_methods_class("POSIXt")
s3_methods_class("POSIXct")
s3_methods_class("POSIXlt")


generic2 <- function(x) UseMethod("generic2")
generic2.a1 <- function(x) "a1"
generic2.a2 <- function(x) "a2"
generic2.b <- function(x) {
  class(x) <- "a1"
  NextMethod()
}

generic2(structure(list(), class = c("b", "a2")))

