library(R6)


Accumulator <- R6Class("Accumulator",
                       list (
                         sum = NULL,
                         add = function(x = 1) {
                           self$sum <- self$sum + x
                           invisible(self)
                         },
                         initialize = function() {
                           self$sum <- 0
                         }
                       ))


x <- Accumulator$new()$add(4)
print(x$add(4))
x$sum


# self is returned invisibly to allow methods chaining

x$add(5)$add(10)$sum

# $initialize is called when a new class is initialized
# A few checks can be made there

Person <- R6Class("Person", list(
  name = NULL,
  age = NA,
  initialize = function(name, age = NA) {
    stopifnot(is.character(name), length(name) == 1)
    stopifnot(is.numeric(age), length(age) == 1)

    self$name <- name
    self$age <- age
  }
))

hadley <- Person$new("Hadley", age = "thirty-eight")
# Errors

hadley <- Person$new("Hadley", 20)
# Does not error

# Overwriting $print() allows you to override the default printing behaviour
# This shouyld also return invisivle(self).

Person <- R6Class(
  "Person",
  list(
    name = NULL,
    age = NA,
    initialize = function(name, age = NA) {
      self$name <- name
      self$age <- age
    },
    print = function(...) {
      cat("Person: \n")
      cat("   Name:  ", self$name, "\n", sep = "")
      cat("   Age:   ", self$age, "\n", sep = "")
      invisible(self)

    },
    ages = function(delta_age) {
      self$age <- self$age + delta_age
    }
  )
)
hadley2 <- Person$new("Hadley", 30)

# Methods can also be added after creation
#  This makes it more easy to add functions in pieces
# when writing a big class
Accumulator <- R6Class("Accumulator")
Accumulator$set("public", "sum", 0)
Accumulator$set("public", "add", function(x = 1) {
  self$sum <- self$sum + x
  invisible(self)
})

# To inherit behaviour from an existing class provide the class object to the
# inherit argument:
AccumulatorChatty <- R6Class("AccumulatorChatty",
                             inherit = Accumulator,
                             public = list(
                               add = function(x = 1) {
                                 cat("Adding ", x, "\n", sep = "")
                                 super$add(x = x)
                               }
                             ))
x2 <- AccumulatorChatty$new()
x2$add(10)$add(1)$sum

# Every R6 object had an S3 class that reflects its hierarchy of R6 claSSES.
# This means that the easiest way to determine the class (and all classes it
# inherits from) is to use class():

class(hadley2)


# The S3 hierarchy includes the base"R6" class. This provides commmon behaviour,
# including a print.R6() method which calls $print(), as described above
# To list all methods and fields use: names()

names(hadley2)


BankAccount <- R6Class(
  "BankAccount",
  list(
    money = NA,
    initialize = function(money) {
      self$money <- money
    },
    deposit = function(money) {
      self$money <- self$money + money
      invisible(self)
    },
    withdraw = function(money) {
      self$money <- self$money - money
      invisible(self)
    }
  )
)

NoOverdraftAccount <- R6Class (
  "NoOverdraftAccount",
  inherit = BankAccount,
  public = list(
    withdraw = function(money) {
      stopifnot((self$money - money) > 0)
      super$withdraw(money)
    }
  )
)

MoreOverdraftAccount <- R6Class (
  "MoreOverdraftAccount",
  inherit = BankAccount,
  public = list(
    withdraw = function(money) {
      super$withdraw(money + 25)
    }
  )
)

account_WA <- BankAccount$new(500)
account_WA$withdraw(1000)

account_WA2 <- NoOverdraftAccount$new(500)
account_WA2$withdraw(1000)

account_WA3 <- MoreOverdraftAccount$new(500)
account_WA3$withdraw(1000)

suit <- c("♠", "♥", "♦", "♣")
value <- c("A", 2:10, "J", "Q", "K")
cards <- paste0(rep(value, 4), suit)


DeckCards <- R6Class(
  "DeckCards",
  list(
    cards = NA,
    index = 1,
    initialize = function() {
      suit <- c("♠", "♥", "♦", "♣")
      value <- c("A", 2:10, "J", "Q", "K")
      self$cards <- sample(paste0(rep(value, 4), suit))
    },
    draw = function(n = 1) {
      if ((self$index + n) > length(self$cards)){
        stop("Only", length(self$cards) - self$index, " cards remaining", call = FALSE)
      }
      card <- self$cards[self$index: (self$index + n -1)]
      self$index <- self$index + n
      return(card)
    },
    reshuffle = function() {
      self$cards <- sample(self$cards)
      self$index <- 1
    }
  )

)

deckCards <- DeckCards$new()
deckCards$reshuffle()
deckCards$draw(2)

# R6 works with reference semantics so objects are not copied

y1 <- Accumulator$new()
y2 <- y1

y1$add(10)
y1
y2

# This can be solved by using clone

y2 <- y1$clone()
y1$add(10)
y1
y2

# Copy on modify semantics lead to Python like copying and replacing
x <- factor(c("a", "b", "c"))
# Subsequent setting of the levels deletes the old levels:
levels(x) <- c("c", "b", "a")

# Finalize is used to deconstruct a R6 class

TemporaryFile <- R6Class("TemporaryFile", list(
  path = NULL,
  initialize = function() {
    self$path <- tempfile()
  },
  finalize = function() {
    message("Cleaning up ", self$path)
    unlink(self$path)
  }
))

FileWriter <- R6Class("FileWriter", list(
  con = NULL,
  initialize = function(filename){
    self$con <- file(filename, open = "a")
  },
  finalize = function(){
    close(self$con)
  },
  append_line = function(x){
    cat(x, "\n", sep = "", file = self$con)
  }
))


tmp_file <- tempfile()

my_fw <- FileWriter$new(tmp_file)
readLines(tmp_file)
my_fw$append_line("First")
my_fw$append_line("Second")
readLines(tmp_file)
