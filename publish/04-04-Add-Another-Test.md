# Add Another Test

Now I'll continue adding more tests. The style I follow is to look at all the things the class should do and test each one of them for any conditions that might cause the class to fail. This is not the same as testing every public method, which is what some programmers advocate. Testing should be risk-driven; remember, I'm trying to find bugs, now or in the future. Therefore I don’t test accessors that just read and write a field: They are so simple that I’m not likely to find a bug there.

This is important because trying to write too many tests usually leads to not writing enough. I get many benefits from testing even if I do only a little testing. My focus is to test the areas that I'm most worried about going wrong. That way I get the most benefit for my testing effort.

It is better to write and run incomplete tests than not to run complete tests.

So I'll start by hitting the other main output for this code—the profit calculation. Again, I'll just do a basic test for profit on my initial fixture.

describe('province', function() {
  it('shortfall', function() {
    const asia = new Province(sampleProvinceData());
    expect(asia.shortfall).equal(5);
  });
  it('profit', function() {
    const asia = new Province(sampleProvinceData());
    expect(asia.profit).equal(230);
  });
});
That shows the final result, but the way I got it was by first setting the expected value to a placeholder, then replacing it with whatever the program produced (230). I could have calculated it by hand myself, but since the code is supposed to be working correctly, I'll just trust it for now. Once I have that new test working correctly, I break it by altering the profit calculation with a spurious * 2. I satisfy myself that the test fails as it should, then revert my injected fault. This pattern—write with a placeholder for the expected value, replace the placeholder with the code's actual value, inject a fault, revert the fault—is a common one I use when adding tests to existing code.

There is some duplication between these tests—both of them set up the fixture with the same first line. Just as I'm suspicious of duplicated code in regular code, I'm suspicious of it in test code, so will look to remove it by factoring to a common place. One option is to raise the constant to the outer scope.

describe('province', function() {
  const asia = new Province(sampleProvinceData());   // DON'T DO THIS
  it('shortfall', function() {
    expect(asia.shortfall).equal(5);
  });
  it('profit', function() {
    expect(asia.profit).equal(230);
  });
});
But as the comment indicates, I never do this. It will work for the moment, but it introduces a petri dish that's primed for one of the nastiest bugs in testing—a shared fixture which causes tests to interact. The const keyword in JavaScript only means the reference to asia is constant, not the content of that object. Should a future test change that common object, I'll end up with intermittent test failures due to tests interacting through the shared fixture, yielding different results depending on what order the tests are run in. That's a nondeterminism in the tests that can lead to long and difficult debugging at best, and a collapse of confidence in the tests at worst. Instead, I prefer to do this:

describe('province', function() {
  let asia;
  beforeEach(function() {
    asia = new Province(sampleProvinceData());
  });
  it('shortfall', function() {
    expect(asia.shortfall).equal(5);
  });
  it('profit', function() {
    expect(asia.profit).equal(230);
  });
});
The beforeEach clause is run before each test runs, clearing out asia and setting it to a fresh value each time. This way I build a fresh fixture before each test is run, which keeps the tests isolated and prevents the nondeterminism that causes so much trouble.

When I give this advice, some people are concerned that building a fresh fixture every time will slow down the tests. Most of the time, it won't be noticeable. If it is a problem, I'd consider a shared fixture, but then I will need to be really careful that no test ever changes it. I can also use a shared fixture if I'm sure it is truly immutable. But my reflex is to use a fresh fixture because the debugging cost of making a mistake with a shared fixture has bit me too often in the past.

Given I run the setup code in beforeEach with every test, why not leave the setup code inside the individual it blocks? I like my tests to all operate on a common bit of fixture, so I can become familiar with that standard fixture and see the various characteristics to test on it. The presence of the beforeEach block signals to the reader that I'm using a standard fixture. You can then look at all the tests within the scope of that describe block and know they all take the same base data as a starting point.

