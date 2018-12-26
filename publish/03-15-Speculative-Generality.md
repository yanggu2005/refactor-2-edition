# Speculative Generality（夸夸其谈通用性）

这个令我们十分敏感的坏味道，命名者是Brian Foote。当有人说“噢，我想我们总有一天需要做这事”，并因而企图以各式各样的钩子和特殊情况来处理一些非必要的事情，这种坏味道就出现了。那么做的结果往往造成系统更难理解和维护。如果所有装置都会被用到，那就值得那么做；如果用不到，就不值得。用不上的装置只会挡你的路，所以，把它搬开吧。

如果你的某个抽象类其实没有太大作用，请运用*Collapse Hierarchy*。不必要的委托可运用*Inline Function*和*Inline Class*除掉。如果函数的某些参数未被用上，可以用*Change Function Declaration*去掉这些参数。如果有并非真正需要、只是为不知远在何处的将来而塞进去的参数，也应该用*Change Function Declaration*去掉。

如果函数或类的唯一用户是测试用例，这就飘出了坏味道*Speculative Generality*。如果你发现这样的函数或类，可以首先删掉测试用例，然后使用*Remove Dead Code*。