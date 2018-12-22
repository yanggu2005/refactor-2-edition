# The Starting Point

# 起点

在本书第一版中，我用的实例程序，是为影片出租店打印一张详单。放到现在，你们很多人可能要问了：「影片出租店是个啥」？为了避免回答这个问题，我重新升级了一下这个例子，to something that is both older and still current。

> video rental store 怎么翻译比较贴切中国（及港澳台）国情呢

> 「影片出租店是个啥」 是否太口语？

> 如何翻出 re-skinned？如何翻译 that is both older and still current？

想想一个话剧公司，旗下有很多话剧演员，他们经常要去各种场合演出。一般来讲，顾客对某些剧场有需求，而公司则根据观众的多寡和话剧的类型来决定收费。该公司目前上演两类剧场：悲剧和喜剧。公司不仅会打印表演的详单，还会为顾客提供一些优惠，在其他场次的场次中使用可以优惠——一种提升顾客忠诚度的方式。

戏剧的数据存储在一个简单的 JSON 文件中，这个文件是这样的：

_plays.json..._
`json { "hamlet": {"name": "Hamlet", "type": "tragedy"}, "as-like": {"name": "As You Like It", "type": "comedy"}, "othello": {"name": "Othello", "type": "tragedy"} }`

> 表演的详单，怪怪的

> volume credits，是个啥

> mechanism，机制，但直译机制不好
