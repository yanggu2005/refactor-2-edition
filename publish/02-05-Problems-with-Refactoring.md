# 重构的挑战

每当有人大力推荐一种技术、工具或是架构，我总是会观察这东西会遇到哪些挑战，毕竟生活中很少有晴空万里无云的好事。你需要了解一件事背后的权衡取舍，才能决定何时何地应用它。我认为重构是一种很有价值的技术，大多数团队都应该更多地重构，但它也不是完全没有挑战的。有必要充分了解重构会遇到的挑战，这样才能做出有效应对。

## 延缓新功能开发

如果你读了前面一小节，我对这个挑战的回应便已经很清楚了。尽管很多人认为花在重构的时间是在拖慢新功能开发，但重构的目的就是加速开发。不过尽管如此，“重构会拖慢进度”这种看法仍然很普遍，这可能是导致人们没有充分重构最大的阻力所在。

> 重构的整个目的就在于让我们开发更快、用更少的工作量创造更大的价值。

有一种情况确实需要权衡取舍。我有时会看到一个（大规模的）重构很有必要进行，而马上要添加的功能非常小，这时我会更愿意先把新功能加上，然后再做这次大规模重构。做这个决定需要判断力——这是我作为程序员的专业能力之一。我很难描述决定的过程，更无法量化决定的依据。

我清楚地知道，预备性重构常会使修改更容易，所以如果做一点重构能让新功能实现更容易，我一定会做。如果一个问题我已经见过，此时我也会更倾向于重构它——有时我就得先看见一块丑陋的代码几次，然后才能提起劲头来重构它。另一方面，如果一块代码我很少触碰，它不会经常给我带来麻烦，那么我就倾向于不去重构它。有时我还没想清楚究竟应该如何优化代码，那么我也会延迟重构；不过另一些时候，即便没想清楚优化的方向，我也会先做些实验，试试看能否有所改进。

我从同事那里听到的证据表明，在我们这个行业里重构不足的情况，远多于重构过度的情况。换句话说，绝大多数人应该尝试多做重构。代码库的健康与否，到底会对生产率造成多大的影响，很多人可能说不出来，因为他们没有太多在健康的代码库上工作的经历——轻松地把现有代码组合配置，快速构造出复杂的新功能，这种强大的开发方式他们没有体验过。

虽然我们经常批评经理们以“保障开发速度”的名义压制重构，其实程序员们自己也经常这么干。有时他们自己觉得不应该重构，其实他们的领导还挺希望他们做一些重构的。如果你是一支团队的技术领导，一定要向团队成员表明，你重视改善代码库健康的价值。合理判断何时应该重构、何时应该暂时不重构，这样的判断力需要多年经验积累。对于重构缺乏经验的年轻人需要有意的指导，才能帮助他们加速经验积累的过程。

有些人试图用“整洁的代码”、“良好的工程实践”之类道德理由来论证重构的必要性，我认为这是个陷阱。重构的意义不在于把代码库打磨得闪闪发光，而是纯粹经济角度出发的考量。我们之所以重构，因为它能让让我们更快——添加功能更快，修复bug更快。一定要随时记住这一点，与别人交流时也要不断强调这一点。重构应该总是由经济利益驱动。程序员、经理和客户越理解这一点，“好的设计”那条曲线就会越经常出现。

## 代码所有权

很多重构手法不仅会影响一个模块内部，还会影响该模块与系统其他部分的关系。比如我想给一个函数改名，并且我也能找到该函数的所有调用者，那么我只需运用*Change Function Declaration*，在一次重构中修改函数声明和调用者。但即便这么简单的一个重构，有时也无法实施：调用方代码可能由另一支团队拥有，而我没有权限写入他们的代码库；这个函数可能是一个提供给客户的API，这时我根本无法知道是否有人使用它，至于谁在用、用得有多频繁就更是一无所知。这样的函数属于已发布接口（published interface）：接口的使用者与声明者彼此独立，声明者无权修改使用者的代码。

代码所有权的边界会妨碍重构，因为一旦我自作主张地修改，就一定会破坏使用者的程序。这不会完全阻止重构，我仍然可以做很多重构，但确实会对重构造成约束。为了给一个函数改名，我需要使用*Rename Function*，但同时也得保留原来的函数声明，使其把调用传递给新的函数。这会让接口变复杂，但这就是为了避免破坏使用者的系统而不得不付出的代价。我可以把旧的接口标记为`deprecated`（不推荐使用），等一段时间之后最终让其退休；但有些时候，旧的接口必须一直保留下去。

