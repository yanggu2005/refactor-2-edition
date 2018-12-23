# Long Function

In our experience, the programs that live best and longest are those with short functions. Programmers new to such a code base often feel that no computation ever takes place—that the program is an endless sequence of delegation. When you have lived with such a program for a few years, however, you learn just how valuable all those little functions are. All of the payoffs of indirection—explanation, sharing, and choosing—are supported by small functions.

Since the early days of programming, people have realized that the longer a function is, the more difficult it is to understand. Older languages carried an overhead in subroutine calls, which deterred people from small functions. Modern languages have pretty much eliminated that overhead for in-process calls. There is still overhead for the reader of the code because you have to switch context to see what the function does. Development environments that allow you to quickly jump between a function call and its declaration, or to see both functions at once, help eliminate this step, but the real key to making it easy to understand small functions is good naming. If you have a good name for a function, you mostly don’t need to look at its body.

The net effect is that you should be much more aggressive about decomposing functions. A heuristic we follow is that whenever we feel the need to comment something, we write a function instead. Such a function contains the code that we wanted to comment but is named after the intention of the code rather than the way it works. We may do this on a group of lines or even on a single line of code. We do this even if the method call is longer than the code it replaces—
provided the method name explains the purpose of the code. The key here is not function length but the semantic distance between what the method does and how it does it.

Ninety-nine percent of the time, all you have to do to shorten a function is Extract Function. Find parts of the function that seem to go nicely together and make a new one.

If you have a function with lots of parameters and temporary variables, they get in the way of extracting. If you try to use Extract Function, you end up passing so many parameters to the extracted method that the result is scarcely more readable than the original. You can often use Replace Temp with Query to eliminate the temps. Long lists of parameters can be slimmed down with Introduce Parameter Object and Preserve Whole Object.

If you’ve tried that and you still have too many temps and parameters, it’s time to get out the heavy artillery: Replace Function with Command.

How do you identify the clumps of code to extract? A good technique is to look for comments. They often signal this kind of semantic distance. A block of code with a comment that tells you what it is doing can be replaced by a method whose name is based on the comment. Even a single line is worth extracting if it needs explanation.

Conditionals and loops also give signs for extractions. Use Decompose Conditional to deal with conditional expressions. A big switch statement should have its legs turned into single function calls with Extract Function. If there's more than one switch statement switching on the same condition, you should apply Replace Conditional with Polymorphism.

With loops, extract the loop and the code within the loop into its own method. If you find it hard to give an extracted loop a name, that may be because it's doing two different things—in which case don't be afraid to use Split Loop to break out the separate tasks.
