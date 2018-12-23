# Middle Man

One of the prime features of objects is encapsulation—hiding internal details from the rest of the world. Encapsulation often comes with delegation. You ask a director whether she is free for a meeting; she delegates the message to her diary and gives you an answer. All well and good. There is no need to know whether the director uses a diary, an electronic gizmo, or a secretary to keep track of her appointments.

c However, this can go too far. You look at a class’s interface and find half the methods are delegating to this other class. After a while, it is time to use Remove Middle Man and talk to the object that really knows what’s going on. If only a few methods aren’t doing much, use Inline Function to inline them into the caller. If there is additional behavior, you can use Replace Superclass with Delegate or Replace Subclass with Delegate to fold the middle man into the real object. That allows you to extend behavior without chasing all that delegation.

