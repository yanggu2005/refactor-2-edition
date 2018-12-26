# Sample Code to Test

Here's some code to look at and test. The code supports a simple application that allows a user to examine and manipulate a production plan. The (crude) UI looks like this:

（图4-1）

The production plan has a demand and price for each province. Each province has producers, each of which can produce a certain number of units at a particular price. The UI also shows how much revenue each producer would earn if they sell all their production. At the bottom, the screen shows the shortfall in production (the demand minus the total production) and the profit for this plan. The UI allows the user to manipulate the demand, price, and the individual producer's production and costs to see the effect on the production shortfall and profits. Whenever a user changes any number in the display, all the others update immediately.

I'm showing a user interface here, so you can sense how the software is used, but I'm only going to concentrate on the business logic part of the software—that is, the classes that calculate the profit and the shortfall, not the code that generates the HTML and hooks up the field changes to the underlying business logic. This chapter is just an introduction to the world of self-testing code, so it makes sense for me to start with the easiest case—which is code that doesn't involve user interface, persistence, or external service interaction. Such separation, however, is a good idea in any case: Once this kind of business logic gets at all complicated, I will separate it from the UI mechanics so I can more easily reason about it and test it.

This business logic code involves two classes: one that represents a single producer, and the other that represents a whole province. The province's constructor takes a JavaScript object—one we could imagine being supplied by a JSON document.

Here's the code that loads the province from the JSON data:

class Province…

  constructor(doc) {
    this._name = doc.name;
    this._producers = [];
    this._totalProduction = 0;
    this._demand = doc.demand;
    this._price = doc.price;
    doc.producers.forEach(d => this.addProducer(new Producer(this, d)));
  }
  addProducer(arg) {
    this._producers.push(arg);
    this._totalProduction += arg.production;
  }
  
This function creates suitable JSON data. I can create a sample province for testing by constructing a province object with the result of this function.

top level…

  function sampleProvinceData() {
    return {
      name: "Asia",
      producers: [
        {name: "Byzantium", cost: 10, production: 9},
        {name: "Attalia",   cost: 12, production: 10},
        {name: "Sinope",    cost: 10, production: 6},
      ],
      demand: 30,
      price: 20
    };
  }
The province class has accessors for the various data values:

class Province…

  get name()    {return this._name;}
  get producers() {return this._producers.slice();}
  get totalProduction()    {return this._totalProduction;}
  set totalProduction(arg) {this._totalProduction = arg;}
  get demand()    {return this._demand;}
  set demand(arg) {this._demand = parseInt(arg);}
  get price()    {return this._price;}
  set price(arg) {this._price = parseInt(arg);}
The setters will be called with strings from the UI that contain the numbers, so I need to parse the numbers to use them reliably in calculations.

The producer class is mostly a simple data holder:

class Producer…
  constructor(aProvince, data) {
    this._province = aProvince;
    this._cost = data.cost;
    this._name = data.name;
    this._production = data.production || 0;
  }
  get name() {return this._name;}
  get cost()    {return this._cost;}
  set cost(arg) {this._cost = parseInt(arg);}
  
  get production() {return this._production;}
  set production(amountStr) {
    const amount =  parseInt(amountStr);
    const newProduction = Number.isNaN(amount) ? 0 : amount;
    this._province.totalProduction += newProduction - this._production;
    this._production = newProduction;
  }

The way that set production updates the derived data in the province is ugly, and whenever I see that I want to refactor to remove it. But I have to write tests before that I can refactor it.

The calculation for the shortfall is simple.

class Province…

  get shortfall() {
    return this._demand - this.totalProduction;
  }
That for the profit is a bit more involved.

class Province…

  get profit() {
    return this.demandValue - this.demandCost;
  }
  get demandCost() {
    let remainingDemand = this.demand;
    let result = 0;
    this.producers
      .sort((a,b) => a.cost - b.cost)
      .forEach(p => {
        const contribution = Math.min(remainingDemand, p.production);
          remainingDemand -= contribution;
          result += contribution * p.cost;
      });
    return result;
  }
  get demandValue() {
    return this.satisfiedDemand * this.price;
  }
  get satisfiedDemand() {
    return Math.min(this._demand, this.totalProduction);
  } 