# Large Class

When a class is trying to do too much, it often shows up as too many fields. When a class has too many fields, duplicated code cannot be far behind.

You can Extract Class to bundle a number of the variables. Choose variables to go together in the component that makes sense for each. For example, “depositAmount” and “depositCurrency” are likely to belong together in a component. More generally, common prefixes or suffixes for some subset of the variables in a class suggest the opportunity for a component. If the component makes sense with inheritance, you’ll find Extract Superclass or Replace Type Code with Subclasses (which essentially is extracting a subclass) are often easier.

Sometimes a class does not use all of its fields all of the time. If so, you may be able to do these extractions many times.

As with a class with too many instance variables, a class with too much code is a prime breeding ground for duplicated code, chaos, and death. The simplest solution (have we mentioned that we like simple solutions?) is to eliminate redundancy in the class itself. If you have five hundred-line methods with lots of code in common, you may be able to turn them into five ten-line methods with another ten two-line methods extracted from the original.

The clients of such a class are often the best clue for splitting up the class. Look at whether clients use a subset of the features of the class. Each subset is a possible separate class. Once you've identified a useful subset, use Extract Class, Extract Superclass, or Replace Type Code with Subclasses to break it out.

