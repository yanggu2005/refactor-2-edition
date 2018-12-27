# Reorganizing the Calculations by Type

# 按类型重组计算过程

接下来我将注意力集中到下一个特性改动：支持更多类型的戏剧，每种戏剧有自己的价格计算和积分计算。对于现在的结构，我只需要在计算函数里添加分支逻辑。`amountFor`函数highlights the central role the type of play has in the choice of calculations——但这样的分支逻辑很容易随代码堆积而腐坏，unless it's reinforced by more structural elements of the programming language.

There are various ways to introduce structure to make this explicit，不过这种场景下自然的方式是使用类型多态——一个经典的面向对象特性。传统的面向对象特性在JavaScript世界一直备受争议，但ECMAScript 2015为此特性提供了一个广为人知的语法。因此，在合适的场景下使用面向对象是合理的——显然我们这个场景就很合适。

我总体的设想是先建立一个继承体系，有喜剧和悲剧两个子类，它们各自包含独立的计算逻辑。调用者通过调用一个多态的`amount`函数，让语言帮你分发到不同的悲剧或喜剧的计算过程中。为此我需要用到多种重构方法。最核心的一招是*Replace Conditional with Polymorphism*，用多态取代整块的条件表达式。但在我施展*Replace Conditional with Polymorphism*之前，我得先创建一个基本的继承结构。我需要先创建一个类，并将价格函数和volume积分函数放进去。

我会先从检查计算代码开始（之前的重构使人感觉愉悦的一点是，如今我可以忽略那些格式化代码，只要我不改变输出的数据结构。我可以进一步添加测试来保证中间数据结构不会被以外修改。）

*createStatementData.js...*

```javascript
export default function createStatementData(invoice, plays) {
  const result = {};
  result.customer = invoice.customer;
  result.performances = invoice.performances.map(enrichPerformance);
  result.totalAmount = totalAmount(result);
  result.totalVolumeCredits = totalVolumeCredits(result);
  return result;

  function enrichPerformance(aPerformance) {
    const result = Object.assign({}, aPerformance);
    result.play = playFor(result);
    result.amount = amountFor(result);
    result.volumeCredits = volumeCreditsFor(result);
    return result;
  }
  function playFor(aPerformance) {
    return plays[aPerformance.playID];
  }
  function amountFor(aPerformance) {
    let result = 0;
    switch (aPerformance.play.type) {
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
        throw new Error(`unknown type: ${aPerformance.play.type}`);
    }
    return result;
  }
  function volumeCreditsFor(aPerformance) {
    let result = 0;
    result += Math.max(aPerformance.audience - 30, 0);
    if ("comedy" === aPerformance.play.type) result += Math.floor(aPerformance.audience / 5);
    return result;
  }
  function totalAmount(data) {
    return data.performances
      .reduce((total, p) => total + p.amount, 0);
  }
  function totalVolumeCredits(data) {
    return data.performances
      .reduce((total, p) => total + p.volumeCredits, 0); 
  }
}
```

## 创建一个Performance计算器

`enrichPerformance`函数是关键，因为正是它用每场performance的数据来填充中间的数据结构。目前它是直接调用了计算价格和volume积分的函数。我需要做的是创建一个类，通过该类来调用这些函数。由于这个类存放了performance数据的计算函数，所以我将其命名为performance计算器。

*function createStatementData...* 

```javascript
function enrichPerformance(aPerformance) {
  const calculator = new PerformanceCalculator(aPerformance);
  const result = Object.assign({}, aPerformance);
  result.play = playFor(result);
  result.amount = amountFor(result);
  result.volumeCredits = volumeCreditsFor(result);
  return result;
}
```

*顶层作用域…*

```javascript
class PerformanceCalculator {
  constructor(aPerformance) {
    this.performance = aPerformance
  }
}
```

目前为止，这个对象还没做什么事。我希望将函数行为搬移进来——可以从最容易搬移的东西开始，也就是play字段。严格来说，我并不需要搬移这个字段，因为它没有体现出多态性，但将它一起搬移可以把所有数据转换集中到一处地方，保持一致性，使代码更清晰。

