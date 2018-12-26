# 分解`statement`方法

每当看到这样长长的函数，我下意识想从整个函数行为中分辨出不同的分离点。第一个引起我注意的就是中间那个switch语句。

```javascript
function statement(invoice, plays) {
  let totalAmount = 0;
  let volumeCredits = 0;
  let result = `Statement for ${invoice.customer}\n`;
  const format = new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: "USD",
    minimumFractionDigits: 2
  }).format;

  for (let perf of invoice.performances) {
    const play = plays[perf.playID];
    let thisAmount = 0;

    switch (play.type) {
    case "tragedy":
      thisAmount = 40000;
      if (perf.audience > 30) {
        thisAmount += 1000 * (perf.audience - 30);
      }
      break;
    case "comedy":
      thisAmount = 30000;
      if (perf.audience > 20) {
        thisAmount += 10000 + 500 * (perf.audience - 20);
      }
      thisAmount += 300 * perf.audience;
      break;
     default:
       throw new Error(`unknown type: ${play.type}`);
    }
    
    // add volume credits
    volumeCredits += Math.max(perf.audience - 30, 0);
    // add extra credit for every ten comedy attendees
    if ("comedy" === play.type) volumeCredits += Math.floor(perf.audience / 5);

    // print line for this order
    result += ` ${play.name}: ${format(thisAmount / 100)} (${
      perf.audience
    } seats)\n`;
    totalAmount += thisAmount;
  }
  result += `Amount owed is ${format(totalAmount / 100)}\n`;
  result += `You earned ${volumeCredits} credits\n`;
  return result;
}
```

看着这块代码，我就知道它是一场演出费用的计算逻辑。这是看到这块代码的直觉。不过正如Ward Cunningham所说，这种理解只存在于我的脑海里，是种转瞬即逝的灵光。我需要将它从脑子模糊的印象里表达到代码上。这样当我回头看时，代码就能告诉我它在干什么——不需要让我重新思考一遍。

要我的理解转化到代码里，我们需要将这块代码自身抽取成一个函数，按它所干的事情给它命名——比如`amountFor(performance)`。每次我想将一块代码抽取成一个函数时，有个标准流程可以最大程度减少我犯错的机会。我把这个流程记录了下来，将其命名为*Extract Method*，以便我可以方便地引用它。

首先检查一下，如果我将这块代码提炼到自己的一个函数里，有哪些变量将不在作用域里。在此实例中，是这三个变量：`perf`、`play`和`thisAmount`。前两个会被提炼后的函数使用，但不会被修改，那么我就可以将它们以参数方式传递进来。你需要更多关注会被修改的变量。这里只有唯一一个，因此我可以直接将它返回。我还可以将其初始化放到提炼后的函数里。这些更改会得到这样的代码：

_`statement`函数…_

```javascript
function amountFor(perf, play) {
  let thisAmount = 0;
  switch (play.type) {
  case "tragedy":
    thisAmount = 40000;
    if (perf.audience > 30) {
      thisAmount += 1000 * (perf.audience - 30);
    }
    break;
  case "comedy":
    thisAmount = 30000;
    if (perf.audience > 20) {
      thisAmount += 10000 + 500 * (perf.audience - 20);
    }
    thisAmount += 300 * perf.audience;
    break;
  default:
    throw new Error(`unknown type: ${play.type}`);
  }
  return thisAmount;
}
```

当我在代码块上使用斜体标记 _"function someName"_ 这样的题头时，说明被标记的代码块在题头所在函数、文件或类的作用域内。通常该作用域内还有其他的代码，但我尚未讨论到它们，因此将它们隐去不显示。

原来的`statement`函数现在可以直接调用这个新的函数来初始化`thisAmount`：

*顶层作用域…*

```javascript
function statement (invoice, plays) {
  let totalAmount = 0;
  let volumeCredits = 0;
  let result = `Statement for ${invoice.customer}\n`;
  const format = new Intl.NumberFormat("en-US", { 
    style: "currency", 
    currency: "USD",
    minimumFractionDigits: 2
  }).format;
  
  for (let perf of invoice.performances) {
    const play = plays[perf.playID];
    /* ------------- highlight code below with pink ----
    let thisAmount = amountFor(perf, play);
    */
 
    // add volume credits
    volumeCredits += Math.max(perf.audience - 30, 0);
    // add extra credit for every ten comedy attendees
    if ("comedy" === play.type) volumeCredits += Math.floor(perf.audience / 5);
 
    // print line for this order
    result += ` ${play.name}: ${format(thisAmount/100)} (${perf.audience} seats)\n`;
    totalAmount += thisAmount;
  }
  result += `Amount owed is ${format(totalAmount/100)}\n`;
  result += `You earned ${volumeCredits} credits\n`;
  return result;
}
```

