# Long Parameter List

In our early programming days, we were taught to pass in as parameters everything needed by a function. This was understandable because the alternative was global data, and global data quickly becomes evil. But long parameter lists are often confusing in their own right.

If you can obtain one parameter by asking another parameter for it, you can use Replace Parameter with Query to remove the second parameter. Rather than pulling lots of data out of an existing data structure, you can use Preserve Whole Object to pass the original data structure instead. If several parameters always fit together, combine them with Introduce Parameter Object. If a parameter is used as a flag to dispatch different behavior, use Remove Flag Argument.

Classes are a great way to reduce parameter list sizes. They are particularly useful when multiple functions share several parameter values. Then, you can use Combine Functions into Class to capture those common values as fields. If we put on our functional programming hats, we'd say this creates a set of partially applied functions.
