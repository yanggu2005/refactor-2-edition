# Splitting the Phases of Calculation and Formatting

# 分离计算阶段与格式化阶段

到目前为止，我的重构主要是为原函数添加基本的结构，以便我更好地理解它，看清它的逻辑结构。重构的早期步骤一般都是这样。将复杂的代码块分解为更小的单元非常重要，与好的命名同等重要。现在，我可以更多关注我要修改的功能部分了——也即是为这张详单提供一个 HTML 版本。不管怎么说，现在改起来更加简单了。因为计算代码已经被分离出来，我只需要为顶部的七行代码实现一个 HTML 的版本。问题是，这些分解出来的函数嵌套在打印文本详单的函数里，我总不想将它们全复制粘贴到一个新的函数里，不管组织得有多好。我希望同样的计算函数可以被文本版详单和 HTML 版详单共用。

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
function statement (invoice, plays) {
  const statementData = {}
  statementData.customer = invoice.customer
  return renderPlainText(statementData, invoice, plays);
}

function renderPlainText(data, invoice, plays) {
  let result = `Statement for ${data.customer}\n`;
  for (let perf of invoice.performances) {
    result += ` ${playFor(perf).name}: ${usd(amountFor(perf))} (${perf.audience} seats)\n`;
  }
  result += `Amount owed is ${usd(totalAmount())}\n`;
  result += `You earned ${totalVolumeCredits()} credits\n`;
  return result;
}
```

类似地，我将performance字段也搬移过去，这样我就可以移除掉`renderPlainText`的`invoice`参数（编译-测试-提交）。

*顶层作用域…*

```javascript
function statement (invoice, plays) {
  const statementData = {}
  statementData.customer = invoice.customer
  statementData.performances = invoice.performances
  return renderPlainText(statementData, plays);
}

function renderPlainText(data, plays) {
  let result = `Statement for ${data.customer}\n`;
  for (let perf of data.performances) {
    result += ` ${playFor(perf).name}: ${usd(amountFor(perf))} (${perf.audience} seats)\n`;
  }
  result += `Amount owed is ${usd(totalAmount())}\n`;
  result += `You earned ${totalVolumeCredits()} credits\n`;
  return result;
}
```

*function renderPlainText...*

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

现在，我希望`play`变量也从中间数据中获得。为此，需要使用play中的数据填充performance对象（编译-测试-提交）。

```javascript
function statement (invoice, plays) {
  const statementData = {}
  statementData.customer = invoice.customer
  statementData.performances = invoice.performances.map(enrichPerformance)
  return renderPlainText(statementData, plays);
  
  function enrichPerformance(aPerformance) {
    const result = Object.assign({}, aPerformance);
    return result;
  }
}
```

目前为止我只是简单地返回了一个performance对象的拷贝，但马上我就会添加新的数据到这条记录(record)中。返回拷贝的原因是，我不想修改传给函数的数据。我尽可能地以不可变对象的方式看待数据——可变状态很快就会反咬你一口。

> `result = Object.assign({}, aPerformance)`的写法，不熟悉JavaScript的人看来可能十分奇怪。它返回的是一个浅拷贝。虽然我更希望有个函数来完成此功能，但这个用法是如此约定俗成，如果我自己写个函数，于JavaScript程序员看来可能格格不入。