做完这个改动后，我会马上编译并执行一遍测试，看有否破坏其他东西。无论每次重构多么简单，养成重构后即运行测试的习惯非常重要。犯错误是很容易的——至少我发现是这样。每次小的更改后即运行测试，这样当我真的犯了错时，只需要在一块很小的改动范围里找出错误，这使得查错与修复易如反掌。这是重构过程的精髓所在：小步修改，而后运行测试。如果我修改了太多东西，犯了错时就会逼我陷入调试困境，这说来就话长了。小步修改，及随之而来紧凑的反馈环，正是防止混乱的关键。

这里我使用的*编译*一词，指的是将JavaScript变成可执行代码之前的所有步骤。虽然JavaScript可以直接执行，有时可能不需任何步骤，但有时可能需要将代码移动到一个输出目录、使用诸如Babel[Babel]这样的预处理器等。

因为是JavaScript，我可以直接将`amountFor`提炼成为`statement`的一个内部函数。这很有用，因为我不需要将外部函数作用域中的变量传给新的函数。这个场景下可能区别不大，但至少也少了一件要操心的事。

> 重构是指小步地修改程序，这样当你出错时，找出bug更加简单。

做完上面的修改，测试是通过的，因此下一步我要把代码提交到本地的版本管理系统。我会使用诸如git或mercurial这样的版本管理系统，它们允许我进行本地提交。每次成功的重构后我都会提交代码，如果接下来搞坏了，那我可以轻易回到一个可工作的状态。在把代码提交到远端仓库之前，我会把零碎的修改压缩成一个更有意义的提交。

*Extract Function* 是一种常见的可自动完成的重构。如果我是用Java编程，我会本能地使用IDE的快捷键来完成这项重构。在我写这篇文章时，JavaScript工具对此重构的支持仍不是很健壮，因此我必须手动重构它。这不是很难，当然我还是需要小心处理那些局部作用域变量。

完成*Extract Function*手法后，我会看看提炼出来的函数，能否快速简单地使它意义更加清晰。一般我做的第一件事就是重命名一些变量，使它们更简洁，比如将`thisAmount`重命名为`result`：

*function statement...*

```javascript
function amountFor(perf, play) {
  let result = 0;
  switch (play.type) {
  case "tragedy": 
    result = 40000;
    if (perf.audience > 30) {
      result += 1000 * (perf.audience - 30);
    }
    break;
  case "comedy": 
    result = 30000;
    if (perf.audience > 20) {
      result += 10000 + 500 * (perf.audience - 20);
    }
    result += 300 * perf.audience;
    break;
  default: 
      throw new Error(`unknown type: ${play.type}`)
  }
  return result;
}
```

我自己的编码规范是，永远将函数的返回值命名为「result」。这样我一眼就知道它的角色。然后我再次编译、测试、提交代码。然后我前往下一个：函数参数。

*function statement...*

```javascript
function amountFor(aPerformance, play) {
  let result = 0;
  switch (play.type) {
  case "tragedy": 
    result = 40000;
    if (aPerformance.audience > 30) {
      result += 1000 * (aPerformance.audience - 30);
    }
    break;
  case "comedy": 
    result = 30000;
    if (aPerformance.audience > 20) {
      result += 10000 + 500 * (aPerformance.audience - 20);
    }
    result += 300 * aPerformance.audience;
    break;
  default: 
      throw new Error(`unknown type: ${play.type}`)
  }
  return result;
}
```

这同样也是我个人的编码风格。使用一门动态类型语言（诸如JavaScript）时，跟踪其类型很有意义。因此，我为参数取名时都默认带上其类型名。一般我会使用不定冠词修饰它，除非命名中还含有其他角色相关的信息。这个风格是从Kent Beck那里学的[Beck SBPP]，现在还一直觉得很有用。

> 写出计算机能够理解的代码，凡人也能做到；优秀的程序员写出的代码，人类也能理解。

