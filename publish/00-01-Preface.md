# 前言

从前，有位咨询顾问造访客户调研其开发项目。系统核心是个类继承体系，顾问看了开发人员所写的一些代码。他发现整个体系相当凌乱，上层超类对于系统的运作做了一些假设，下层子类实现这些假设。但是这些假设并不适合所有子类，导致覆写（override）工作非常繁重。只要在超类做点修改，就可以减少许多覆写工作。在另一些地方，超类的某些意图并未被良好理解，因此其中某些行为在子类内重复出现。还有一些地方，好几个子类做相同的事情，其实可以把它们搬到继承体系的上层去做。

这位顾问于是建议项目经理看看这些代码，把它们整理一下，但是经理并不热衷于此，毕竟程序看上去还可以运行，而且项目面临很大的进度压力。于是经理说，晚些时候再抽时间做这些整理工作。

顾问也把他的想法告诉了在这个继承体系上工作的程序员，告诉他们可能发生的事情。程序员都很敏锐，马上就看出问题的严重性。他们知道这并不全是他们的错，有时候的确需要借助外力才能发现问题。程序员立刻用了一两天的时间整理好这个继承体系，并删掉了其中一半代码，功能毫发无损。他们对此十分满意，而且发现在继承体系中加入新的类或使用系统中的其他类都更快、更容易了。

项目经理并不高兴。进度排得很紧，有许多工作要做。系统必须在几个月之后发布，而这些程序员却白白耗费了两天时间，干的工作对未来几个月要交付的大量功能毫不相干。原先的代码运行起来还算正常。的确，新的设计更加“纯粹”、更加“整洁”。但项目要交付给客户的，是可以有效运行的代码，不是用以取悦学究的完美东西。顾问接下来又建议应该在系统的其他核心部分进行这样的整理工作，这会使整个项目停顿一至二个星期。所有这些工作只是为了让代码看起来更漂亮，并不能给系统添加任何新功能。

你对这个故事有什么感想？你认为这个顾问的建议（更进一步整理程序）是对的吗？你会遵循那句古老的工程谚语吗：“如果它还可以运行，就不要动它。”

我必须承认自己有某些偏见，因为我就是那个顾问。六个月之后这个项目宣告失败，很大的原因是代码太复杂，无法调试，也无法将性能调优到可接受的水平。

后来，项目重新启动，几乎从头开始编写整个系统，Kent Beck受邀做了顾问。他做了几件迥异以往的事，其中最重要的一件就是坚持以持续不断的重构行为来整理代码。这个团队效能的提升，以及重构在其中扮演的角色，启发了我撰写这本书的第一版，如此一来我就能够把Kent和其他一些人已经学会的“以重构方式改进软件质量”的知识，传播给所有读者。

自本书第一版问世至今，读者的反馈甚佳，重构的理念已经被广泛接纳，在编程的词汇表中扎根下来。然而，对于一本与编程相关的图书而言，十八年已经太漫长，因此我感到，是时候回头重新修缮这本书了。我几乎重写了全书的每一页，但从其内涵而言，整本书又几乎没有改变。重构的精髓仍然一如既往；大部分关键的重构手法也大体不变。我希望这次修缮能帮助更多的读者学会如何有效地进行重构。

## 什么是重构？

所谓重构（refactoring）是这样一个过程：在不改变代码外在行为的前提下，对代码做出修改，以改进程序的内部结构。重构是一种经千锤百炼形成的有条不紊的程序整理方法，可以最大限度地减少整理过程中引入错误的几率。本质上说，重构就是在代码写好之后改进它的设计。

“在代码写好之后改进它的设计”?这种说法有点奇怪。在软件开发的大部分历史时期，大部分人相信应该先设计而后编码：首先得有一个良好的设计，然后才能开始编码。但是，随着时间流逝，人们不断修改代码，于是根据原先设计所得的系统，整体结构逐渐衰弱。代码质量慢慢沉沦，编码工作从严谨的工程堕落为胡砍乱劈的随性行为。

