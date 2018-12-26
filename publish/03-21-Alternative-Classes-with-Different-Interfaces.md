# Alternative Classes with Different Interfaces（异曲同工的类）

使用类的好处之一就在于可以替换：今天用这个类，未来可以换成用另一个类。但只有当两个类的接口一致时，才能做这种替换。可以用*Change Function Declaration*将函数签名变得一致。但这往往不够，请反复运用*Move Function*将某些行为移入类，直到两者的协议一致为止。如果搬移过程造成了重复代码，或许可运用*Extract Superclass*为自己赎点罪。