这次重命名是否值得呢？当然值得。好代码应能清楚地告诉读者它在做什么，而变量命名是代码清晰的关键。永远不要害怕重命名变量以提升代码可读性。有好的查找替换工具在手，重命名通常并不困难；测试、语言的静态类型支持等，都可以帮你揪出漏改的地方。而且有了自动化的重构工具，即便使用广泛的函数也能轻松地进行重命名。

下一个要寻求重命名的是`play`变量，但我对这个参数另有安排。

## 移除`play`变量

观察`amountFor`函数时，我会查看它的参数都从哪里来。`aPerformance`是从循环变量中来，所以自然每次循环都会改变。但`play`变量是由performance变量计算得到的，因此根本没必要将它作为参数传入——我可以在`amountFor`函数中重新计算得到。当我分解一个长函数时，我喜欢将`play`这样的变量移除掉，因为临时变量创建了很多局部作用域的命名，会使提炼函数更加复杂。这里我要使用的重构手法是*Replace Temp with Query*。

我先将赋值表达式的右边部分提炼出一个函数来。

*function statement...*

```javascript
function playFor(aPerformance) {
  return plays[aPerformance.playID];
}
```

*顶层作用域…*

```javascript
function statement (invoice, plays) {
  let totalAmount = 0;
  let volumeCredits = 0;
  let result = `Statement for ${invoice.customer}\n`;
  const format = new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: "USD",
    minimumFractionDigits: 2
  }).format;

  for (let perf of invoice.performances) {
    const play = playFor(perf);
    let thisAmount = amountFor(perf, play);

    // add volume credits
    volumeCredits += Math.max(perf.audience - 30, 0);
    // add extra credit for every ten comedy attendees
    if ("comedy" === play.type) volumeCredits += Math.floor(perf.audience / 5);

    // print line for this order
    result += ` ${play.name}: ${format(thisAmount / 100)} (${
      perf.audience
    } seats)\n`;
    totalAmount += thisAmount;
  }
  result += `Amount owed is ${format(totalAmount / 100)}\n`;
  result += `You earned ${volumeCredits} credits\n`;
  return result;
}
```

编译-测试-提交，然后再使用*Inline Variables*手法。

*顶层作用域…*

```javascript
function statement(invoice, plays) {
  let totalAmount = 0;
  let volumeCredits = 0;
  let result = `Statement for ${invoice.customer}\n`;
  const format = new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: "USD",
    minimumFractionDigits: 2
  }).format;

  for (let perf of invoice.performances) {
    const play = playFor(perf);
    let thisAmount = amountFor(perf, playFor(perf));

    // add volume credits
    volumeCredits += Math.max(perf.audience - 30, 0);
    // add extra credit for every ten comedy attendees
    if ("comedy" === playFor(perf).type) volumeCredits += Math.floor(perf.audience / 5);

    // print line for this order
    result += ` ${playFor(perf).name}: ${format(thisAmount / 100)} (${
      perf.audience
    } seats)\n`;
    totalAmount += thisAmount;
  }
  result += `Amount owed is ${format(totalAmount / 100)}\n`;
  result += `You earned ${volumeCredits} credits\n`;
  return result;
}
```

编译-测试-提交。内联变量后，我就可以对`amountFor`函数应用*Change Function Declaration*手法，然后移除`play`参数了。我会分两步走。第一步，我先在`amountFor`函数内部使用新抽取的函数：

*function statement...*

```javascript
function amountFor(perf, play) {
  let result = 0;
  switch (playFor(aPerformance).type) {
  case "tragedy": 
    result = 40000;
    if (perf.audience > 30) {
      result += 1000 * (perf.audience - 30);
    }
    break;
  case "comedy": 
    result = 30000;
    if (perf.audience > 20) {
      result += 10000 + 500 * (perf.audience - 20);
    }
    result += 300 * perf.audience;
    break;
  default: 
      throw new Error(`unknown type: ${playFor(aPerformance).type}`)
  }
  return result;
}
```

编译-测试-提交，然后将参数删除。

*顶层作用域…*

```javascript
function statement(invoice, plays) {
  let totalAmount = 0;
  let volumeCredits = 0;
  let result = `Statement for ${invoice.customer}\n`;
  const format = new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: "USD",
    minimumFractionDigits: 2
  }).format;

  for (let perf of invoice.performances) {
    let thisAmount = amountFor(perf);

    // add volume credits
    volumeCredits += Math.max(perf.audience - 30, 0);
    // add extra credit for every ten comedy attendees
    if ("comedy" === playFor(perf).type) volumeCredits += Math.floor(perf.audience / 5);

    // print line for this order
    result += ` ${playFor(perf).name}: ${format(thisAmount / 100)} (${
      perf.audience
    } seats)\n`;
    totalAmount += thisAmount;
  }
  result += `Amount owed is ${format(totalAmount / 100)}\n`;
  result += `You earned ${volumeCredits} credits\n`;
  return result;
}
```

