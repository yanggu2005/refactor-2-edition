# Insider Trading

Software people like strong walls between their modules and complain bitterly about how trading data around too much increases coupling. To make things work, some trade has to occur, but we need to reduce it to a minimum and keep it all above board.

Modules that whisper to each other by the coffee machine need to be separated by using Move Function and Move Field to reduce the need to chat. If modules have common interests, try to create a third module to keep that commonality in a well-regulated vehicle, or use Hide Delegate to make another module act as an intermediary.

Inheritance can often lead to collusion. Subclasses are always going to know more about their parents than their parents would like them to know. If it’s time to leave home, apply Replace Subclass with Delegate or Replace Superclass with Delegate.

