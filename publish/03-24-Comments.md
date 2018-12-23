# Comments

Don’t worry, we aren’t saying that people shouldn’t write comments. In our olfactory analogy, comments aren’t a bad smell; indeed they are a sweet smell. The reason we mention comments here is that comments are often used as a deodorant. It’s surprising how often you look at thickly commented code and notice that the comments are there because the code is bad.

Comments lead us to bad code that has all the rotten whiffs we’ve discussed in the rest of this chapter. Our first action is to remove the bad smells by refactoring. When we’re finished, we often find that the comments are superfluous.

If you need a comment to explain what a block of code does, try Extract Function. If the method is already extracted but you still need a comment to explain what it does, use Change Function Declaration to rename it. If you need to state some rules about the required state of the system, use Introduce Assertion.

When you feel the need to write a comment, first try to refactor the code so that any comment becomes superfluous.

A good time to use a comment is when you don’t know what to do. In addition to describing what is going on, comments can indicate areas in which you aren’t sure. A comment can also explain why you did something. This kind of information helps future modifiers, especially forgetful ones.