“重构”正好与此相反。哪怕手上有一个糟糕的设计，甚至是一堆混乱的代码，我们也可以借由重构将它加工成设计良好的代码。重构的每个步骤都很简单，甚至显得有些过于简单：只需要把某个字段从一个类移到另一个类，把某些代码从一个函数拉出来构成另一个函数，或是在继承体系中把某些代码推上推下就行了。但是，聚沙成塔，这些小小的修改累积起来就可以根本改善设计质量。这和一般常见的“软件会慢慢腐烂”的观点恰恰相反。

有了重构以后，工作的平衡点开始发生变化。我发现设计不是在一开始完成的，而是在整个开发过程中逐渐浮现出来。在系统构筑过程中，我会学到如何不断改进设计。这个“构筑-设计”的反复互动，可以让一个程序在开发过程中持续保有良好的设计。

## 本书有什么？

本书是一本为专业程序员而写的重构指南。我的目的是告诉你如何以一种可控制且高效率的方式进行重构。你将学会如何有条不紊地改进程序结构，而且不会引入错误，这就是正确的重构方式。

按照传统，图书应该以概念介绍开头。尽管我也同意这个原则，但是我发现以概括性的讨论或定义来介绍重构，实在不是件容易的事。所以我决定用一个实例做为开路先锋。第1章展示了一个小程序，其中有些常见的设计缺陷，我把它重构得更容易理解和修改。其间我们可以看到重构的过程，以及几个很有用的重构手法。如果你想知道重构到底是怎么回事，这一章不可不读。

第2章讨论重构的一般性原则、定义，以及进行重构的原因，我也大致介绍了重构所存在的一些挑战。第3章由Kent Beck介绍如何嗅出代码中的“坏味道”，以及如何运用重构清除这些坏味道。测试在重构中扮演着非常重要的角色，第4章介绍如何在代码中构筑测试。

从第5章往后的篇幅就是本书的核心部分——重构列表。尽管不能说是一份巨细靡遗的列表，却足以覆盖大多数开发者可能用到的关键重构手法。这份列表的源头是1990年代后期我开始学习重构时的笔记，直到今天我仍然不时查阅这些笔记，作为对我不甚可靠的记忆力的补充。每当我想做点什么——例如Split Phase(154)——的时候，这份列表就会提醒我如何一步一步安全前进。我希望这是值得你日后一再回顾的部分。

### 一本Web优先的书

万维网对我们的社会影响深远，尤其是改变了我们获取信息的方式。在撰写本书第一版时，关于软件开发的知识大多通过出版物传播。而时至今日，我的大部分信息都来自网上。这个趋势给像我这样的写作者带来了一个挑战：今日世界还有图书的一席之地吗？今天的图书应该是什么形态？

我相信像这样一本书仍然有其价值，但也需要作出改变。图书的价值在于把大量信息以内聚的方式整合起来。在撰写本书的过程中，我尝试用连贯一致的方式来组织和涵盖大量各有特色的重构手法。

但这个聚合的整体、这个抽象的文学作品，尽管传统上只能以纸质图书的形式呈现，未来却未必非得如此。出版行业仍然将纸质图书视为首要的呈现形式，虽然我们已经满怀热情地接纳了电子图书，它们毕竟也只是在原来纸质图书结构基础上做了电子化的呈现。

我想通过这本书探索一条不同的路径。本书的权威版本是它的网站（或者叫“Web版”）。如果你购买了纸质版或者电子版，就会同时获得访问Web版的权限。（关于如何在InformIT网站上注册你的商品，请留意下文的提示。）纸质版图书是网站内容的精选，并整理成适合印刷的形式。纸质版并不尝试包含网站上的所有重构手法，尤其是考虑到未来我很有可能在Web版中增加更多重构手法。与此相似，电子版图书又是Web版的另一个呈现，其中包含的重构手法列表可能与纸质版不同，毕竟电子书在售出之后也可以相对容易地更新和添加内容。

在写下这些文字时，我无从知晓你正在阅读的是在线Web版、手机上的电子书、纸质版、还是别的什么超乎我想象的形式。我尽力写一本有用的书，不论你用什么形式来汲取其中的知识。