我将使用*Change Function Declaration*手法将performance的play变量传给计算器。

*function createStatementData...* 

```javascript
function enrichPerformance(aPerformance) {
  const calculator = new PerformanceCalculator(aPerformance, playFor(aPerformance));
  const result = Object.assign({}, aPerformance);
  result.play = calculator.play;
  result.amount = amountFor(result);
  result.volumeCredits = volumeCreditsFor(result);
  return result;
}
```

*class PerformanceCalculator...*

```javascript
class PerformanceCalculator {
  constructor(aPerformance, aPlay) {
    this.performance = aPerformance
    this.play = aPlay;
  }
}
```

（以下行文我不会再特别提及编译-测试-提交，我猜你也已经读得不厌其烦。但我仍会不断地重复做。确实有时我也会烦，直到错误又有机会跳出来咬我一下，我才又学会进入小步的节奏。）

## 将函数搬移进计算器

我要搬移的下一块逻辑，对于计算performance的价格来说就尤为重要了。重新调整嵌套函数的层级时，我经常要将函数挪来挪去，但接下来这个改动需要更深层的函数上下文，因此我将小心使用*Move Function*来重构它。首先，将函数逻辑拷贝一份到新的上下文中，也就是类里头。然后需要微调一下代码，将`aPerformance`和`playFor(aPerformance)`分别指向`this.performance`和`this.play`，使它能适应这个新家。

*class PerformanceCalculator...*

```javascript
get amount() {
  let result = 0;
  switch (this.play.type) {
    case "tragedy": 
      result = 40000;
      if (this.performance.audience > 30) {
        result += 1000 * (this.performance.audience - 30);
      }
      break;
    case "comedy": 
      result = 30000;
      if (this.performance.audience > 20) {
        result += 10000 + 500 * (this.performance.audience - 20);
      }
      result += 300 * this.performance.audience;
      break;
    default: 
      throw new Error(`unknown type: ${this.play.type}`);
  }
  return result;
}
```

搬移完成后，我可以编译一下，看看是否有任何编译错误。「编译」阶段会自动在我本地开发环境运行代码时自动发生，我实际需要做的只是跑一下Babel[babel]。这能帮我发现新函数潜在的语法错误——其他的就帮不上忙了。尽管如此，这一步还是很有用。

新函数适应了新家后，我会回到原来的函数，将它改造成一个委托函数，并直接调用新的函数。

*function createStatementData...* 

```javascript
function amountFor(aPerformance) {
  return new PerformanceCalculator(aPerformance, playFor(aPerformance)).amount;
}
```

现在，我可以进行一次编译-测试-提交，确保代码搬到新家也能正常工作。之后，我会用*Inline Function*直接从引用点调用新的函数（然后编译-测试-提交）。

*function createStatementData...* 

```javascript
function enrichPerformance(aPerformance) {
  const calculator = new PerformanceCalculator(aPerformance, playFor(aPerformance));
  const result = Object.assign({}, aPerformance);
  result.play = calculator.play;
  result.amount = calculator.amount;
  result.volumeCredits = volumeCreditsFor(result);
  return result;
}
```

搬移volume积分计算也遵循同样的流程：

*function createStatementData...* 

```javascript
function enrichPerformance(aPerformance) {
  const calculator = new PerformanceCalculator(aPerformance, playFor(aPerformance));
  const result = Object.assign({}, aPerformance);
  result.play = calculator.play;
  result.amount = calculator.amount;
  result.volumeCredits = calculator.volumeCredits;
  return result;
}
```

*class PerformanceCalculator...*

```javascript
get volumeCredits() {
  let result = 0;
  result += Math.max(this.performance.audience - 30, 0);
  if ("comedy" === this.play.type) result += Math.floor(this.performance.audience / 5);
  return result;
}
```

## 使Performance计算器具备多态性

