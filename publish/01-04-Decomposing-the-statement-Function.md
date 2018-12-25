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

*statement函数…*

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

*statement函数…*

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

*statement函数…*

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

*statement函数…*

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

*statement函数…*

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