如果你想查看本书权威的Web版，并及时获得内容更新和纠错，请到InformIT网站注册你的《重构（第二版）》图书。你需要首先打开informit.com/register页面，登录你的InformIT账户（如果没有InformIT账户的话，需要先注册一个），然后输入本书的ISBN号“9780134757599”，点击“Submit”按钮。然后网站会向你提出一个与本书内容有关的问题，所以请确保纸质书或电子书在手边。成功注册以后，去到“Account”页面，打开“Digital Purchases”标签，点击本书标题下面的“Launch”按钮，就能看到本书的Web版。

### JavaScript代码范例

作为软件开发中技术性最强的部分，代码范例对于概念的阐释至关重要。不过即使在不同的编程语言中，重构手法看上去也是大同小异。虽然会有一些值得留心的语言特性，但重构手法的核心要素都是一样的。

我选择了用JavaScript来展现本书中的重构手法，因为我感到大多数读者都能看懂这种语言。不过即便你眼下正在使用的是别的语言，采用这些重构手法也应该不困难。我尽量不使用JavaScript任何复杂的特性，这样即便你对这门语言只有粗浅的了解，应该也能跟上重构的过程。另外，使用JavaScript展示重构手法，并不代表我推荐这门语言。

使用JavaScript展示代码范例，也不意味着本书介绍的技巧只适用于JavaScript。本书的第一版采用了Java，但很多从未写过任何Java代码的程序员也同样认为这些技巧很有用。我曾经尝试过用十多种不同的语言来呈现这些范例，以此展示重构手法的通用性，不过这对于普通读者而言只会带来困惑。对于读者所使用的编程语言，我不做任何假设。我希望读者能汲取本书的内容，并将其应用于自己日常使用的编程语言。具体而言，我希望读者能首先理解本书中的JavaScript范例代码，然后将其适配到自己习惯的语言。

因此，除了在特殊情况下，当我谈到“类”、“模块”、“函数”等词汇时，我都按照它们在程序设计领域的一般含义来使用这些词，而不是以其在JavaScript语言模型中的特殊含义来使用。

我只把JavaScript用作一种示例语言，因此我也会尽量避免使用其他程序员可能不太熟悉的编程风格。这不是一本关于“JavaScript重构”的书，而是一本关于重构的通用书籍，只是采用了JavaScript作为示例。有很多JavaScript特有的重构手法很有意思（例如将回调重构成promise或async/await），但这些不是本书要讨论的内容。

## 谁该阅读本书？

本书的目标读者是专业程序员，也就是那些以编写软件为生的人。书中的范例和讨论，涉及大量需要详细阅读和理解的代码。这些例子都用JavaScript写成，不过这些重构手法应该适用于大部分编程语言。为了理解书中的内容，读者需要有一定的编程经验，但需要的知识并不多。

本书的首要目标读者群是想要学习重构的软件开发者，同时对于已经理解重构的人也有价值——作为一本教学辅助书。在这本书里，我用了大量篇幅详细解释各个重构手法的过程和原理，因此有经验的开发者可以用这本书来指导同事。

尽管关注对象是代码，但重构对于系统设计也有巨大影响。资深设计师和架构师也很有必要了解重构原理，并在自己的项目中运用重构技术。最好是由老资格、经验丰富的开发人员来引入重构技术，因为这样的人最能够透彻理解重构背后的原理，并根据情况加以调整，使之适用于特定工作领域。如果你使用的不是JavaScript，这一点尤其重要，因为你必须把我给出的范例以其他语言改写。

下面我要告诉你，如何能够在不通读全书的情况下充分用好它。

* 如果你想知道重构是什么，请阅读第1章，其中示例会让你清楚重构的过程。
* 如果你想知道为什么应该重构，请阅读前两章。它们告诉你重构是什么以及为什么应该重构。
* 如果你想知道该在什么地方重构，请阅读第3章。它会告诉你一些代码特征，这些特征指出“这里需要重构”。
* 如果你想着手进行重构，请完整阅读前四章，然后选择性地阅读重构列表。一开始只需概略浏览列表，看看其中有些什么，不必理解所有细节。一旦真正需要实施某个准则，再详细阅读它，从中获取帮助。列表部分是供查阅的参考性内容，你不必一次就把它全部读完。

