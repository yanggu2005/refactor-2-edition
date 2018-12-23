# Primitive Obsession

Most programming environments are built on a widely used set of primitive types: integers, floating point numbers, and strings. Libraries may add some additional small objects such as dates. We find many programmers are curiously reluctant to create their own fundamental types which are useful for their domain—such as money, coordinates, or ranges. We thus see calculations that treat monetary amounts as plain numbers, or calculations of physical quantities that ignore units (adding inches to millimeters), or lots of code doing if (a < upper && a > lower).

Strings are particularly common petri dishes for this kind of odor: A telephone number is more than just a collection of characters. If nothing else, a proper type can often include consistent display logic for when it needs to be displayed in a user interface. Representing such types as strings is such a common stench that people call them “stringly typed” variables.

You can move out of the primitive cave into the centrally heated world of meaningful types by using Replace Primitive with Object. If the primitive is a type code controlling conditional behavior, use Replace Type Code with Subclasses followed by Replace Conditional with Polymorphism.

Groups of primitives that commonly appear together are data clumps and should be civilized with Extract Class and Introduce Parameter Object.
