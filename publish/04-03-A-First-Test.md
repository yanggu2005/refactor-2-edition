# A First Test

To test this code, I'll need some sort of testing framework. There are many out there, even just for JavaScript. The one I'll use is Mocha, which is reasonably common and well-regarded. I won't go into a full explanation of how to use the framework, just show some example tests with it. You should be able to adapt, easily enough, a different framework to build similar tests.

Here is a simple test for the shortfall calculation:

describe('province', function() {
  it('shortfall', function() {
    const asia = new Province(sampleProvinceData());
    assert.equal(asia.shortfall, 5);
  });
});
The Mocha framework divides up the test code into blocks, each grouping together a suite of tests. Each test appears in an it block. For this simple case, the test has two steps. The first step sets up some fixture—data and objects that are needed for the test: in this case, a loaded province object. The second line verifies some characteristic of that fixture—in this case, that the shortfall is the amount that should be expected given the initial data.

Different developers use the descriptive strings in the describe and it blocks differently. Some would write a sentence that explains what the test is testing, but others prefer to leave them empty, arguing that the descriptive sentence is just duplicating the code in the same way a comment does. I like to put in just enough to identify which test is which when I get failures.

If I run this test in a NodeJS console, the output looks like this:

․․․․․․․․․․․․․․

  1 passing (61ms)
Note the simplicity of the feedback—just a summary of how many tests are run and how many have passed.

Always make sure a test will fail when it should.

When I write a test against existing code like this, it's nice to see that all is well—but I'm naturally skeptical. Particularly, once I have a lot of tests running, I'm always nervous that a test isn't really exercising the code the way I think it is, and thus won't catch a bug when I need it to. So I like to see every test fail at least once when I write it. My favorite way of doing that is to temporarily inject a fault into the code, for example:

class Province…

  get shortfall() {
    return this._demand - this.totalProduction * 2;
  }
Here's what the console now looks like:

!

  0 passing (72ms)
  1 failing

  1) province shortfall:
     AssertionError: expected -20 to equal 5
      at Context.<anonymous> (src/tester.js:10:12)
The framework indicates which test failed and gives some information about the nature of the failure—in this case, what value was expected and what value actually turned up. I therefore notice at once that something failed—and I can immediately see which tests failed, giving me a clue as to what went wrong (and, in this case, confirming the failure was where I injected it).

Run tests frequently. Run those exercising the code you're working on at least every few minutes; run all tests at least daily.

In a real system, I might have thousands of tests. A good test framework allows me to run them easily and to quickly see if any have failed. This simple feedback is essential to self-testing code. When I work, I'll be running tests very frequently—checking progress with new code or checking for mistakes with refactoring.

The Mocha framework can use different libraries, which it calls assertion libraries, to verify the fixture for a test. Being JavaScript, there are a quadzillion of them out there, some of which may still be current when you're reading this. The one I'm using at the moment is Chai. Chai allows me to write my validations either using an "assert" style:

describe('province', function() {
  it('shortfall', function() {
    const asia = new Province(sampleProvinceData());
    assert.equal(asia.shortfall, 5);
  });
});
or an "expect" style:

describe('province', function() {
  it('shortfall', function() {
    const asia = new Province(sampleProvinceData());
    expect(asia.shortfall).equal(5);
  });
});
I usually prefer the assert style, but at the moment I mostly use the expect style while working in JavaScript.

Different environments provide different ways to run tests. When I'm programming in Java, I use an IDE that gives me a graphical test runner. Its progress bar is green as long as all the tests pass, and turns red should any of them fail. My colleagues often use the phrases "green bar" and "red bar" to describe the state of tests. I might say, "Never refactor on a red bar," meaning you shouldn't be refactoring if your test suite has a failing test. Or, I might say, "Revert to green" to say you should undo recent changes and go back to the last state where you had all-passing test suite (usually by going back to a recent version-control checkpoint).

Graphical test runners are nice, but not essential. I usually have my tests set to run from a single key in Emacs, and observe the text feedback in my compilation window. The key point is that I can quickly see if my tests are all OK.

