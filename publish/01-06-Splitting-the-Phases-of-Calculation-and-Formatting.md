# 分离计算阶段与格式化阶段

到目前为止，我的重构主要是为原函数添加基本的结构，以便我更好地理解它，看清它的逻辑结构。这也是重构早期的一般步骤。把复杂的代码块分解为更小的单元，与好的命名一样都很重要。现在，我可以更多关注我要修改的功能部分了——也即是为这张详单提供一个HTML版本。不管怎么说，现在改起来更加简单了。因为计算代码已经被分离出来，我只需要为顶部的七行代码实现一个HTML的版本。问题是，这些分解出来的函数嵌套在打印文本详单的函数中。无论嵌套的函数组织多么良好，我总不想将它们全复制粘贴到另一个新的函数中。我希望同样的计算函数可以被文本版详单和HTML版详单共用。

要实现复用有许多种方法，我最喜欢的技术是*Split Phrase*。这里我的目标是将逻辑分割成两部分：一部分计算详单所需的数据，另一部分将数据渲染成文本或 HTML。第一阶段会创建一个中间数据结构，然后把它传递给第二阶段。

要开始*Split Phrase*，我会先对组成第二阶段的代码应用*Extract Function*。在我们的场景中，这部分代码即是打印详单的代码，其实即是`statement`函数的全部内容。把它们与所有嵌套的函数一起抽取到一个新的顶层函数中，我将这个函数命名为`renderPlainText`。

```javascript
function statement (invoice, plays) {
  return renderPlainText(invoice, plays);
}

function renderPlainText(invoice, plays) {
  let result = `Statement for ${invoice.customer}\n`;
  for (let perf of invoice.performances) {
    result += ` ${playFor(perf).name}: ${usd(amountFor(perf))} (${perf.audience} seats)\n`;
  }
  result += `Amount owed is ${usd(totalAmount())}\n`;
  result += `You earned ${totalVolumeCredits()} credits\n`;
  return result;
}

function totalAmount() {...}
function totalVolumeCredits() {...}
function usd(aNumber) {...}
function volumeCreditsFor(aPerformance) {...}
function playFor(aPerformance) {...}
function amountFor(aPerformance) {...}
```

我依然遵循编译-测试-提交循环，然后创建一个对象，作为在两个阶段间传递的中间数据结构。将这个数据对象作为第一个参数传递给`renderPlainText`（然后编译-测试-提交）。

```javascript
function statement (invoice, plays) {
  const statementData = {}
  return renderPlainText(statementData, invoice, plays);
}

function renderPlainText(data, invoice, plays) {
  let result = `Statement for ${invoice.customer}\n`;
  for (let perf of invoice.performances) {
    result += ` ${playFor(perf).name}: ${usd(amountFor(perf))} (${perf.audience} seats)\n`;
  }
  result += `Amount owed is ${usd(totalAmount())}\n`;
  result += `You earned ${totalVolumeCredits()} credits\n`;
  return result;
}

function totalAmount() {...}
function totalVolumeCredits() {...}
function usd(aNumber) {...}
function volumeCreditsFor(aPerformance) {...}
function playFor(aPerformance) {...}
function amountFor(aPerformance) {...}
```

现在我要检查一下`renderPlainText`用到的其他参数。我希望将它们挪到这个中间的数据结构里，这样所有计算代码都可以被挪到`statement`函数中，`renderPlainText`仅会对通过`data`参数传进来的数据进行操作。

第一步是将顾客字段添加到中间对象里（编译-测试-提交）。

```javascript
function statement(invoice, plays) {
  const statementData = {};
  statementData.customer = invoice.customer;
  return renderPlainText(statementData, invoice, plays);
}

function renderPlainText(data, invoice, plays) {
  let result = `Statement for ${data.customer}\n`;
  for (let perf of invoice.performances) {
    result += ` ${playFor(perf).name}: ${usd(amountFor(perf))} (${
      perf.audience
    } seats)\n`;
  }
  result += `Amount owed is ${usd(totalAmount())}\n`;
  result += `You earned ${totalVolumeCredits()} credits\n`;
  return result;
}
```

类似地，我将 performance 字段也搬移过去，这样我就可以移除掉`renderPlainText`的`invoice`参数（编译-测试-提交）。

