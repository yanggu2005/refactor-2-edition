# 对此起始程序的评价

你对这个程序的设计有何想法？我的第一感觉是，这还在可忍受的限度内——这样小的程序，不需任何深入的设计，也不会太难理解。但我前面讲过，这是因为要保证实例足够小的缘故。如果这段代码身处于一个更大规模——也许是几百行——的程序中时，把所有代码放到一个函数里就很难理解了。

尽管如此，这个程序还是能正常工作。那么是不是说，对它的设计评价只是美学意义上的判断，只是对所谓丑陋代码的反感呢？毕竟编译器也不会在乎代码好不好看。但是当我们需要修改系统时，就涉及到了人，而人在乎这些。差劲的系统是很难修改的，因为很难找到修改点，难以了解修改点与现有代码如何协作。这样就很有可能会犯错，从而引入bug。

因此，如果我需要修改一个有几百行代码的函数，我会期望它有良好的结构，并且已经被分解成一系列函数和语言要素，这能帮我清楚了解这段代码在做什么。如果程序杂乱无章，先为它整理出结构来再做需要的修改，通常来说更加简单。

> 如果你要给程序添加一个特性，但发现代码因缺乏良好的结构而不易进行更改，那就先重构那个程序，使特性的添加比较容易进行，然后再添加特性。

在这个例子里，我们的用户希望对系统做几个修改。首先他们希望以HTML格式输出详单。现在请你想一想，这个变化会带来什么影响。我得为所有在result变量后追加字符串的地方添加分支逻辑。这会为函数引入更多复杂度。遇到这种需求时，很多人会直接复制整个方法，在其中修改输出HTML的部分。复制一遍代码似乎不算太难，但会为以后带来更多麻烦。一旦计费逻辑发生变化，我就得同时修改两处地方，以保证它们逻辑相同。如果你编写的是一个永不需要修改的程序，这种复制粘贴就还好。但如果程序会长时间存在，那么重复就会造成潜在的威胁。

现在，第二个变化来了：演员们尝试在表演类型上做更多突破，无论是历史剧、田园剧、田园喜剧、田园史剧、历史悲剧、还是历史田园悲喜剧，无论一成不变的正统戏，还是千变万幻的新派戏，他们都希望尝试，只是还没有决定试哪种、何时试演。这对戏剧场次的计费方式、积分的计算方式都有影响。作为一个经验丰富的开发者，你可以肯定：不论最终提出什么方案，他们一定会在六个月之内再次修改它。毕竟，需求通常不来则已，来便接踵而至。

为了应对分类规则和计费规则的变化，程序必须对`statement()`方法做出修改。但如果只是简单地将`statement`函数复制一份并重命名为`HTMLStatement`，未来的所有修改就必须在两处地方保证一致性。随着各种规则变得越来越复杂，适当的修改点将越来越难找，犯错的机会也会越来越大。

我再强调一次，是需求的变化使重构变得必要。如果一段代码能正常工作，并且不会再被修改，那么完全可以不去重构它。能改进它当然很好，但若没人需要去理解它，它就不会真正妨碍什么。如果确实有人需要理解它的工作原理，并且觉得理解起来很费劲，那你就需要做些什么来改进它了。
