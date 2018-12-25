# Shotgun Surgery（霰弹式修改）

Shotgun Surgery类似Divergent Change，但恰恰相反。如果每遇到某种变化，你都必须在许多不同的类内做出许多小修改，你所面临的坏味道就是Shotgun Surgery。如果需要修改的代码散布四处，你不但很难找到它们，也很容易忘记某个重要的修改。

这种情况下你应该使用*Move Method*和*Move Field*把所有需要修改的代码放进同一个模块。如果有很多函数都在操作相似的数据，可以使用*Combine Functions into Class*。如果有些函数的功能是转化或者充实数据结构，可以使用*Combine Functions into Transform*。如果一些函数的输出可以组合后提供给一段专门使用这些计算结果的逻辑，这种时候常常用得上*Split Phase*。

面对Shotgun Surgery，一个常用的策略就是使用内联（inline）相关的重构——例如*Inline Function*或是*Inline Class*——把本不该分散的逻辑拽回一处。完成内联之后，你可能会闻到Long Method或者Large Class的味道，不过你总可以用提炼（extract）的重构手法将其拆解成更合理的小块。即便如此钟爱小型的函数和类，我们也并不担心在重构的过程中暂时创建一些较大的程序单元。