_顶层作用域…_

```javascript
function statement(invoice, plays) {
  const statementData = {};
  statementData.customer = invoice.customer;
  statementData.performances = invoice.performances;
  return renderPlainText(statementData, plays);
}

function renderPlainText(data, plays) {
  let result = `Statement for ${data.customer}\n`;
  for (let perf of data.performances) {
    result += ` ${playFor(perf).name}: ${usd(amountFor(perf))} (${
      perf.audience
    } seats)\n`;
  }
  result += `Amount owed is ${usd(totalAmount())}\n`;
  result += `You earned ${totalVolumeCredits()} credits\n`;
  return result;
}
```

_function renderPlainText..._

```javascript
function totalAmount() {
  let result = 0;
  for (let perf of data.performances) {
    result += amountFor(perf);
  }
  return result;
}

function totalVolumeCredits() {
  let result = 0;
  for (let perf of data.performances) {
    result += volumeCreditsFor(perf);
  }
  return result;
}
```

现在，我希望`play`变量也从中间数据中获得。为此，需要使用 play 中的数据填充 performance 对象（编译-测试-提交）。

```javascript
function statement(invoice, plays) {
  const statementData = {};
  statementData.customer = invoice.customer;
  statementData.performances = invoice.performances.map(enrichPerformance);
  return renderPlainText(statementData, plays);

  function enrichPerformance(aPerformance) {
    const result = Object.assign({}, aPerformance);
    return result;
  }
}
```

目前为止我只是简单地返回了一个 performance 对象的拷贝，但马上我就会添加新的数据到这条记录(record)中。返回拷贝的原因是，我不想修改传给函数的数据。我尽可能地以不可变对象的方式看待数据——可变状态很快就会反咬你一口。

> `result = Object.assign({}, aPerformance)`的写法，不熟悉 JavaScript 的人看来可能十分奇怪。它返回的是一个浅拷贝。虽然我更希望有个函数来完成此功能，但这个用法是如此约定俗成，如果我自己写个函数，于 JavaScript 程序员看来可能格格不入。

Now I have a spot for the play, 需要把它加上。我需要对`playFor`和`statement`函数应用*Move Function*（然后编译-测试-提交）。

_function statement..._

```javascript
function enrichPerformance(aPerformance) {
  const result = Object.assign({}, aPerformance);
  result.play = playFor(result);
  return result;
}
function playFor(aPerformance) {
  return plays[aPerformance.playID];
}
```

然后我就可以替换`renderPlainText`中对`playFor`的所有引用点了，让它们使用新的数据（编译-测试-提交）。

_function renderPlainText..._

```javascript
let result = `Statement for ${data.customer}\n`;
for (let perf of data.performances) {
  result += ` ${perf.play.name}: ${usd(amountFor(perf))} (${
    perf.audience
  } seats)\n`;
}
result += `Amount owed is ${usd(totalAmount())}\n`;
result += `You earned ${totalVolumeCredits()} credits\n`;
return result;

function volumeCreditsFor(aPerformance) {
  let result = 0;
  result += Math.max(aPerformance.audience - 30, 0);
  if ("comedy" === aPerformance.play.type)
    result += Math.floor(aPerformance.audience / 5);
  return result;
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
```

然后我可以类似的手法搬移`amountFor`（编译-测试-提交）。

_function statement..._

```javascript
function enrichPerformance(aPerformance) {
  const result = Object.assign({}, aPerformance);
  result.play = playFor(result);
  result.amount = amountFor(result);
  return result;
}
function amountFor(aPerformance) {...}
```

_function renderPlainText..._

```javascript
let result = `Statement for ${data.customer}\n`;
for (let perf of data.performances) {
  result += ` ${perf.play.name}: ${usd(perf.amount)} (${
    perf.audience
  } seats)\n`;
}
result += `Amount owed is ${usd(totalAmount())}\n`;
result += `You earned ${totalVolumeCredits()} credits\n`;
return result;
```

```javascript
function totalAmount() {
  let result = 0;
  for (let perf of data.performances) {
    result += perf.amount;
  }
  return result;
}
```

接着搬移 volume 积分计算（编译-测试-提交）。

_function statement..._

