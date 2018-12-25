# Long Parameter List（过长参数列）

刚开始学习编程的时候，老师教我们：把函数所需的所有东西都以参数传递进去。这可以理解，因为除此之外就只能选择全局数据，而全局数据很快就会变成邪恶的东西。但过长的参数列本身也经常令人迷惑。

如果可以向某个参数发出请求而获得另一个参数的值，那么就可以使用*Replace Parameter with Query*去掉这第二个参数。如果你发现自己正在从现有的数据结构中抽出很多数据项，可以考虑使用*Preserve Whole Object*，直接传入原来的数据结构。如果有几项参数总是同时出现，可以用*Introduce Parameter Object*将其合并成一个对象。如果某个参数被用作区分函数行为的旗标，可以使用*Remove Flag Argument*。

使用类可以有效地缩短参数列。如果多个函数有同样的几个参数，引入一个类就尤为有意义。你可以使用*Combine Functions into Class*，将这些共同的参数变成这个类的字段。如果戴上函数式编程的帽子，我们会说，这个重构过程创造了一组部分应用函数（partially applied function）。
