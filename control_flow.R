## 5 CONTROL FLOW

# 5.2 CHOICES

# The basic form of an if statement in R is as follows:

if (codition) true_action
if (condition) true_action else false_action

# if condition is TRUE, true_action is evaluated; if condition is FALSE, the optional
# false_action is evaluated.

# Typically the actions are compound statements contained wihin {:

grade <- function(x) {
  if (x > 90){
    "A"
  } else if (x > 80) {
    "B"
  } else if (x > 50) {
    "C"
  } else {
    "F"
  }
}

# if returns a value so that you can assign the results

x1 <- if (TRUE) 1 else 2
x2 <- if (FALSE) 1 else 2

c(x1,x2)

# (I recommend assinging the results of an if statement only when the entire
# expression fits on one line; otherwise it tends to be hard to read)

# When you use the single argument form without an else statement, if invisibly
# returns NULL if the condition is FALSE. since functions like c() and paste()
# dro NULL inputs, this allows for a compact expression of certain idioms.

greet <- function(name, birthday) {
  paste0(
    "hi ", name,
    if (birthday) " and HAPPY BIRTHDAY"
  )
}

greet("Maria", FALSE)

greet("Jaime", TRUE)

# 5.2.1 Invalid inputs

# The condition should evaluate to a single TRUE or FALSe. Most other inputs will 
# generate an error.

if ("x") 1

if (logical()) 1

if (NA) 1

# The exception is a logical vector of length greater than 1, which generates a warning

if (c(TRUE, FALSE)) 1

# In R 3.5.0 and greater, you can turn this into an error by setting an environment
# variable

Sys.setenv("_R_CHECK_LENGTH_1_CONDITION_" = "true")
if(c(TRUE, FALSE)) 1

# This is good practise since it reveals a clear mistake

# 5.2.2 Vectorised if

# Given that if only works with a single TRUE or FALSE, you might wonder what to do
# if you have a vector of logical value. Handling vectors of values is the job of
# ifelse(): a vectorised function with test, yes and no vectors that will be recy
# cled to the same length

x <- 1:10
ifelse(x %% 5 ==0, "XXX", as.character(x))

ifelse(x %% 2 ==0,"even", "odd")

# Note the missing values will be propagated into the output

# I recommend using ifelse() only when the yes and no vectors are the same type as
# it is otherwise hard to predict the output type

# Another vectorised equivalent is the more general dplyr::case_when() . It uses
# a special syntax to allow any number of conditon-vector pais:

dplyr::case_when(
  x %% 35 == 0 ~ "fizz buzz",
  x %% 5 == 0 ~ "fizz",
  x %% 7 == 0 ~ "buzz",
  is.na(x) ~ "???",
  TRUE ~ as.character(x)
)

# 5.2.3 SWITCH() STATEMENT



x_option <- function(x) {
  switch(x, 
         a = "option 1",
         b = "option 2",
         c = "option 3",
         stop("Invalid `x` value")
         )
}

# The last component of a switch() should always throw an error, otherwise 
# unmatched inputs will invisibly return NULL:

(switch("c", a = 1, b = 2))

# If multiple inputs have the same output, you can leave the right hand side of =
# empty and the input will "fall through" to the next value. The mimics the behaviour
# of C's switch statement:

legs <- function(x) {
  switch(x,
         cow =,
         horse = ,
         dog = 4,
         human = ,
         chicken =2,
         plant = 0,
         stop("Unkown input"))
}

legs("cow")

legs("dog")

# It is also possible to use switch() with a numeric x, but it is harder to read,
# and has undesirable failure modes if x is not a whole number. I recommend 
# using switch only with character inputs

# 5.2.4 EXCERCISES

# What type of vector does each of the following calls to ifelse() return?

ifelse(TRUE, 1, "no")

ifelse(NA, 1, "no")

# 2. Why does the following code work?

x <- 1:10

if (length(x)) "not empty" else "empty"

x <- numeric()

if (length(x)) "not empty" else "empty"

# 5.3 LOOPS

# for loops are used to iterate over items in a vector. They have the following
# basic form:

for (item in vector) perform_action


# For each item in vector, perform_action is called once; updating the value of 
# item each time.

for (i in 1:3) {
  print(i)
}

# When iterating over a vector of indices, it's conventional to use very short
# variable names like i, j or k

# N.B.: for assigns the item to the current environment, overwriting any existing
# variable with the same name:

i <- 100
for (i in 1:3) {}

i

# There are two ways to terminate a for loop early:

# next exits the current iteration

# break exits the entire for loop

for (i in 1:10){
  if (i < 3)
    next
  
  
  print(i)
  
  if (i >= 5)
    break
}

# 5.3.1 COMMON PITFALLS

# There are three common pitfalls to watch out for when using for. First, if you
# 're generating data, make sure to preallocate the output container. Otherwise
# the loop will be very slow; see Sections 23.2.2 and 24.6 for more details.
# The vector() function is helpful here

means <- c(1, 50, 20)
out <- vector("list", length(means))
for (i in 1:length(means)) {
  out[[i]] <- rnorm(10, means[[i]])
}
# Next, beware of iterating over 1:length(x), which will fail in unhelpful ways
# if x has length 0:

means <- c()
out <- vector("list", length(means))
for (i in 1:length(means)) {
  out[[i]] <- rnorm(10, means[[i]])
}

# This occurs because : works with both increasing and decreasing sequences:

1:length(means)

# Use seq_along(x) instead. It always returns a value the same length as x:

seq_along(means)

out <- vector("list", length(means))
for (i in seq_along(means)) {
  out[[i]] <- rnorm(10, means[[i]])
}

# Finally, you might encounter problems when iterating over S3 vectors, as loops
# typically strip the attributes:

xs <- as.Date(c("2020-01-01", "2020-01-01"))
for (x in xs) {
  print(x)
}

# Work arround this by calling [[ yourself:

for (i in seq_along(xs)) {
  print(xs[[i]])
}

# 5.3.2 RELATED TOOLS

# For loops are useful if you know in advance the set of values that you want to iterate
# over. If you don't know, there are two related tools with more flexible specifications

# while(condition) action: performs action while condition is TRUE

# repeat(action): repeats forever until it encounters a break

# R does not have an equivalent to do {action} while (condition) syntax found
# in other languages

# You can rewrite any for loop to use while instead, and you can rewrite any while
# loop to use repeat, but the converses are not true. That means while is more
# flexible than for, and repeat is more flexible than while. It's good practise
# however to use the least-flexible solution so you should use for whenever possible

# Generally speaking you shouldn't need to use for loops for data analysis tasks
# as map() and apply() already provide less flexible solutions to most problems
# See chapter 9
