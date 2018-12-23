# Shotgun Surgery

Shotgun surgery is similar to divergent change but is the opposite. You whiff this when, every time you make a change, you have to make a lot of little edits to a lot of different classes. When the changes are all over the place, they are hard to find, and it’s easy to miss an important change.

In this case, you want to use Move Function and Move Field to put all the changes into a single module. If you have a bunch of functions operating on similar data, use Combine Functions into Class. If you have functions that are transforming or enriching a data structure, use Combine Functions into Transform. Split Phase is often useful here if the common functions can combine their output for a consuming phase of logic.

A useful tactic for shotgun surgery is to use inlining refactorings, such as Inline Function or Inline Class, to pull together poorly separated logic. You'll end up with a Long Method or a Large Class, but can then use extractions to break it up into more sensible pieces. Even though we are inordinately fond of small functions and classes in our code, we aren't afraid of creating something large as an intermediate step to reorganization.
