# LevAutomata

After gaining [some experiences on finite state automata](https://github.com/EDFward/REAutomata), I'm now prepared to tackle the spell correction problem which I heard from several blog posts ([1](http://julesjacobs.github.io/2015/06/17/disqus-levenshtein-simple-and-fast.html), [2](http://fulmicoton.com/posts/levenshtein/), [3](http://blog.notdot.net/2010/07/Damn-Cool-Algorithms-Levenshtein-Automata)). After scratching my head for days I finally build a functioning toy which looks following:

<img alt="screenshot" src="http://i.imgur.com/wn3kwTp.png" width=300 />

Old friend [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa) handles the input and output stream but that's not my focus.

Disclaimer: The algorithm I implemented is not Levenshtein automata per se, neither as in [the third aforementioned post](http://blog.notdot.net/2010/07/Damn-Cool-Algorithms-Levenshtein-Automata) which I followed along. But that post is the only one which did the whole spell correction pipeline, so my code is essentially a swift-port of the original python one. It is a simplified version of Levenshtein automata - there is no characteristic vectors for example, but only NFA building, DFA conversion and a *zigzag merge join*-like strategy to find potential words in a sorted dictionary.

The NFA/DFA part looks a lot like in what I did in [REAutomata](https://github.com/EDFward/REAutomata). Building NFA itself is straightforward with the help of the following illustration (using *food* as the input word)

![lev](http://lh4.ggpht.com/_23zDbjk-dKI/TFAMHm_FQUI/AAAAAAAABrI/jpf9QkVoZUk/levenstein-nfa-food.png)

For algorithm details please check that post.

One difference is about the types of edges: except normal and epsilon edges, it's necessary to have one of *Any* type (indicated as star in the graph), meaning any valid input character could make that transition. Compiling to DFA is almost the same. The trickiest part is how to use such automata to find the similar words in a dictionary (brute force is not acceptable, as will shown later).

The strategy from that post is trying to find *the lexicographically next string* when a given word doesn't match with our input word. In this way we could dramatically reduce the search space (suppose the dictionary is a sorted list).

> We repeatedly look up a string on one side, and use that to jump to the appropriate place on the other side. If there's no matching entry, we use the result of the lookup to jump ahead on the first side, and so forth. The result is that we skip over large numbers of non-matching index entries, as well as large numbers of non-matching Levenshtein strings, saving us the effort of exhaustively enumerating either of them.

In the post those ~40 line python code took me a long time to understand (and to debug!). My advice is to use a pencil and paper to actually emulate the state transition, which helps a lot in my case, to better understand how it works (such as the problem why we need a stack of three-element tuples).

After implementation, now it's profiling time! Note that I use `/usr/share/dict/web2` as the dictionary, which contains 235886 words. The test is to find all similar words with specified allowed mismatches (Levenshtein distance).

| Input | Allowed mismatch | Time (sec) |
|:-----:|:----------------:|:----------:|
|  hell |         1        |    0.016   |
|  hell |         2        |    0.283   |
|  hell |         3        |    1.800   |

Considering that Levenshtein distances exponentially affect number of states in DFA, the time usage seems reasonable (or not, I'm not sure that's the reason, help wanted).

|     Input     | Allowed mismatch | Strategy             | Time (sec) |
|:-------------:|:----------------:|----------------------|:----------:|
| nicetomeetyou |         2        | zigzag merge join    |    0.538   |
| nicetomeetyou |         2        | brute force with DFA |    2.517   |
| nicetomeetyou |         2        | brute force with NFA |   42.697   |

The zigzag strategy outperforms the brute force ones, which scanned through the whole dictionary and test each of them using either DFA or NFA. Zigzag merge join yields performance in orders of hundreds of milliseconds, however I heard in real Levenshtein automata it should be in milliseconds.

In conclusion, this is a great learning experience for me in several aspects: development flow in Swift and Xcode including testing and profiling, understanding a hardcore computer science problem and solution, so to speak. By the way, the reason I didn't read [the original paper](http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.16.652) is because it's notoriously complicated, so I skipped :)















