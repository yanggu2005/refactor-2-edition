# TODOLIST

* 出版物的样式指南，包括：
  * 数字与正文之间不应该有空格
  * 英文与正文中文之间不应该有空格
  * 代码块的缩进等是否应与原书保持完全一致？
  * 正文中的重构手法保持英文，英文加斜体
* 目前我的 WebStorm 不知道为何无法输入中文双引号，后期统一做替换调整
* 字体、段落间距、行间距等，可后期做统一调整

## terminology / translations 

* keep track of: fully aware and informed about, 目前翻「跟踪」？
* bug detector：bug检测器，「器」总觉得俗
* phase: 目前翻为「阶段」？ 01-06 => 挺好
* statement: 结算单/详单？目前翻「详单」
* record：记录？似乎是一类数据结构，有约定俗成翻译否？
* [x] self-checking：自我检验 - 与原来保持一致
* [x] extract：继续翻译成提炼还是抽取 => 还是“提炼”好些，我希望尽量保持原来的味道

## Questions

* Global data that you can guarantee never changes after the program starts is relatively safe—if you have a language that can enforce that guarantee. -- 具体指什么语言的什么特性？

* If there is additional behavior, you can use Replace Superclass with Delegate or Replace Subclass with Delegate to fold the middle man into the real object. That allows you to extend behavior without chasing all that delegation. => 我觉得应该是反过来，Replace Delegation with Inheritance才对，是不是写错了？

* 0204：Those changes can often be greater in the existing code than in the new code. => greater是指什么？