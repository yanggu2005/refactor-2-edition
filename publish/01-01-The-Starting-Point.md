# 起点

在本书第一版中，我用的实例程序是为影片出租店的顾客打印一张详单。放到今天，你们很多人可能要问了：「影片出租店是什么」？为避免过多回答这个问题，我翻新了下例子，将其包装成一个仍有古典韵味，又尚未消亡的现代实例。

设想有一个戏剧演出团，演员们经常要去各种场合表演戏剧。通常顾客会有一些想看的剧目，而剧团则根据观众的多寡及剧目的类型来收取票价。该团目前出演两种戏剧：悲剧和喜剧。除了为顾客打印演出账单，剧团还推出了「volume积分」优惠，顾客下次观看演出时使用可以打折——你可以把它看做一种提升顾客忠诚度的方式。

该团将剧目的数据存储在一个简单的JSON文件中，这个文件是这样的：

*plays.json...*

```json
{
  "hamlet": { "name": "Hamlet", "type": "tragedy" },
  "as-like": { "name": "As You Like It", "type": "comedy" },
  "othello": { "name": "Othello", "type": "tragedy" }
}
```

他们开出的账单也存储在一个JSON文件里中：

*invoices.json...*

```json
[
  {
    "customer": "BigCo",
    "performances": [
      {
        "playID": "hamlet",
        "audience": 55
      },
      {
        "playID": "as-like",
        "audience": 35
      },
      {
        "playID": "othello",
        "audience": 40
      }
    ]
  }
]
```

打印账单的代码来自这段简单的函数：

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
    result += `  ${play.name}: ${format(thisAmount/100)} (${perf.audience} seats)\n`;
    totalAmount += thisAmount;
  }
  result += `Amount owed is ${format(totalAmount/100)}\n`;
  result += `You earned ${volumeCredits} credits\n`;
  return result;
}
```

用以上测试数据文件作为输入运行这段代码，会得到如下输出：

```
Statement for BigCo
  Hamlet: $650.00 (55 seats)
  As You Like It: $580.00 (35 seats)
  Othello: $500.00 (40 seats)
Amount owed is $1,730.00
You earned 47 credits
```