由于这些复杂性，我建议不要搞细粒度的强代码所有制。有些组织喜欢给每段代码都指定唯一的所有者，只有这个人能修改这段代码。我曾经见过一支只有三个人的团队以这种方式运作，每个程序员都要给另外两人发布接口，随之而来的就是接口维护的种种麻烦。如果这三个人都直接去代码库里做修改，事情会简单得多。我推荐团队代码所有制，这样一支团队里的成员都可以修改这个团队拥有的代码，即便最初写代码的是别人。程序员可能各自分工负责系统的不同区域，但这种责任应该体现为监控自己责任区内发生的修改，而不是简单粗暴地禁止别人修改。

这种较为宽容的代码所有制甚至可以应用于跨团队的场合。有些团队鼓励类似于开源的模型：B团队的成员也可以在一个分支上修改A团队的代码，然后把提交发送给A团队去审核。这样一来，如果团队想修改自己的函数，他们就可以同时修改使用端的代码；只要使用方接受了他们的修改，就可以删掉旧的函数声明了。对于涉及多个团队的大系统开发，在“强代码所有制”和“混乱修改”两个极端之间，这种类似开源的模式常常是一个合适的折衷。

Branches
As I write this, a common approach in teams is for each team member to work on a branch of the code base using a version control system, and do considerable work on that branch before integrating with a mainline (often called master or trunk) shared across the team. Often, this involves building a whole feature on a branch, not integrating into the mainline until the feature is ready to be released into production. Fans of this approach claim that it keeps the mainline clear of any in-process code, provides a clear version history of feature additions, and allows features to be reverted easily should they cause problems.

There are downsides to feature branches like this. The longer I work on an isolated branch, the harder the job of integrating my work with mainline is going to be when I'm done. Most people reduce this pain by frequently merging or rebasing from mainline to my branch. But this doesn't really solve the problem when several people are working on individual feature branches. I distinguish between merging and integration. If I merge mainline into my code, this is a one-way movement—my branch changes but the mainline doesn't. I use "integrate" to mean a two-way process that pulls changes from mainline into my branch and then pushes the result back into mainline, changing both. If Rachel is working on her branch I don't see her changes until she integrates with mainline; at that point, I have to merge her changes into my feature branch, which may mean considerable work. The hard part of this work is dealing with semantic changes. Modern version control systems can do wonders with merging complex changes to the program text, but they are blind to the semantics of the code. If I've changed the name of a function, my version control tool may easily integrate my changes with Rachel's. But if, in her branch, she added a call to a function that I've renamed in mine, the code will fail.

The problem of complicated merges gets exponentially worse as the length of feature branches increases. Integrating branches that are four weeks old is more than twice as hard as those that are a couple of weeks old. Many people, therefore, argue for keeping feature branches short—perhaps just a couple of days. Others, such as me, want them even shorter than that. This is an approach called Continuous Integration (CI), also known as Trunk-Based Development. With CI, each team member integrates with mainline at least once per day. This prevents any branches diverting too far from each other and thus greatly reduces the complexity of merges. CI doesn't come for free: It means you use practices to ensure the mainline is healthy, learn to break large features into smaller chunks, and use feature toggles (aka feature flags) to switch off any in-process features that can't be broken down.

Fans of CI like it partly because it reduces the complexity of merges, but the dominant reason to favor CI is that it's far more compatible with refactoring. Refactorings often involve making lots of little changes all over the code base—which are particularly prone to semantic merge conflicts (such as renaming a widely used function). Many of us have seen feature-branching teams that find refactorings so exacerbate merge problems that they stop refactoring. CI and refactoring work well together, which is why Kent Beck combined them in Extreme Programming.