*function statement...*

```javascript
function amountFor(perf) {
  let result = 0;
  switch (playFor(aPerformance).type) {
  case "tragedy": 
    result = 40000;
    if (perf.audience > 30) {
      result += 1000 * (perf.audience - 30);
    }
    break;
  case "comedy": 
    result = 30000;
    if (perf.audience > 20) {
      result += 10000 + 500 * (perf.audience - 20);
    }
    result += 300 * perf.audience;
    break;
  default: 
      throw new Error(`unknown type: ${playFor(aPerformance).type}`)
  }
  return result;
}
```

然后再一次进行编译-测试-提交。

这次重构可能使一些程序员感到担忧。最初的代码，play变量的查找代码在每次循环中只执行了一次，而重构后却执行了三次。后续我会讨论重构与性能之间的关系，但现在我认为这个改动还不太可能严重影响性能。即便真的影响了，提升一段整理良好代码的性能，也容易得多。

移除局部变量的福音，就是做提炼时会简单得多，因为你只需要与少量的局部作用域打交道。实际上，做任何提炼前，我一般都会将局部变量抽取出去。

处理完`amountFor`的参数后，我回过头来看一下它的调用点。它被赋值给一个临时变量，之后就不再被改变，因此我又采用了*Inline Variables*手法内联它。

*顶层作用域…*

```javascript
function statement(invoice, plays) {
  let totalAmount = 0;
  let volumeCredits = 0;
  let result = `Statement for ${invoice.customer}\n`;
  const format = new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: "USD",
    minimumFractionDigits: 2
  }).format;

  for (let perf of invoice.performances) {
    // add volume credits
    volumeCredits += Math.max(perf.audience - 30, 0);
    // add extra credit for every ten comedy attendees
    if ("comedy" === playFor(perf).type) volumeCredits += Math.floor(perf.audience / 5);

    // print line for this order
    result += ` ${playFor(perf).name}: ${format(amountFor(perf) / 100)} (${
      perf.audience
    } seats)\n`;
    totalAmount += thisAmount;
  }
  result += `Amount owed is ${format(amountFor(perf) / 100)}\n`;
  result += `You earned ${volumeCredits} credits\n`;
  return result;
}
```

## 抽取Volume积分

现在`statement`函数的内部实现是这样的：

*顶层作用域…*

```javascript
function statement(invoice, plays) {
  let totalAmount = 0;
  let volumeCredits = 0;
  let result = `Statement for ${invoice.customer}\n`;
  const format = new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: "USD",
    minimumFractionDigits: 2
  }).format;

  for (let perf of invoice.performances) {
    // add volume credits
    volumeCredits += Math.max(perf.audience - 30, 0);
    // add extra credit for every ten comedy attendees
    if ("comedy" === playFor(perf).type) volumeCredits += Math.floor(perf.audience / 5);

    // print line for this order
    result += ` ${playFor(perf).name}: ${format(amountFor(perf) / 100)} (${
      perf.audience
    } seats)\n`;
    totalAmount += thisAmount;
  }
  result += `Amount owed is ${format(amountFor(perf) / 100)}\n`;
  result += `You earned ${volumeCredits} credits\n`;
  return result;
}
```

现在我们就看到了移除`play`变量的好处，移除了一个局部作用域的变量，提炼volume积分计算逻辑又更简单了些。

我仍需要处理其他两个局部变量。`perf`同样可以轻易作为参数传入，但`volumeCredits`变量则有些棘手。它是个累加变量，每次循环都会更新它的值。因此最简单的方式是，将整块逻辑提炼到新的函数中，然后在新函数中直接返回。

*function statement...*

```javascript
function volumeCreditsFor(perf) {
  let volumeCredits = 0;
  volumeCredits += Math.max(perf.audience - 30, 0);
  if ("comedy" === playFor(perf).type) volumeCredits += Math.floor(perf.audience / 5);
  return volumeCredits;
}
```

*顶层作用域…*

