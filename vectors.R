# 3.2 ATOMIC VECTORS
# There are four primary types of atomic vectors: logical, integer, double and character
# which contains strings. Collectively integer and double are known as numeric vectors.
# There are two rare types: comlex and raw. I won't discuss them further
# because complex numbers are rarely needed in statyistics and raw vectors
# are a special type that's only needed when handling binary data.

# 3.2.1 SCALARS

# Each of the four primary types had a special syntax to create an individual value,
# AKA a scalar.
# --Logicals can be written in full TRUE or FALSE or abbreviated T or F
# --Doubles can be specified in decimal (0.1234), scientific (1.23e4), or hexadecimal
# (0xcafe) form. There are three special values unique to doubles: Inf, -Inf and 
# NAN. These are special values defined by floating point standard.
# --Integers are written similarly to doubles but must be followed by L (1234L,
# 1e4L or 0xcafeL). and can not contain fractional values
# --Strings are surrounded by "" or '' special characters are escaped.

# 3.2.2 Making longer vectors with c()

# To create longer vectors from schorter ones, use c() short for combine:

lgl_var <- c(TRUE, TRUE)
int_var <- c(1L, 6L, 10L)
dbl_var <- c(1, 2.5, 4.4)
chr_var <- c("These are", "some strings")