我已将全部计算逻辑搬移到类中，是时候将它多态化了。第一步是应用*Replace Type Code with Subclasses*引入子类，而不要沿用类型代码。为此，我得为performance计算器创建子类，并在`createPerformanceData`中得到适当的子类。为了拿到正确的子类，我需要将构造函数调用替换为一个普通函数调用，因为JavaScript的构造函数里无法返回子类。我即将使用的手法是*Replace Constructor with Factory Function*。

*function createStatementData...* 

```javascript
function enrichPerformance(aPerformance) {
  const calculator = createPerformanceCalculator(aPerformance, playFor(aPerformance));
  const result = Object.assign({}, aPerformance);
  result.play = calculator.play;
  result.amount = amountFor(result);
  result.volumeCredits = volumeCreditsFor(result);
  return result;
}
```

*顶层作用域…*

```javascript
function createPerformanceCalculator(aPerformance, aPlay) {
  return new PerformanceCalculator(aPerformance, aPlay)
}
```

改造为普通函数后，我就可以在里面创建performance计算器的子类了，然后由创建函数决定返回哪个。

*顶层作用域…*

```javascript
function createPerformanceCalculator(aPerformance, aPlay) {
  switch (aPlay.type) {
    case "tragedy": return new TragedyCalculator(aPerformance, aPlay);
    case "comedy": return new ComedyCalculator(aPerformance, aPlay);
    default: 
      throw new Error(`unknown type: ${aPlay.type}`);
  }
}

class TragedyCalculator extends PerformanceCalculator { 
}

class ComedyCalculator extends PerformanceCalculator {
}
```

准备好实现多态的类结构后，我就可以继续使用*Replace Conditional with Polymorphism*手法了。

我先从悲剧的价格计算开始：

*class TragedyCalculator...*

```javascript
get amount() {
  let result = 40000;
  if (this.performance.audience > 30) {
    result += 1000 * (this.performance.audience - 30);
  }
  return result;
}
```

子类有了这个方法就足以覆盖到父类的条件分支。不过要是你也和我一样偏执，你就还会这样搞一下：

*class PerformanceCalculator...*

```javascript
get amount() {
  let result = 0;
  switch (this.play.type) {
    case "tragedy": 
      throw "bad thing";
    case "comedy": 
      result = 30000;
      if (this.performance.audience > 20) {
        result += 10000 + 500 * (this.performance.audience - 20);
      }
      result += 300 * this.performance.audience;
      break;
    default: 
      throw new Error(`unknown type: ${this.play.type}`);
  }
  return result;
}
```

直接把悲剧的分支删掉，留给default分支去捕获错误当然也行。但我更喜欢显式地抛出异常，况且这行代码也只会再存活个几分钟（这也是我为什么直接抛了个字符串而不用更好的错误对象的缘故）。

我再次进行编译-测试-提交。成功以后，再将喜剧类型的分支也下移到子类去。

*class ComedyCalculator...*

```javascript
get amount() {
  let result = 30000;
  if (this.performance.audience > 20) {
    result += 10000 + 500 * (this.performance.audience - 20);
  }
  result += 300 * this.performance.audience
  return result;
}
```

现在我也可以将父类的`amount`方法一并移除，反正它也不应再被调用到了。But it's kinder to my future self to leave a tombstone.

*class PerformanceCalculator...*

```javascript
get amount() {
  throw new Error('subclass responsibility');
}
```

下一个要取代的条件表达式是volume积分的计算。回顾了一下关于以后戏剧类型的讨论，我发现大多数类型的戏剧都以30位观众作为基线，仅一小部分有所不同。因此，将更为通用的逻辑放到基类作为默认条件，当有特殊场景时按需覆盖它，听起来十分合理。于是我将一部分喜剧的逻辑挪到了基类：

*class PerformanceCalculator...*

```javascript
get volumeCredits() {
  return Math.max(this.performance.audience - 30, 0);
}
```

*class ComedyCalculator...*

```javascript
get volumeCredits() {
  return super.volumeCredits + Math.floor(this.performance.audience / 5);
}
```
