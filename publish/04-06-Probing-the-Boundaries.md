# Probing the Boundaries

So far my tests have focused on regular usage, often referred to as "happy path" conditions where everything is going OK and things are used as expected. But it's also good to throw tests at the boundaries of these conditions—to see what happens when things might go wrong.

Whenever I have a collection of something, such as producers in this example, I like to see what happens when it's empty.

describe('no producers', function() {
  let noProducers;
  beforeEach(function() {
    const data = {
      name: "No proudcers",
      producers: [],
      demand: 30,
      price: 20
    };
    noProducers = new Province(data);
  });
  it('shortfall', function() {
    expect(noProducers.shortfall).equal(30);
  });
  it('profit', function() {
    expect(noProducers.profit).equal(0);
  });
With numbers, zeros are good things to probe:

describe('province'…

  it('zero demand', function() {
    asia.demand = 0;
      expect(asia.shortfall).equal(-25);
      expect(asia.profit).equal(0);
  });
as are negatives:

describe('province'…

  it('negative demand', function() {
    asia.demand = -1;
    expect(asia.shortfall).equal(-26);
    expect(asia.profit).equal(-10);
  });
At this point, I may start to wonder if a negative demand resulting in a negative profit really makes any sense for the domain. Shouldn't the minimum demand be zero? In which case, perhaps, the setter should react differently to a negative argument—raising an error or setting the value to zero anyway. These are good questions to ask, and writing tests like this helps me think about how the code ought to react to boundary cases.

Think of the boundary conditions under which things might go wrong and concentrate your tests there.

The setters take a string from the fields in the UI, which are constrained to only accept numbers—but they can still be blank, so I should have tests that ensure the code responds to the blanks the way I want it to.

describe('province'…

  it('empty string demand', function() {
    asia.demand = "";
    expect(asia.shortfall).NaN;
    expect(asia.profit).NaN;
  });
Notice how I’m playing the part of an enemy to my code. I’m actively thinking about how I can break it. I find that state of mind to be both productive and fun. It indulges the mean-spirited part of my psyche.

This one is interesting:

describe('string for producers', function() {
  it('', function() {
    const data = {
      name: "String producers",
      producers: "",
      demand: 30,
      price: 20
    };
    const prov = new Province(data);
    expect(prov.shortfall).equal(0);
  });
This doesn't produce a simple failure reporting that the shortfall isn't 0. Here's the console output:

․․․․․․․․․!

  9 passing (74ms)
  1 failing

  1) string for producers :
     TypeError: doc.producers.forEach is not a function
      at new Province (src/main.js:22:19)
      at Context.<anonymous> (src/tester.js:86:18)
Mocha treats this as a failure—but many testing frameworks distinguish between this situation, which they call an error, and a regular failure. A failure indicates a verify step where the actual value is outside the bounds expected by the verify statement. But this error is a different animal—it's an exception raised during an earlier phase (in this case, the setup). This looks like an exception that the authors of the code hadn't anticipated, so we get an error sadly familiar to JavaScript programmers ("… is not a function").

How should the code respond to such a case? One approach is to add some handling that would give a better error response—either raising a more meaningful error message, or just setting producers to an empty array (with perhaps a log message). But there may also be valid reasons to leave it as it is. Perhaps the input object is produced by a trusted source—such as another part of the same code base. Putting in lots of validation checks between modules in the same code base can result in duplicate checks that cause more trouble than they are worth, especially if they duplicate validation done elsewhere. But if that input object is coming in from an external source, such as a JSON-encoded request, then validation checks are needed, and should be tested. In either case, writing tests like this raises these kinds of questions.

If I'm writing tests like this before refactoring, I would probably discard this test. Refactoring should preserve observable behavior; an error like this is outside the bounds of observable, so I need not be concerned if my refactoring changes the code's response to this condition.

If this error could lead to bad data running around the program, causing a failure that will be hard to debug, I might use Introduce Assertion to fail fast. I don't add tests to catch such assertion failures, as they are themselves a form of test.

Don’t let the fear that testing can’t catch all bugs stop you from writing tests that catch most bugs.

When do you stop? I’m sure you have heard many times that you cannot prove that a program has no bugs by testing. That’s true, but it does not affect the ability of testing to speed up programming. I’ve seen various proposed rules to ensure you have tested every combination of everything. It’s worth taking a look at these—but don’t let them get to you. There is a law of diminishing returns in testing, and there is the danger that by trying to write too many tests you become discouraged and end up not writing any. You should concentrate on where the risk is. Look at the code and see where it becomes complex. Look at a function and consider the likely areas of error. Your tests will not find every bug, but as you refactor, you will understand the program better and thus find more bugs. Although I always start refactoring with a test suite, I invariably add to it as I go along.

