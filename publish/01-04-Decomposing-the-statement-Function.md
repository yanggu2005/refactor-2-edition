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

要我的理解转化到代码里，我们需要将这块代码自身抽取成一个函数，按它所干的事情给它命名——比如`amountFor(performance)`。每次我想将一块代码抽取成一个函数时，有个标准流程可以最大程度减少我犯错的机会。我把这个流程记录了下来，将其命名为「提炼函数」[106]，以便我可以方便地引用它。

首先检查一下，如果我将这块代码抽取到自己的一个函数里，有哪些变量将不在作用域里。在此实例中，是这三个变量：`perf`、`play`和`thisAmount`。前两个会被抽取后的函数使用，但不会被修改，那么我就可以将它们以参数方式传递进来。你需要更多关注会被修改的变量。这里只有唯一一个，因此我可以直接将它返回。我还可以将其初始化放到抽取后的函数里。这些更改会得到这样的代码：

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

原来的`statement`函数现在可以直接调用这个新抽取的函数来初始化`thisAmount`：

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



