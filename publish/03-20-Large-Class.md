# Large Class（过大的类）

如果想利用单个类做太多事情，其内往往就会出现太多实例变量。一旦如此，Duplicated Code也就接踵而至了。

你可以运用*Extract Class*将几个变量一起提炼至新类内。提炼时应该选择类内彼此相关的变量，将它们放在一起。例如`depositAmount`和`depositCurrency`可能应该隶属同一个类。通常如果类内的数个变量有着相同的前缀或字尾，这就意味有机会把它们提炼到某个组件内。如果这个组件适合作为一个子类，你会发现*Extract Superclass*或者*Replace Type Code with Subclasses*（其实就是提炼子类）往往比较简单。

有时候类并非在所有时刻都使用所有实例变量。果真如此，你或许可以进行多次提炼。

和“太多实例变量”一样，类内如果有太多代码，也是代码重复、混乱并最终走向死亡的源头。最简单的解决方案（还记得吗，我们喜欢简单的解决方案）是把多余的东西消弭于类内部。如果有五个“百行函数”，它们之中很多代码都相同，那么或许你可以把它们变成五个“十行函数”和十个提炼出来的“双行函数”。

观察一个大类的使用者，经常能找到如何拆分的线索。看看使用者是否只用到了这个类所有功能的一个子集，每个这样的子集都可能拆分成单独的一个类。一旦识别出一个合适的功能子集，就试用*Extract Class*、*Extract Superclass*或是*Replace Type Code with Subclasses*将其拆分出来。