```javascript
function statement(invoice, plays) {
  let totalAmount = 0;
  let volumeCredits = 0;
  let result = `Statement for ${invoice.customer}\n`;
  const format = new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: "USD",
    minimumFractionDigits: 2
  }).format;

  for (let perf of invoice.performances) {
    volumeCredits += volumeCreditsFor(perf);
    
    // print line for this order
    result += ` ${playFor(perf).name}: ${format(amountFor(perf) / 100)} (${
      perf.audience
    } seats)\n`;
    totalAmount += thisAmount;
  }
  result += `Amount owed is ${format(amountFor(perf) / 100)}\n`;
  result += `You earned ${volumeCredits} credits\n`;
  return result;
}
```

我还移除了多余的（此处第二条注释还是错误的）注释。

我再次重复编译-测试-提交循环，然后开始重命名新函数里的变量。

*function statement...*

```javascript
function volumeCreditsFor(aPerformance) {
  let result = 0;
  result += Math.max(aPerformance.audience - 30, 0);
  if ("comedy" === playFor(aPerformance).type) result += Math.floor(aPerformance.audience / 5);
  return result;
}
```

我只作为一个步骤进行了展示，但操作时我依然一次只重命名一个变量，并在每次重命名后进行一次编译-测试-提交。

## 移除`format`变量

我们再看一下`statement`这个主方法：

*顶层作用域…*

```javascript
function statement(invoice, plays) {
  let totalAmount = 0;
  let volumeCredits = 0;
  let result = `Statement for ${invoice.customer}\n`;
  const format = new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: "USD",
    minimumFractionDigits: 2
  }).format;

  for (let perf of invoice.performances) {
    // add volume credits
    volumeCredits += Math.max(perf.audience - 30, 0);
    // add extra credit for every ten comedy attendees
    if ("comedy" === playFor(perf).type) volumeCredits += Math.floor(perf.audience / 5);

    // print line for this order
    result += ` ${playFor(perf).name}: ${format(amountFor(perf) / 100)} (${
      perf.audience
    } seats)\n`;
    totalAmount += thisAmount;
  }
  result += `Amount owed is ${format(amountFor(perf) / 100)}\n`;
  result += `You earned ${volumeCredits} credits\n`;
  return result;
}
```
 
正如我上面所指出的，临时变量可能会是问题。它们只对处理它们的代码块中有用，因此临时变量事实上鼓励你写长长的、复杂的函数。下一步，我将要将一些临时变量替换掉。最简单的莫过于从`format`变量入手。这是典型的将函数赋值给变量，而这种场景下我倾向于声明一个函数。

*function statement...*

```javascript
function format(aNumber) {
  return new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: "USD",
    minimumFractionDigits: 2
  }).format(aNumber);
}
```

*顶层作用域…*

```javascript
function statement(invoice, plays) {
  let totalAmount = 0;
  let volumeCredits = 0;
  let result = `Statement for ${invoice.customer}\n`;

  for (let perf of invoice.performances) {
    volumeCredits += volumeCreditsFor(perf);

    // print line for this order
    result += ` ${playFor(perf).name}: ${format(amountFor(perf) / 100)} (${
      perf.audience
    } seats)\n`;
    totalAmount += thisAmount;
  }
  result += `Amount owed is ${format(amountFor(perf) / 100)}\n`;
  result += `You earned ${volumeCredits} credits\n`;
  return result;
}
```

尽管将函数变量改变成函数声明也是一种重构手法，但这里我既未为它命名，也没有将它纳入目录。还有很多的重构手法我都觉得没那么重要，不需要这样做。上面这个手法我觉得既简单，也少用，因此我觉得不值为其命名。

我对函数名称不很满意——`format`还未能清晰地描述其作用。`formatAsUSD`很表意，但又太长，特别它是被用于模板字符串中这样一个小的范围中。我认为这里真正要强调的是，它格式化的是一个货币数字，因此我选取了一个能体现此意图的命名，并应用了*Change Function Declaration*手法。

*顶层作用域…*

```javascript
function statement(invoice, plays) {
  let totalAmount = 0;
  let volumeCredits = 0;
  let result = `Statement for ${invoice.customer}\n`;

  for (let perf of invoice.performances) {
    volumeCredits += volumeCreditsFor(perf);

    // print line for this order
    result += ` ${playFor(perf).name}: ${usd(amountFor(perf))} (${
      perf.audience
    } seats)\n`;
    totalAmount += thisAmount;
  }
  result += `Amount owed is ${usd(amountFor(perf))}\n`;
  result += `You earned ${volumeCredits} credits\n`;
  return result;
}
```

