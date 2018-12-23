# Alternative Classes with Different Interfaces

One of the great benefits of using classes is the support for substitution, allowing one class to swap in for another in times of need. But this only works if their interfaces are the same. Use Change Function Declaration to make functions match up. Often, this doesn't go far enough; keep using Move Function to move behavior into classes until the protocols match. If this leads to duplication, you may be able to use Extract Superclass to atone.

