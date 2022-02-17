# 18.1 Introduction

# To compute on the language, we first need to understand its structure. That requires
# some new vocabulary, some new tools, and some new ways of thinking about R code.
# The first of there is the distinction between an operation and its result. Take
# the following code, which multiplies a variable x by 10 and saves the result to a new
# variable called y. It doesn't work because we haven't defined a variable called x.

y <- x * 10

# It would be nice if we coulc capture the intent of the code without executing it.
# In other words, how can we separate our description of the action from the action
# itself?

# One way is to use rlang::expr():

z <- rlang::expr(y <- x * 10)
z

# expr() returns an expression, an object that captures the structure of the code
# without evaluating it(i.e. running it). If you have an expression, you van evaluate
# it with base::eval()

x <- 4
eval(z)
y

# The focus of this chapter is the data structures that underlie expressions. Mastering
# this knowledge will allow you to inspect and modify captured code, and to generate
# code with code. We'll come back to expr() in Chapter 19, and to eval() in chapter20

library(rlang)
library(lobstr)

# 18.2 Abstract Syntax Trees

# Expressions are also called abstract syntax trees (ASTs) because the structure of code
# is hierarchical and can be naturally represented as a tree. Understanding the tree
# structure is crucial for inspecting and modifying expression (i.e. metaprogramming)

# 18.2.1 Drawing

lobstr::ast(f(x, "y", 1))

lobstr::ast(f(g(1, 2), h(3, 4, i())))

# 18.2.3 Infix calls

# Every call in R can be written in tree form because any call can be written in prefix form
# (Section 6.8.1). Take y <- x * 10 again: what are the functions that are being called?
# It is not as easy to spot as f(x, 1) because this expression contains two infix calls:
# <- and *. That means that these two lines of code are equivalent:

y <- x * 10
y
`<-`(y, `*`(x, 10))
y

lobstr::ast(y <- x * 10)

# There really is no difference between the ASTs, and if you generate an expression with
# prefix calls, R will still print it in infix forms:

expr(`<-`(y, `*`(x, 10)))

# Expressions
# Colectively, the data structures present in the AST are called expressions. An 
# expression is any member of the set of base types created by parsing code: constant
# scalars, symbols, call objects and pairlists. These are the data structures used to
# represent captured code from expr(), adn is_expression(expr(...)) is always true.
# Constants, sumbols and call objects are the most important, and are discussed below.
# Pairlists and empty symbols are more specialised and we'll come back to them in Sections
# 18.6.1 And Section 18.6.2.

#NB: In base R documentation "expression" is used to mean two things. As well as
# the definition above, expression is also used to refer to the type of object
# returned by expression() and parse(), which are basically lists of expressions
# as defined above. In this book I'll call these expression vectors and I'll come
# back to them in Section 18.6.3

# 18.3.1 Constants

# Scalar constants are the simplest component of the AST. More precisely, a constant
# is either NULL or a length-1 atomic vector (or scalar, Section 3.2.1) like TRUE
# 1L, 2.5 or "x". You can test for a constant with rlang::is_syntactic_literal()

# Constants are self-quoting in the sense that the expression used to represent a 
# constant is the same constant.

identical(expr(TRUE), TRUE)

identical(expr(1), 1)

identical(expr(2L), 2L)

identical(expr("x"), "x")

# 18.3.2 Symbols

# A symbol represents the name of an object like x, mtcars, or mean. In base #, the
# terms symbol and name are used interchangeably (i.e. is.name() is identical to
# is.symbol()), but in this book I used symbol consistently because "name" had many
# other meanings.

# You can create a symbol in two ways: by capturing code that references an object
# with expr(), or turning a string into a symbol with rlang::sym()

expr(x)

sym("x")

# You can turn a symbol back into a string with as.character() or rlang::as_String().
# as_string() has the advantage of clearly signalling that you'll get a character vector 
# of length1.

rlang::as_string(rlang::expr(x))

# You can recognize a symbol because it's printed without quotes, str() tells you that
# it's a symbol, and is.symbol() is TRUE.

str(rlang::expr(x))

rlang::is_symbol(rlang::expr(x))

# The symbol type is not vectorised, i.e. a symbol is always length 1. If you want
# multiple symbols, you'll need to pyt them in a list using (e.g.) rlang::syms()

# 18.3.3 Calls

# A call object represents a captued function call. Call objects are special type
# of list where the first component specifies the function to call(ussually a symbol),
# and the remaining elements are the arguments for that call. Call objects create branches
# in the AST, because calls can be nested inside other calls.

# You can identify a call object when printed because it looks just like a function
# call. Confusingly typeof() and str() print "language" for call objects but is.call()
# returns TRUE.

lobstr::ast(read.table("important.csv", row.names = FALSE))

x <- rlang::expr(read.table("important.csv", row.names = FALSE))

typeof(x)

is.call(x)

# 18.3.3.1 Subsetting

# Calls generally behave like lists, i.e. you can use standard subsetting tools.
# The first element of the call object is the function to call, which is usually
# a symbol:

x[[1]]

is.symbol(x[[1]])

# The remainder of the elements are the arguments:

as.list(x[-1])

# You can extract individual arguments with [[ or if named $:
x[[2]]

x$row.names

# You can determine the number of arguments in a call object by subtracting 1 from 
# its length:

length(x) -1

# Extracting specific arguments from calls is challenging because of R's flexible rules
# for argument mathcing: it could potentially by in any location, with the full name,
# with an abbreviated name, ot with no name. To work around this problem, you can use
# rlang::call_standardise() which standaredises all arguments to use the full name:

rlang::call_standardise(x)

# NB if the function uses ... it's not possible to standardise all arguments

# Calls can be modified in the same way as lists

x$header <- TRUE
x

# 18.3.3.2 Function position

# The first element of the call object is the function position. This contains the function
# that will be calles when the object is evaluated, and is ussually a symbol:

lobstr::ast(foo())

# While R allows you to surround the name of the funtion with quotes, the parser 
# converts it to a symbol:

lobstr::ast("foo"())

# However, sometimes the function doesn't exist in the current environment and you need 
# to do some computation to retrieve it: for example, if the function is in another package,
# is a method of an R6 object, or is created by a function factory. In this case,
# the function position will be occupied by another call:

lobstr::ast(pkg::foo(1))

lobstr::ast(obj$foo(1))

lobstr::ast(foo(1)(2))


# 18.3.3.3 Constructing

# You can construct a call object from its components using rlang::call2() . The first
# argument is the name of the function to call(wither as a string, a symbol or another
# call). The remaining arguments will be passed along to the call:

rlang::call2("mean", x = rlang::expr(x), na.rm = TRUE)

rlang::call2(rlang::expr(base::mean), x = rlang::expr(x), na.rm = T)

# Infix calls created in this way still print as usual.

rlang::call2("<-", rlang::expr(x), 10)

# Using call2() to create complex expression is a bit clunky. You'll learn another
# technique in chapter 19.

# 18.3.4 Summary

# The following table summarises the appearance of the different expression subtypes
# in str() and typeof():

# Both base R and elang provide function for testing for each type of input, although
# the types covered are slightly different. You can easily tell them apart because
# all the base functions start with is. and the rlang functions start with is_.

# 18.3.5 Exercises


