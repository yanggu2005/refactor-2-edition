# Temporary Field

Sometimes you see a class in which a field is set only in certain circumstances. Such code is difficult to understand, because you expect an object to need all of its fields. Trying to understand why a field is there when it doesn’t seem to be used can drive you nuts.

Use Extract Class to create a home for the poor orphan variables. Use Move Function to put all the code that concerns the fields into this new class. You may also be able to eliminate conditional code by using Introduce Special Case to create an alternative class for when the variables aren’t valid.