An important part of writing this book was naming the various refactorings. Terminology helps us communicate, so that when one developer advises another to extract some code into a function, or to split some computation into separate phases, both understand the references to Extract Function and Split Phase. This vocabulary also helps in selecting automated refactorings.

Building on a Foundation Laid by Others
I need to say right at the beginning that I owe a big debt with this book—a debt to those whose work in the 1990s developed the field of refactoring. It was learning from their experience that inspired and informed me to write the first edition of this book, and although many years have passed, it's important that I continue to acknowledge the foundation that they laid. Ideally, one of them should have written that first edition, but I ended up being the one with the time and energy.

Two of the leading early proponents of refactoring were Ward Cunningham and Kent Beck. They used it as a foundation of development in the early days and adapted their development processes to take advantage of it. In particular, it was my collaboration with Kent that showed me the importance of refactoring—an inspiration that led directly to this book.

Ralph Johnson leads a group at the University of Illinois at Urbana-Champaign that is notable for its practical contributions to object technology. Ralph has long been a champion of refactoring, and several of his students did vital early work in this field. Bill Opdyke developed the first detailed written work on refactoring in his doctoral thesis. John Brant and Don Roberts went beyond writing words—they created the first automated refactoring tool, the Refactoring Browser, for refactoring Smalltalk programs.

Many people have advanced the field of refactoring since the first edition of this book. In particular, the work of those who have added automated refactorings to development tools have contributed enormously to making programmers' lives easier. It's easy for me to take it for granted that I can rename a widely used function with a simple key sequence—but that ease relies on the efforts of IDE teams whose work helps us all.

Acknowledgments
Even with all that research to draw on, I still needed a lot of help to write this book. The first edition drew greatly on experience and encouragement from Kent Beck. He first introduced me to refactoring, inspired me to start writing notes to record refactorings, and helped form them into finished prose. He came up with the idea of Code Smells. I often feel he would have written the first edition better than I had done—if we wasn't writing the foundation book for Extreme Programming instead.

All the technical book authors I know mention the big debt they owe to technical reviewers. We've all written works with big flaws that were only caught by our peers acting as reviewers. I don't do a lot of technical review work myself, partly because I don't think I'm very good at it, so I have a lot of admiration for those who take it on. There's not even a pittance to be made by reviewing someone else's book, so doing it is a great act of generosity.

When I started serious work on the book, I formed a mailing list of advisors to give me feedback. As I made progress, I sent drafts of new material to this group and asked them for their feedback. I want to thank the following for posting their feedback on the mailing list: Arlo Belshee, Avdi Grimm, Beth Anders-Beck, Bill Wake, Brian Guthrie, Brian Marick, Chad Wathington, Dave Farley, David Rice, Don Roberts, Fred George, Giles Alexander, Greg Doench, Hugo Corbucci, Ivan Moore, James Shore, Jay Fields, Jessica Kerr, Joshua Kerievsky, Kevlin Henney, Luciano Ramalho, Marcos Brizeno, Michael Feathers, Patrick Kua, Pete Hodgson, Rebecca Parsons, and Trisha Gee.

Of this group, I'd particularly like to highlight the special help I got on JavaScript from Beth Anders-Beck, James Shore, and Pete Hodgson.

Once I had a pretty complete first draft, I sent it out for further review, because I wanted to have some fresh eyes look at the draft as a whole. William Chargin and Michael Hunger both delivered incredibly detailed review comments. I also got many useful comments from Bob Martin and Scott Davis. Bill Wake added to his contributions on the mailing list by doing a full review of the first draft.

My colleagues at ThoughtWorks are a constant source of ideas and feedback on my writing. There are innumerable questions, comments, and observations that have fueled the thinking and writing of this book. One of the great things about being an employee at ThoughtWorks is that they allow me to spend considerable time on writing. In particular, I appreciate the regular conversations and ideas I get from Rebecca Parsons, our CTO.

At Pearson, Greg Doench is my acquisition editor, navigating many issues in getting a book to publication. Julie Nahil is my production editor. I was glad to again work with Dmitry Kirsanov for copyediting and Alina Kirsanova for composition and indexing.