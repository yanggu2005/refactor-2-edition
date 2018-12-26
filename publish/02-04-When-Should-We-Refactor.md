# When Should We Refactor?

Refactoring is something I do every hour I program. I have noticed a number of ways it fits into my workflow.

The Rule of Three
Here’s a guideline Don Roberts gave me: The first time you do something, you just do it. The second time you do something similar, you wince at the duplication, but you do the duplicate thing anyway. The third time you do something similar, you refactor.

Or for those who like baseball: Three strikes, then you refactor.

Preparatory Refactoring—Making It Easier to Add a Feature
The best time to refactor is just before I need to add a new feature to the code base. As I do this, I look at the existing code and, often, see that if it were structured a little differently, my work would be much easier. Perhaps there's function that does almost all that I need, but has some literal values that conflict with my needs. Without refactoring I might copy the function and change those values. But that leads to duplicated code—if I need to change it in the future, I'll have to change both spots (and, worse, find them). And copy-paste won't help me if I need to make a similar variation for a new feature in the future. So with my refactoring hat on, I use Parameterize Function. Once I've done that, all I have to do is call the function with the parameters I need.

It’s like I want to go 100 miles east but instead of just traipsing through the woods, I’m going to drive 20 miles north to the highway and then I’m going to go 100 miles east at three times the speed I could have if I just went straight there. When people are pushing you to just go straight there, sometimes you need to say, ‘Wait, I need to check the map and find the quickest route.’ The preparatory refactoring does that for me.

-- Jessica Kerr

The same happens when fixing a bug. Once I've found the cause of the problem, I see that it would be much easier to fix should I unify the three bits of copied code causing the error into one. Or perhaps separating some update logic from queries will make it easier to avoid the tangling that's causing the error. By refactoring to improve the situation, I also increase the chances that the bug will stay fixed, and reduce the chances that others will appear in the same crevices of the code.

Comprehension Refactoring: Making Code Easier to Understand
Before I can change some code, I need to understand what it does. This code may have been written by me or by someone else. Whenever I have to think to understand what the code is doing, I ask myself if I can refactor the code to make that understanding more immediately apparent. I may be looking at some conditional logic that's structured awkwardly. I may have wanted to use some existing functions but spent several minutes figuring out what they did because they were named badly.

At that point I have some understanding in my head, but my head isn't a very good record of such details. As Ward Cunningham puts it, by refactoring I move the understanding from my head into the code itself. I then test that understanding by running the software to see if it still works. If I move my understanding into the code, it will be preserved longer and be visible to my colleagues.

That doesn't just help me in the future—it often helps me right now. Early on, I do comprehension refactoring on little details. I rename a couple variables now that I understand what they are, or I chop a long function into smaller parts. Then, as the code gets clearer, I find I can see things about the design that I could not see before. Had I not changed the code, I probably never would have seen these things, because I’m just not clever enough to visualize all these changes in my head. Ralph Johnson describes these early refactorings as wiping the dirt off a window so you can see beyond. When I’m studying code, refactoring leads me to higher levels of understanding that I would otherwise miss. Those who dismiss comprehension refactoring as useless fiddling with the code don't realize that by foregoing it they never see the opportunities hidden behind the confusion.

Litter-Pickup Refactoring
A variation of comprehension refactoring is when I understand what the code is doing, but realize that it's doing it badly. The logic is unnecessarily convoluted, or I see functions that are nearly identical and can be replaced by a single parameterized function. There's a bit of a tradeoff here. I don't want to spend a lot of time distracted from the task I'm currently doing, but I also don't want to leave the trash lying around and getting in the way of future changes. If it's easy to change, I'll do it right away. If it's a bit more effort to fix, I might make a note of it and fix it when I'm done with my immediate task.

Sometimes, of course, it's going to take a few hours to fix, and I have more urgent things to do. Even then, however, it's usually worthwhile to make it a little bit better. As the old camping adage says, always leave the camp site cleaner than when you found it. If I make it a little better each time I pass through the code, over time it will get fixed. The nice thing about refactoring is that I don't break the code with each small step—so, sometimes, it takes months to complete the job but the code is never broken even when I'm part way through it.

Planned and Opportunistic Refactoring
The examples above—preparatory, comprehension, litter-pickup refactoring—are all opportunistic. I don't set aside time at the beginning to spend on refactoring—instead, I do refactoring as part of adding a feature or fixing a bug. It's part of my natural flow of programming. Whether I'm adding a feature or fixing a bug, refactoring helps me do the immediate task and also sets me up to make future work easier. This is an important point that's frequently missed. Refactoring isn't an activity that's separated from programming—any more than you set aside time to write if statements. I don't put time on my plans to do refactoring; most refactoring happens while I'm doing other things.

You have to refactor when you run into ugly code—but excellent code needs plenty of refactoring too.

It's also a common error to see refactoring as something people do to fix past mistakes or clean up ugly code. Certainly you have to refactor when you run into ugly code, but excellent code needs plenty of refactoring too. Whenever I write code, I'm making tradeoffs—how much do I need to parameterize, where to draw the lines between functions? The tradeoffs I made correctly for yesterday's feature set may no longer be the right ones for the new features I'm adding today. The advantage is that clean code is easier to refactor when I need to change those tradeoffs to reflect the new reality.

for each desired change, make the change easy (warning: this may be hard), then make the easy change -- Kent Beck

