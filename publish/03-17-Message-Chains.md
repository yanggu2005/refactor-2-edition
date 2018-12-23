# Message Chains

You see message chains when a client asks one object for another object, which the client then asks for yet another object, which the client then asks for yet another another object, and so on. You may see these as a long line of getThis methods, or as a sequence of temps. Navigating this way means the client is coupled to the structure of the navigation. Any change to the intermediate relationships causes the client to have to change.

The move to use here is Hide Delegate. You can do this at various points in the chain. In principle, you can do this to every object in the chain, but doing this often turns every intermediate object into a middle man. Often, a better alternative is to see what the resulting object is used for. See whether you can use Extract Function to take a piece of the code that uses it and then Move Function to push it down the chain. If several clients of one of the objects in the chain want to navigate the rest of the way, add a method to do that.

Some people consider any method chain to be a terrible thing. We are known for our calm, reasoned moderation. Well, at least in this case we are.