I'm not saying that you should never use feature branches. If they are sufficiently short, their problems are much reduced. (Indeed, users of CI usually also use branches, but integrate them with mainline each day.) Feature branches may be the right technique for open source projects where you have infrequent commits from programmers who you don't know well (and thus don't trust). But in a full-time development team, the cost that feature branches impose on refactoring is excessive. Even if you don't go to full CI, I certainly urge you to integrate as frequently as possible. You should also consider the objective evidence that teams that use CI are more effective in software delivery.

Testing
One of the key characteristics of refactoring is that it doesn't change the observable behavior of the program. If I follow the refactorings carefully, I shouldn't break anything—but what if I make a mistake? (Or, knowing me, s/if/when.) Mistakes happen, but they aren't a problem provided I catch them quickly. Since each refactoring is a small change, if I break anything, I only have a small change to look at to find the fault—and if I still can't spot it, I can revert my version control to the last working version.

The key here is being able to catch an error quickly. To do this, realistically, I need to be able to run a comprehensive test suite on the code—and run it quickly, so that I'm not deterred from running it frequently. This means that in most cases, if I want to refactor, I need to have self-testing code.

To some readers, self-testing code sounds like a requirement so steep as to be unrealizable. But over the last couple of decades, I've seen many teams build software this way. It takes attention and dedication to testing, but the benefits make it really worthwhile. Self-testing code not only enables refactoring—it also makes it much safer to add new features, since I can quickly find and kill any bugs I introduce. The key point here is that when a test fails, I can look at the change I've made between when the tests were last running correctly and the current code. With frequent test runs, that will be only a few lines of code. By knowing it was those few lines that caused the failure, I can much more easily find the bug.

This also answers those who are concerned that refactoring carries too much risk of introducing bugs. Without self-testing code, that's a reasonable worry—which is why I put so much emphasis on having solid tests.

There is another way to deal with the testing problem. If I use an environment that has good automated refactorings, I can trust those refactorings even without running tests. I can then refactor, providing I only use those refactorings that are safely automated. This removes a lot of nice refactorings from my menu, but still leaves me enough to deliver some useful benefits. I'd still rather have self-testing code, but it's an option that is useful to have in the toolkit.

This also inspires a style of refactoring that only uses a limited set of refactorings that can be proven safe. Such refactorings require carefully following the steps, and are language-specific. But teams using them have found they can do useful refactoring on large code bases with poor test coverage. I don't focus on that in this book, as it's a newer, less described and understood technique that involves detailed, language-specific activity. (It is, however, something I hope talk about more on my web site in the future. For a taste of it, see Jay Bazuzi's description of a safer way to do Extract Method in C++.)

Self-testing code is, unsurprisingly, closely associated with Continuous Integration—it is the mechanism that we use to catch semantic integration conflicts. Such testing practices are another component of Extreme Programming and a key part of Continuous Delivery.

Legacy Code
Most people would regard a big legacy as a Good Thing—but that's one of the cases where programmers' view is different. Legacy code is often complex, frequently comes with poor tests, and, above all, is written by Someone Else (shudder).

Refactoring can be a fantastic tool to help understand a legacy system. Functions with misleading names can be renamed so they make sense, awkward programming constructs smoothed out, and the program turned from a rough rock to a polished gem. But the dragon guarding this happy tale is the common lack of tests. If you have a big legacy system with no tests, you can't safely refactor it into clarity.

The obvious answer to this problem is that you add tests. But while this sounds a simple, if laborious, procedure, it's often much more tricky in practice. Usually, a system is only easy to put under test if it was designed with testing in mind—in which case it would have the tests and I wouldn't be worrying about it.

There's no simple route to dealing with this. The best advice I can give is to get a copy of Working Effectively with Legacy Code and follow its guidance. Don't be worried by the age of the book—its advice is just as true more than a decade later. To summarize crudely, it advises you to get the system under test by finding seams in the program where you can insert tests. Creating these seams involves refactoring—which is much more dangerous since it's done without tests, but is a necessary risk to make progress. This is a situation where safe, automated refactorings can be a godsend. If all this sounds difficult, that's because it is. Sadly, there's no shortcut to getting out of a hole this deep—which is why I'm such a strong proponent of writing self-testing code from the start.

Even when I do have tests, I don't advocate trying to refactor a complicated legacy mess into beautiful code all at once. What I prefer to do is tackle it in relevant pieces. Each time I pass through a section of the code, I try to make it a little bit better—again, like leaving a camp site cleaner than when I found it. If this is a large system, I'll do more refactoring in areas I visit frequently—which is the right thing to do because, if I need to visit code frequently, I'll get a bigger payoff by making it easier to understand.

Databases
When I wrote the first edition of this book, I said that refactoring databases was a problem area. But, within a year of the book's publication, that was no longer the case. My colleague Pramod Sadalage developed an approach to evolutionary database design and database refactoring that is now widely used. The essence of the technique is to combine the structural changes to a database's schema and access code with data migration scripts that can easily compose to handle large changes.

Consider a simple example of renaming a field (column). As in Change Function Declaration, I need to find the original declaration of the structure and all the callers of this structure and change them in a single change. The complication, however, is that I also have to transform any data that uses the old field to use the new one. I write a small hunk of code that carries out this transform and store it in version control, together with the code that changes any declared structure and access routines. Then, whenever I need to migrate between two versions of the database, I run all the migration scripts that exist between my current copy of the database and my desired version.

As with regular refactoring, the key here is that each individual change is small yet captures a complete change, so the system still runs after applying the migration. Keeping them small means they are easy to write, but I can string many of them into a sequence that can make a significant change to the database's structure and the data stored in it.

One difference from regular refactorings is that database changes often are best separated over multiple releases to production. This makes it easy to reverse any change that causes a problem in production. So, when renaming a field, my first commit would add the new database field but not use it. I may then set up the updates so they update both old and new fields at once. I can then gradually move the readers over to the new field. Only once they have all moved to the new field, and I've given a little time for any bugs to show themselves, would I remove the now-unused old field. This approach to database changes is an example of a general approach of parallel change (also called expand-contract).