For a long time, people thought of writing software as a process of accretion: To add new features, we should be mostly adding new code. But good developers know that, often, the fastest way to add a new feature is to change the code to make it easy to add. Software should thus be never thought of as "done." As new capabilities are needed, the software changes to reflect that. Those changes can often be greater in the existing code than in the new code.

All this doesn't mean that planned refactoring is always wrong. If a team has neglected refactoring, it often needs dedicated time to get their code base into a better state for new features, and a week spent refactoring now can repay itself over the next couple of months. Sometimes, even with regular refactoring I'll see a problem area grow to the point when it needs some concerted effort to fix. But such planned refactoring episodes should be rare. Most refactoring effort should be the unremarkable, opportunistic kind.

One bit of advice I've heard is to separate refactoring work and new feature additions into different version-control commits. The big advantage of this is that they can be reviewed and approved independently. I'm not convinced of this, however. Too often, the refactorings are closely interwoven with adding new features, and it's not worth the time to separate them out. This can also remove the context for the refactoring, making the refactoring commits hard to justify. Each team should experiment to find what works for them; just remember that separating refactoring commits is not a self-evident principle—it's only worthwhile if it makes life easier.

Long-Term Refactoring
Most refactoring can be completed within a few minutes—hours at most. But there are some larger refactoring efforts that can take a team weeks to complete. Perhaps they need to replace an existing library with a new one. Or pull some section of code out into a component that they can share with another team. Or fix some nasty mess of dependencies that they had allowed to build up.

Even in such cases, I'm reluctant to have a team do dedicated refactoring. Often, a useful strategy is to agree to gradually work on the problem over the course of the next few weeks. Whenever anyone goes near any code that's in the refactoring zone, they move it a little way in the direction they want to improve. This takes advantage of the fact that refactoring doesn't break the code—each small change leaves everything in a still-working state. To change from one library to another, start by introducing a new abstraction that can act as an interface to either library. Once the calling code uses this abstraction, it's much easier to switch one library for another. (This tactic is called Branch By Abstraction.)

Refactoring in a Code Review
Some organizations do regular code reviews; those that don’t would do better if they did. Code reviews help spread knowledge through a development team. Reviews help more experienced developers pass knowledge to those less experienced. They help more people understand more aspects of a large software system. They are also very important in writing clear code. My code may look clear to me but not to my team. That’s inevitable—it’s hard for people to put themselves in the shoes of someone unfamiliar with whatever they are working on. Reviews also give the opportunity for more people to suggest useful ideas. I can only think of so many good ideas in a week. Having other people contribute makes my life easier, so I always look for reviews.

I’ve found that refactoring helps me review someone else’s code. Before I started using refactoring, I could read the code, understand it to some degree, and make suggestions. Now, when I come up with ideas, I consider whether they can be easily implemented then and there with refactoring. If so, I refactor. When I do it a few times, I can see more clearly what the code looks like with the suggestions in place. I don’t have to imagine what it would be like—I can see it. As a result, I can come up with a second level of ideas that I would never have realized had I not refactored.

Refactoring also helps get more concrete results from the code review. Not only are there suggestions; many suggestions are implemented there and then. You end up with much more of a sense of accomplishment from the exercise.

How I'd embed refactoring into a code review depends on the nature of the review. The common pull request model, where a reviewer looks at code without the original author, doesn't work too well. It's better to have the original author of the code present because the author can provide context on the code and fully appreciate the reviewers' intentions for their changes. I've had my best experiences with this by sitting one-on-one with the original author, going through the code and refactoring as we go. The logical conclusion of this style is pair programming: continuous code review embedded within the process of programming.

What Do I Tell My Manager?
One of the most common questions I’ve been asked is, "How to tell a manager about refactoring?" I've certainly seen places were refactoring has become a dirty word—with managers (and customers) believing that refactoring is either correcting errors made earlier, or work that doesn't yield valuable features. This is exacerbated by teams scheduling weeks of pure refactoring—especially if what they are really doing is not refactoring but less careful restructuring that causes breakages in the code base.

To a manager who is genuinely savvy about technology and understands the design stamina hypothesis, refactoring isn't hard to justify. Such managers should be encouraging refactoring on a regular basis and be looking for signs that indicate a team isn't doing enough. While it does happen that teams do too much refactoring, it's much rarer than teams not doing enough.

Of course, many managers and customer don't have the technical awareness to know how code base health impacts productivity. In these cases I give my more controversial advice: Don’t tell!

Subversive? I don’t think so. Software developers are professionals. Our job is to build effective software as rapidly as we can. My experience is that refactoring is a big aid to building software quickly. If I need to add a new function and the design does not suit the change, I find it’s quicker to refactor first and then add the function. If I need to fix a bug, I need to understand how the software works—and I find refactoring is the fastest way to do this. A schedule-driven manager wants me to do things the fastest way I can; how I do it is my responsibility. I'm being paid for my expertise in programming new capabilities fast, and the fastest way is by refactoring—therefore I refactor.

When Should I Not Refactor?
It may sound like I always recommend refactoring—but there are cases when it's not worthwhile.

If I run across code that is a mess, but I don't need to modify it, then I don't need to refactor it. Some ugly code that I can treat as an API may remain ugly. It's only when I need to understand how it works that refactoring gives me any benefit.

Another case is when it's easier to rewrite it than to refactor it. This is a tricky decision. Often, I can't tell how easy it is to refactor some code unless I spend some time trying and thus get a sense of how difficult it is. The decision to refactor or rewrite requires good judgment and experience, and I can't really boil it down into a piece of simple advice.