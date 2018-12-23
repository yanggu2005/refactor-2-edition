# 第3章：代码的坏味道

by Kent Beck and Martin Fowler

If it stinks, change it.

— Grandma Beck, discussing child-rearing philosophy

By now you have a good idea of how refactoring works. But just because you know how doesn’t mean you know when. Deciding when to start refactoring—and when to stop—is just as important to refactoring as knowing how to operate the mechanics of it.

Now comes the dilemma. It is easy to explain how to delete an instance variable or create a hierarchy. These are simple matters. Trying to explain when you should do these things is not so cut-and-dried. Instead of appealing to some vague notion of programming aesthetics (which, frankly, is what we consultants usually do), I wanted something a bit more solid.

When I was writing the first edition of this book, I was mulling over this issue as I visited Kent Beck in Zurich. Perhaps he was under the influence of the odors of his newborn daughter at the time, but he had come up with the notion of describing the “when” of refactoring in terms of smells.

“Smells,” you say, “and that is supposed to be better than vague aesthetics?” Well, yes. We have looked at lots of code, written for projects that span the gamut from wildly successful to nearly dead. In doing so, we have learned to look for certain structures in the code that suggest—sometimes, scream for—the possibility of refactoring. (We are switching over to “we” in this chapter to reflect the fact that Kent and I wrote this chapter jointly. You can tell the difference because the funny jokes are mine and the others are his.)

One thing we won’t try to give you is precise criteria for when a refactoring is overdue. In our experience, no set of metrics rivals informed human intuition. What we will do is give you indications that there is trouble that can be solved by a refactoring. You will have to develop your own sense of how many instance variables or how many lines of code in a method are too many.

Use this chapter and the table on the inside back cover as a way to give you inspiration when you’re not sure what refactorings to do. Read the chapter (or skim the table) and try to identify what it is you’re smelling, then go to the refactorings we suggest to see whether they will help you. You may not find the exact smell you can detect, but hopefully it should point you in the right direction.

