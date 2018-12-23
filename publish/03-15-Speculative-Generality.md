# Speculative Generality

Brian Foote suggested this name for a smell to which we are very sensitive. You get it when people say, “Oh, I think we'll need the ability to do this kind of thing someday” and thus add all sorts of hooks and special cases to handle things that aren’t required. The result is often harder to understand and maintain. If all this machinery were being used, it would be worth it. But if it isn’t, it isn’t. The machinery just gets in the way, so get rid of it.

If you have abstract classes that aren’t doing much, use Collapse Hierarchy. Unnecessary delegation can be removed with Inline Function and Inline Class. Functions with unused parameters should be subject to Change Function Declaration to remove those parameters. You should also apply Change Function Declaration to remove any unneeded parameters, which often get tossed in for future variations that never come to pass.

Speculative generality can be spotted when the only users of a function or class are test cases. If you find such an animal, delete the test case and apply Remove Dead Code.

