
## rvw-legacy

(Legacy) R interface to [Vowpal Wabbit](https://github.com/JohnLangford/vowpal_wabbit/wiki)


### What is Vowpal Wabbit?

[Vowpal Wabbit](https://github.com/JohnLangford/vowpal_wabbit/wiki) is a fast
on-line learner built by [John Langford](http://hunch.net/~jl/) and others,
initially at Yahoo! Research and now at Microsoft Research


### What does _rvw-legacy_ do?

This _rvw-legacy_ package builds upon the
[skeleton r.vw package](https://github.com/JohnLangford/vowpal_wabbit/tree/master/R/r.vw)
in the [Vowpal Wabbit](https://github.com/JohnLangford/vowpal_wabbit/wiki)
sources. It has streamlined the packaging and added a few things here and
there.

The newer [rvw](https://github.com/rvw-org/rvw) package offers a fresher and more powerful
approach leveraging the Vowpal Wabbit _library_ rather than calling the _binary_.


### Requirements

You will need the `vw` binary in your path.  On Debian / Ubuntu systems to

```sh
sudo apt-get install vowpal-wabbiit
```

On other systems follow the
[Vowpal Wabbit instructions](https://github.com/JohnLangford/vowpal_wabbit/blob/master/README.md).


### Examples

Several demos are included in the `demo/` directory and accessible (once installed) via the `demo()` function.  Here
are tow figures from `demo/vw_example_4.r` which revisits the Titanic dataset.

![](https://raw.githubusercontent.com/eddelbuettel/rvw/master/inst/images/roc_curves.png)

![](https://raw.githubusercontent.com/eddelbuettel/rvw/master/inst/images/confusion_matrices.png)

### Status

Now mostly dormant as [rvw](https://github.com/rvw-org/rvw) offers a fresher approach.


### What about [RVowpalWabbit](https://github.com/eddelbuettel/rvowpalwabbit) ?

Also legacy just like _rvw-legacy_.


### Author

The
[r.vw package](https://github.com/JohnLangford/vowpal_wabbit/tree/master/R/r.vw)
was written by [Selim Raboudi](https://github.com/SelimRaboudi).

_rvw-legacy_ was being written by Dirk Eddelbuettel


### License

[r.vw](https://github.com/JohnLangford/vowpal_wabbit/tree/master/R/r.vw)
is released under the ("revised" or "new" or "3-clause") BSD; the _rvw_
package and its additions by Dirk Eddelbuettel are under the GPL (>= 2) just
like R. 