*function statement...*

```javascript
function usd(aNumber) {
  return new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: "USD",
    minimumFractionDigits: 2
  }).format(aNumber/100);
}
```

命名既重要又不简单。只有命名恰当时，将大函数分解为小函数才能体现出价值。有了好的名称，我就不必通过阅读函数体来了解其行为。但要一次把名取好是困难的，因此我会使用当下能想到最好的那个。稍后如果想到更好的，我毫不犹豫就会换掉它。通常你需要花几秒钟通读更多代码，才能意识到最好的命名是什么。

重命名的同时，我还将重复的除100行为也搬移到函数里。将金钱存储为以美分为单元的正整数，是种常见的做法——这可以避免将货币的小数部分存为浮点数，同时又不影响我用数学运算符操作它。不过，展示这样一个美分单位的整数时，我总需要展示为美元形式，因此我让格式化函数来处理整除的事宜。

## 移除Volume积分总和

我的下一个目标是`volumeCredits`。处理这个变量更加微妙，因为它是在循环过程累加得到的。第一步，就是应用*Split Loop*将`volumeCredits`的累加过程分离出来：

*顶层作用域…*

```javascript
function statement(invoice, plays) {
  let totalAmount = 0;
  let volumeCredits = 0;
  let result = `Statement for ${invoice.customer}\n`;

  for (let perf of invoice.performances) {
    // print line for this order
    result += ` ${playFor(perf).name}: ${format(amountFor(perf) / 100)} (${
      perf.audience
    } seats)\n`;
    totalAmount += thisAmount;
  }
  for (let perf of invoice.performances) {
    volumeCredits += volumeCreditsFor(perf);
  }  
  result += `Amount owed is ${format(amountFor(perf) / 100)}\n`;
  result += `You earned ${volumeCredits} credits\n`;
  return result;
}
```

完成这一步，我就可以使用*Slide Statement*手法将变量声明挪到到紧邻循环的位置。

```javascript
function statement(invoice, plays) {
  let totalAmount = 0;
  let result = `Statement for ${invoice.customer}\n`;
  for (let perf of invoice.performances) {
    // print line for this order
    result += ` ${playFor(perf).name}: ${format(amountFor(perf) / 100)} (${
      perf.audience
    } seats)\n`;
    totalAmount += thisAmount;
  }
  let volumeCredits = 0;
  for (let perf of invoice.performances) {
    volumeCredits += volumeCreditsFor(perf);
  }  
  result += `Amount owed is ${format(amountFor(perf) / 100)}\n`;
  result += `You earned ${volumeCredits} credits\n`;
  return result;
}
```

把更新`volumeCredits`变量相关的代码都集中到一起，有利于使用*Replace Temp with Query*。如前所述，第一步是先对变量的计算过程应用*Extract Function*手法。

*function statement...*

```javascript
function totalVolumeCredits() {
  let volumeCredits = 0;
  for (let perf of invoice.performances) {
    volumeCredites += volumeCreditsFor(perf);
  }
  return volumeCredits;
}
```

*顶层作用域…*

```javascript
function statement(invoice, plays) {
  let totalAmount = 0;
  let result = `Statement for ${invoice.customer}\n`;
  for (let perf of invoice.performances) {
    // print line for this order
    result += ` ${playFor(perf).name}: ${format(amountFor(perf) / 100)} (${
      perf.audience
    } seats)\n`;
    totalAmount += thisAmount;
  }
  let volumeCredits = totalVolumeCredits();
  result += `Amount owed is ${format(amountFor(perf) / 100)}\n`;
  result += `You earned ${volumeCredits} credits\n`;
  return result;
}
```

完成函数提炼后，我就能应用*Inline Variables*手法了：

*顶层作用域…*

```javascript
function statement(invoice, plays) {
  let totalAmount = 0;
  let result = `Statement for ${invoice.customer}\n`;
  for (let perf of invoice.performances) {
    // print line for this order
    result += ` ${playFor(perf).name}: ${format(amountFor(perf) / 100)} (${
      perf.audience
    } seats)\n`;
    totalAmount += thisAmount;
  }
  result += `Amount owed is ${format(amountFor(perf) / 100)}\n`;
  result += `You earned ${totalVolumeCredits()} credits\n`;
  return result;
}
```

