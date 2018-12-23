# Duplicated Code

If you see the same code structure in more than one place, you can be sure that your program will be better if you find a way to unify them. Duplication means that every time you read these copies, you need to read them carefully to see if there's any difference. If you need to change the duplicated code, you have to find and catch each duplication.

The simplest duplicated code problem is when you have the same expression in two methods of the same class. Then all you have to do is Extract Function and invoke the code from both places. If you have code that's similar, but not quite identical, see if you can use Slide Statements to arrange the code so the similar items are all together for easy extraction. If the duplicate fragments are in subclasses of a common base class, you can use Pull Up Method to avoid calling one from another.
