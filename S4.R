library(methods)


setClass("Person",
         slots = c(
           name = "character",
           age = "numeric"
         ))

john <- new("Person", name = "John Smith", age = NA_real_)

# is gives the class name
is(john)

john@name

slot(john, "age")

# Accessors of fields are often these dreaded generics again....
# Creating the setters and getters for person

setGeneric("age", function(x) standardGeneric("age"))
setGeneric("age<-", function(x, value) standardGeneric("age<-"))

# Defining the methods with setMethod

setMethod("age", "Person", function(x) x@age)
setMethod("age<-", "Person", function(x, value) {
  x@age <- value
  x
})

age(john) <- 50
age(john)

# Sloop can recognize S4 classes

sloop::otype(john)
sloop::ftype(age)

# 13.1
# Q1
attributes(lubridate::period())

example_12345 <- lubridate::period(
  c(1, 2, 3, 4, 5),
  c("second", "minute", "hour", "day", "week")
)

example_12345

str(example_12345)

# Full declaration of S4 class
# Prototype is optional but should actually always be included

setClass("Person",
         slots = c(
           name ="character",
           age = "numeric"
         ),
         prototype = list(
           name = NA_character_,
           age = NA_real_
         ))

me <- new("Person", name="Hadley")
str(me)

# inheritance uses the contains keyword

setClass("Employee",
         contains = "Person",
         slots = c(
           boss = "Person"
         ),
         prototype = list(
           boss = new("Person")
         ))
str(new("Employee"))

# To determine which classes an object inherits from use is()

is(new("Person"))

is(new("Employee"))

# or to test:
is(john, "Person")

# Watch out when redifening classes whilst there are already living instances

setClass("A", slots = c(x = "numeric"))

a <- new("A", x = 10)

setClass("A", slots = c(a_different_slot = "numeric"))
a


# Writing a helper is often a convenient thing to do

Person <- function(name, age = NA) {
  age <- as.double(age)

  new("Person", name = name, age = age)
}

Person("Hadley")

# Constructors automatically check that the slots have correst classes

Person(mtcars)

# Extra checks have to be written yourself like Person could be a vector. Then name and age should be equal lengths

Person("Hadley", c(30, 37))

# To enforce this write a setValidity function

setValidity("Person", function(object) {
  if (length(object@name) != length(object@age)){
    "@name and @ age should be the same length"
  } else {
    TRUE
  }
})

# Now an invalid object can no longer be created

Person("Hadley", age = c(30, 37))

# Editing an existing object to be invalid still works tho

alex <- Person("Alex", age = 30)
alex@age <- 1:10

# However one can check the validity later on:

validObject(alex)


# 15.4 Generics and methods
# TO create a S4 generic use:

setGeneric("myGeneric", function(x) standardGeneric("myGeneric"))

# It is bad practice to use {} in the generics as it triggers a special case that
# is a lot more expensive.

# DONT DO THIS!
setGeneric("myGeneric", function(x) {
  standardGeneric("myGeneric")
})

# 15.4.1 Signature
# Like setClass(), setGeneric() had many other arguments. There is only one that you
# need to know about: signature. This allows you to control the arguments that are
# used for method dispatch. If signature is not supplied, all arguments (apart from ...)
# are used. It is occasionally useful to remove arguments from dispatch. This allows
# you to require that methods provide arguments like verbose = TRUE or queit = FALSE
# but they don't take part in dispatch.

setGeneric("myGeneric",
           function(x, ..., verbose = TRUE) standardGeneric("myGeneric"),
           signature = "x")

# 15.4.2 Methods
# A generic isn't useful without some methods, and in S4 you define methods with
# setMethod(). There are three important arguments: the name of the generic, the
# name of the class and the method itself.

setMethod("myGeneric", "Person", function(x){
  # method implementation
})

# More formally, the second argument to setMethod() is called the signature. In S4
# unlike S3 the signature can include multiple arguments. This makes method dispatch in
# S4 substantially more complicated, but avoids having to implement double-dispatch
# as a special case. We'll talk more about multiple dispatch in the next dection.
# setMethod() has other arguments, but you should never use them,

# To list all the methods that belong to a generic, or that are associated with a class, use
# methods("generic") or methods(class = "class"); to find the implementation of a specific
# method use selectMethod("generic", "class")

methods(class = data.frame)

# the most commonly defined S4 method that controls printing is show(), which controls
# how the object appears when it is printed. To define a method for an existing
# generic you must first determine the arguments. You can get those from the documentation
# or by looking at the args() of the generic:

args(getGeneric("show"))

# The show generic needs a single argument object.

setMethod("show", "Person", function(object) {
  cat(is(object)[[1]], "\n",
      " Name: ", object@name, "\n",
      " Age: ", object@age, "\n",
      sep = ""
  )

})
john
# 15.4.4 Accessors
# Slots should be considered an internal implementation detail: they can change without
# warning and user code should avoid accessing them directly. Instead, all user-accessible
# slots should be accompanies by a pair os accessors. If the slot is unique to the class
# this can just be a function.

person_name <- function(x) x@name

# Typically, however, you'll define a generic so that multiple classes can use the same
# interface:
setGeneric("name", function(x) standardGeneric("name"))
setMethod("name", "Person", function(x) x@name)

name(john)

# if the slot is also writeable, you should provide a setter funtion. You should always
# include validObject() in the setter to prevent the user from creatint invalid objects.

setGeneric("name<-", function(x, value) standardGeneric("name<-"))
setMethod("name<-", "Person", function(x, value) {
  x@name <- value
  validObject(x)
  x
})
name(john) <- "Jon Smythe"
name(john)

name(john) <- letters
setGeneric("age", function(x) standardGeneric("age"))
setMethod("age", "Person", function(x) x@age)

setGeneric("age<-", function(x, value) standardGeneric("age<-"))
setMethod("age<-", "Person", function(x, value) {
  x@age <- value
  validObject(x)
  x
})
age(john) <- 12
age(john)
