milqi - MILd Query Interaction
========================================================================================================================
This plugin is under development.


Abstract
------------------------------------------------------------------------------------------------------------------------
milqi has 2 modes, query-first and candidate-first.
milqi is inspired [ctrlp](kien/ctrlp.vim) and [unite](Shougo/unite.vim).

How To Create Your Extension
------------------------------------------------------------------------------------------------------------------------
* Create your milqi-extension definition

    The definition is just a Dictionary.

    * name - Required

        The name of milqi-extension.

    * init(context) - Required

        This attribute is a Funcref, and returns a List.

        See [candidate notation](#candidate-notation).

    * exit(context)

    * accept(context, candidate) - Required

    * get_abbr(context, candidate)

    * lazy_init(context, query) - Optional for query-first mode

        This attribute is a Funcref, and returns a Dictionary which has attributes below:

            * reset - 1/0
            * candidates - []

    * async_init(context) - Optional for candidate-first mode

        This attribute is a Funcref, and returns a Dictionary which has attributes below:

            * done - 1/0
            * candidates - []

Interaction mode
------------------------------------------------------------------------------------------------------------------------
* query-first

    init() and lazy_init()

* candidate-first

    init() and async_init()


<a name="context-notation">Context Notation</a>
------------------------------------------------------------------------------------------------------------------------
A context is a Dictionary, it has no attributes.
You can use this Dictionary for any-purpose.
