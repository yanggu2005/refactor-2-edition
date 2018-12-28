# 结语

本章的实例很简单，但我希望它能让你对重构过程有一点感觉。我使用了多种重构手法，包括*Extract Function*，*Inline Variables*，*Move Function*，以及*Replace Conditional with Polymorphism*等。

本章的重构有三个较为重要的节点，分别是：将原函数分解成一组嵌套的函数、应用*Split Phrase*分离计算过程与格式化代码、以及为计算器引入多态性来处理计算逻辑。在每个节点代码的结构都会得到重塑，以便我更好地表达代码的意图。

一般来说，重构早期的主要动力是尝试理解代码如何工作。通常你得先通读代码，找到一些感觉，然后再通过重构将这些感觉从脑海中固化到代码里。代码更清晰后，理解起来也更容易，能看到更深的层面，从而形成积极正向的反馈环。这个实例当然仍有值得改进的地方，但我觉得代码相比我初见它时已经有了巨大的改善，并且测试仍能全部通过。

我谈论的是如何改善代码——但程序员多喜欢争论什么样的代码才算好代码。我偏爱小的、命名良好的函数，也知道有些人反对。如果我们说这只关乎美学，只是各花入各眼，没有好坏高低之分，那除了诉诸个人品味，就没有任何客观事实的依据了。但我坚信，这不仅关乎个人品味，而且是有客观标准的。我认为，好代码的衡量标准就是能否轻易地修改它。好代码应该直截了当：有人需要修改代码时，他们应能轻易找到修改点，并快速做出更改，且不会引入其他错误。一个健康的代码库应能最大化地提升我们的效率，支持我们更快、更高效地为用户添加新特性。如何保持代码库的健康呢，就需要时刻留意团队与理想之物的差距，然后通过重构不断接近这个理想。

> 好代码的衡量标准，就是能否轻易地修改它。

But the most important thing to learn from this example is the rhythm of refactoring. Whenever I’ve shown people how I refactor, they are surprised by how small my steps are, each step leaving the code in a working state that compiles and passes its tests. I was just as surprised myself when Kent Beck showed me how to do this in a hotel room in Detroit two decades ago. The key to effective refactoring is recognizing that you go faster when you take tiny steps, the code is never broken, and you can compose those small steps into substantial changes. Remember that—and the rest is silence.
