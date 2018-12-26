# Modifying the Fixture

So far, the tests I've written show how I probe the properties of the fixture once I've loaded it. But in use, that fixture will be regularly updated by the users as they change values.

Most of the updates are simple setters, and I don't usually bother to test those as there's little chance they will be the source of a bug. But there is some complicated behavior around Producer's production setter, so I think that's worth a test.

describe('province'…

  it('change production', function() {
      asia.producers[0].production = 20;
      expect(asia.shortfall).equal(-6);
      expect(asia.profit).equal(292);
  });
This is a common pattern. I take the initial standard fixture that's set up by the beforeEach block, I exercise that fixture for the test, then I verify the fixture has done what I think it should have done. If you read much about testing, you'll hear these phases described variously as setup-exercise-verify, given-when-then, or arrange-act-assert. Sometimes you'll see all the steps present within the test itself, in other cases the common early phases can be pushed out into standard setup routines such as beforeEach.

(There is an implicit fourth phase that's usually not mentioned: teardown. Teardown removes the fixture between tests so that different tests don't interact with each other. By doing all my setup in beforeEach, I allow the test framework to implicitly tear down my fixture between tests, so I can take the teardown phase for granted. Most writers on tests gloss over teardown—reasonably so, since most of the time we ignore it. But occasionally, it can be important to have an explicit teardown operation, particularly if we have a fixture that we have to share between tests because it's slow to create.)

In this test, I'm verifying two different characteristics in a single it clause. As a general rule, it's wise to have only a single verify statement in each it clause. This is because the test will fail on the first verification failure—which can often hide useful information when you're figuring out why a test is broken. In this case, I feel the two are closely enough connected that I'm happy to have them in the same test. Should I wish to separate them into separate it clauses, I can do that later.