让我暂停一下，谈谈刚刚完成的修改。首先，我知道有些读者会再次对此修改带来的性能问题感觉担忧，我知道很多人本能警惕重复的循环。但大多数时候，像这样的循环重复一次，对性能的影响可忽略不计。如果你在重构前后进行计时，很可能不会留意到运行速度有明显区别——而且通常都是这样。许多程序员对代码实际的运行路径都所知不足，甚至经验丰富的程序员有时也会这样。在聪明的编译器、现代的缓存技术面前，我们很多直觉都是不准确的。软件的性能通常只与代码的一小部分相关，改变其他的部分对性能贡献甚微。

当然，「大多数」不等同于「所有」。有时，一些重构手法也会显著地降低性能。但即便如此，我通常也不去管它，继续重构，因为回头调解一份结构良好代码的性能，也容易得多。如果我在重构时引入了明显的性能损耗，我后面会花时间进行性能调优。进行调优时，可能会回退我早先做的一些重构——但更多时候，因重构的便利我可以使用更高效的调优方案。最后我得到的是既整洁又高效的代码。

因此对于重构过程的性能问题，我总体的建议是：大多数情况下你可以忽略它。如果重构引入了性能损耗，先完成重构，再做性能优化。

我希望引入你注意的第二点是，我们移除`volumeCredits`时是多么小步。整个过程一共有4步，每一步都伴随着一次编译-测试-向本地代码库的提交：

* 使用*Split Loop*分离出累加过程
* 使用*Slide Statement*将初始化代码与累加过程集中到一起
* 使用*Extract Function*提炼出计算总数的函数
* 使用*Inline Variables*完全移除中间变量

我得坦白，我并非总是如此小步——但事情变复杂时，我的第一反应就是采用更小的步子。怎样算变复杂呢，就是重构过程有测试挂掉，我又无法马上看见并修复问题时，那我就会回滚到最后一次好的提交，然后以更小的步子重做。这得益于我如此频繁的提交。特别是与复杂代码打交道时，细小的步子是快速前进的关键。

然后我要重复同样的步骤来移除`totalAmount`。我以拆解循环开始（然后编译-测试-提交），然后下移变量的初始化（编译-测试-提交），最后再提炼函数。这里有点头疼的是：最好的函数名应该是「totalAmount」，但它已经被变量名占用，我无法都起同一个名字。因此，我提炼函数时先随便给了它一个名字（然后编译-测试-提交）。

*function statement...*

```javascript
function appleSauce() {
  let totalAmount = 0;
  for (let perf of invoice.performances) {
    totalAmount += amountFor(perf);
  }
  return totalAmount;
}
```

*顶层作用域…*

```javascript
function statement (invoice, plays) {
  let result = `Statement for ${invoice.customer}\n`;
  for (let perf of invoice.performances) {
    result += ` ${playFor(perf).name}: ${usd(amountFor(perf))} (${perf.audience} seats)\n`;
  }
  let totalAmount = appleSauce();
 
  result += `Amount owed is ${usd(totalAmount)}\n`;
  result += `You earned ${totalVolumeCredits()} credits\n`;
  return result;
}
```

然后内联变量（编译-测试-提交），并重命名函数，给它一个更有意义的名字（编译-测试-提交）。

*顶层作用域…*

```javascript
function statement (invoice, plays) {
  let result = `Statement for ${invoice.customer}\n`;
  for (let perf of invoice.performances) {
    result += ` ${playFor(perf).name}: ${usd(amountFor(perf))} (${perf.audience} seats)\n`;
  }
  result += `Amount owed is ${usd(totalAmount())}\n`;
  result += `You earned ${totalVolumeCredits()} credits\n`;
  return result;
}
```

*function statement...*

```javascript
function totalAmount() {
  let totalAmount = 0;
  for (let perf of invoice.performances) {
    totalAmount += amountFor(perf);
  }
  return totalAmount;
}
```

趁着重命名提炼后的函数，我顺便将其内部的变量名改了，以与我的编码风格保持统一。

```javascript
function totalAmount() {
  let result = 0;
  for (let perf of invoice.performances) {
    result += amountFor(perf);
  }
  return result;
}
function totalVolumeCredits() {
  let result = 0;
  for (let perf of invoice.performances) {
    result += volumeCreditsFor(perf);
  }
  return result;
}
```
