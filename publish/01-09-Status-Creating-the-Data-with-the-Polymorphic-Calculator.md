# Status: Creating the Data with the Polymorphic Calculator

# 进展：使用了多态性的计算器来提供数据

又到了观摩代码的时刻，让我们看看为计算器引入多态对代码库有什么影响。

_createStatementData.js_

```javascript
export default function createStatementData(invoice, plays) {
  const result = {};
  result.customer = invoice.customer;
  result.performances = invoice.performances.map(enrichPerformance);
  result.totalAmount = totalAmount(result);
  result.totalVolumeCredits = totalVolumeCredits(result);
  return result;

  function enrichPerformance(aPerformance) {
    const calculator = createPerformanceCalculator(aPerformance, playFor(aPerformance));
    const result = Object.assign({}, aPerformance);
    result.play = calculator.play;
    result.amount = calculator.amount;
    result.volumeCredits = calculator.volumeCredits;
    return result;
  }
  function playFor(aPerformance) {
    return plays[aPerformance.playID];
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

function createPerformanceCalculator(aPerformance, aPlay) {
  switch (aPlay.type) {
  case "tragedy": return new TragedyCalculator(aPerformance, aPlay);
  case "comedy": return new ComedyCalculator(aPerformance, aPlay);
  default:
      throw new Error(`unknown type: ${aPlay.type}`);
  }
}

class PerformanceCalculator {
  constructor(aPerformance, aPlay) {
    this.performance = aPerformance;
    this.play = aPlay;
  }
  get amount() {
    throw new Error("subclass responsibility");
  }
  get volumeCredits() {
    return Math.max(this.performance.audience - 30, 0);
  }
}
class TragedyCalculator extends PerformanceCalculator {
  get amount() {
    let result = 40000;
    if (this.performance.audience > 30) {
      result += 1000 * (this.performance.audience - 30);
    }
    return result;
  }
}
class ComedyCalculator extends PerformanceCalculator {
  get amount() {
    let result = 30000;
    if (this.performance.audience > 20) {
      result += 10000 + 500 * (this.performance.audience - 20);
    }
    result += 300 * this.performance.audience;
    return result;
  }
  get volumeCredits() {
    return super.volumeCredits + Math.floor(this.performance.audience / 5);
  }
}
```

代码量仍然有所增加，因为我再次整理了代码结构。新结构的好处是，不同戏剧类型的计算集中到了一处地方。If most of the changes will be to this code, it will be helpful to have it clearly separated like this. 要添加新类型的戏剧时，只需要添加一个子类，并在创建函数中返回它。

这个实例还揭示了一些洞见，即什么时候使用这样的继承方案是有用的。上面我将条件分支的查找从两个不同的函数（`amountFor`和`volumeCreditsFor`）搬移到一个集中的`createPerformanceCalculator`构造函数中。有越多的函数依赖于同样类型的多态，这种继承方案就越有益处。

除了这样设计，还有另一种可能的方案，就是让`createPerformanceData`返回计算器实例本身，而非依赖于计算器自己来填充中间数据结构。JavaScript的类设计有不少好特性，有一个是getter函数用起来就像普通的数据存取。我在考量直接返回实例本身还是单独计算中间数据时，主要看数据的使用者是谁。在这个例子中，我更想展示的是如何使用中间数据结构，并以此来隐藏计算器背后的多态设计。