```javascript
function enrichPerformance(aPerformance) {
  const result = Object.assign({}, aPerformance);
  result.play = playFor(result);
  result.amount = amountFor(result);
  result.volumeCredits = volumeCreditsFor(result);
  return result;
}

function volumeCreditsFor(aPerformance) {...}
```

_function renderPlainText..._

```javascript
function totalVolumeCredits() {
  let result = 0;
  for (let perf of data.performances) {
    result += perf.volumeCredits;
  }
  return result;
}
```

最后，我将两个计算总数的函数搬移过来。

_function statement..._

```javascript
function statement (invoice, plays) {
  const statementData = {}
  statementData.customer = invoice.customer
  statementData.performances = invoice.performances.map(enrichPerformance)
  statementData.totalAmount = totalAmount(statementData)
  statementData.totalVolumeCredits = totalVolumeCredits(statementData)
  return renderPlainText(statementData, plays);

  function totalAmount(data) {...}
    function totalVolumeCredits(data) {...}
}
```

_function renderPlainText..._

```javascript
let result = `Statement for ${data.customer}\n`;
for (let perf of data.performances) {
  result += ` ${perf.play.name}: ${usd(perf.amount)} (${
    perf.audience
  } seats)\n`;
}
result += `Amount owed is ${usd(data.totalAmount)}\n`;
result += `You earned ${data.totalVolumeCredits}\n`;
return result;
```

尽管我能够修改函数体，使这些计算总数的函数直接使用`statementData`变量（反正它在作用域内），但我更喜欢显式地传入函数参数。

一旦搬移完成，编译-测试-提交做完后，我便忍不住对几处地方快速应用一下*Replace Loop with Pipeline*。

_function renderPlainText..._

```javascript
function totalAmount(data) {
  return data.performances.reduce((total, p) => total + p.amount, 0);
}

function totalVolumeCredits(data) {
  return data.performances.reduce((total, p) => total + p.volumeCredits, 0);
}
```

现在我可以把第一阶段的代码提炼到一个单独的函数里了（编译-测试-提交）。

_顶层作用域…_

```javascript
function statement(invoice, plays) {
  return renderPlainText(createStatementData(invoice, plays));
}

function createStatementData(invoice, plays) {
  const statementData = {};
  statementData.customer = invoice.customer;
  statementData.performances = invoice.performances.map(enrichPerformance);
  statementData.totalAmount = totalAmount(statementData);
  statementData.totalVolumeCredits = totalVolumeCredits(statementData);
  return statementData;
}
```

因为两个阶段已彻底分离，我就把它搬移到一个单独的文件中去（并且修改了返回值的变量名，以符合我的编码风格）。

_statement.js..._

```javascript
import createStatementData from "./createStatementData.js";
```

_createStatementData.js..._

```javascript
export default function createStatementData(invoice, plays) {
  const result = {};
  result.customer = invoice.customer;
  result.performances = invoice.performances.map(enrichPerformance);
  result.totalAmount = totalAmount(result);
  result.totalVolumeCredits = totalVolumeCredits(result);
  return result;

  function enrichPerformance(aPerformance) {...}
    function playFor(aPerformance) {...}
    function amountFor(aPerformance) {...}
    function volumeCreditsFor(aPerformance) {...}
    function totalAmount(data) {...}
    function totalVolumeCredits(data) {...}
}
```

one final swing of 编译-测试-提交——接下来要编写一个 HTML 版本就很简单了。

_statement.js..._

```javascript
function htmlStatement(invoice, plays) {
  return renderHtml(createStatementData(invoice, plays));
}

function renderHtml(data) {
  let result = `<h1>Statement for ${data.customer}</h1>\n`;
  result += "<table>\n";
  result += "<tr><th>play</th><th>seats</th><th>cost</th></tr>";
  for (let perf of data.performances) {
    result += ` <tr><td>${perf.play.name}</td><td>${perf.audience}</td>`;
    result += `<td>${usd(perf.amount)}</td></tr>\n`;
  }
  result += "</table>\n";
  result += `<p>Amount owed is <em>${usd(data.totalAmount)}</em></p>\n`;
  result += `<p>You earned <em>${data.totalVolumeCredits}</em> credits</p>\n`;
  return result;
}

function usd(aNumber) {...}
```

（我把`usd`函数也搬移到顶层作用域里，以便`renderHtml`也能访问它。）
