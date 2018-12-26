# Defining Refactoring

Like many terms in software development, "refactoring" is often used very loosely by practitioners. I use the term more precisely, and find it useful to use it in that more precise form. (These definitions are the same as those I gave in the first edition of this book.) The term "refactoring" can be used either as a noun or a verb. The noun's definition is:

Refactoring (noun): a change made to the internal structure of software to make it easier to understand and cheaper to modify without changing its observable behavior.

This definition corresponds to the named refactorings I've mentioned in the earlier examples, such as Extract Function and Replace Conditional with Polymorphism.

The verb's definition is:

Refactoring (verb): to restructure software by applying a series of refactorings without changing its observable behavior.

So I might spend a couple of hours refactoring, during which I would apply a few dozen individual refactorings.

Over the years, many people in the industry have taken to use "refactoring" to mean any kind of code cleanup—but the definitions above point to a particular approach to cleaning up code. Refactoring is all about applying small behavior-preserving steps and making a big change by stringing together a sequence of these behavior-preserving steps. Each individual refactoring is either pretty small itself or a combination of small steps. As a result, when I'm refactoring, my code doesn't spend much time in a broken state, allowing me to stop at any moment even if I haven't finished.

If someone says their code was broken for a couple of days while they are refactoring, you can be pretty sure they were not refactoring.

I use "restructuring" as a general term to mean any kind of reorganizing or cleaning up of a code base, and see refactoring as a particular kind of restructuring. Refactoring may seem inefficient to people who first come across it and watch me making lots of tiny steps, when a single bigger step would do. But the tiny steps allow me to go faster because they compose so well—and, crucially, because I don't spend any time debugging.

In my definitions, I use the phrase "observable behavior." This is a deliberately loose term, indicating that the code should, overall, do just the same things it did before I started. It doesn't mean it will work exactly the same—for example, Extract Function will alter the call stack, so performance characteristics might change—but nothing should change that the user should care about. In particular, interfaces to modules often change due to such refactorings as Change Function Declaration and Move Function. Any bugs that I notice during refactoring should still be present after refactoring (though I can fix latent bugs that nobody has observed yet).

Refactoring is very similar to performance optimization, as both involve carrying out code manipulations that don't change the overall functionality of the program. The difference is the purpose: Refactoring is always done to make the code "easier to understand and cheaper to modify." This might speed things up or slow things down. With performance optimization, I only care about speeding up the program, and am prepared to end up with code that is harder to work with if I really need that improved performance.

