# Repeated Switches

Talk to a true object-oriented evangelist and they'll soon get onto the evils of switch statements. They'll argue that any switch statement you see is begging for Replace Conditional with Polymorphism. We've even heard some people argue that all conditional logic should be replaced with polymorphism, tossing most ifs into the dustbin of history.

Even in our more wild-eyed youth, we were never unconditionally opposed to the conditional. Indeed, the first edition of this book had a smell entitled "switch statements." The smell was there because in the late 90's we found polymorphism sadly underappreciated, and saw benefit in getting people to switch over.

These days there is more polymorphism about, and it isn't the simple red flag that it often was fifteen years ago. Furthermore, many languages support more sophisticated forms of switch statements that use more than some primitive code as their base. So we now focus on the repeated switch, where the same conditional switching logic (either in a switch/case statement or in a cascade of if/else statements) pops up in different places. The problem with such duplicate switches is that, whenever you add a clause, you have to find all the switches and update them. Against the dark forces of such repetition, polymorphism provides an elegant weapon for a more civilized codebase.
