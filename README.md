milqi - MILd Query Interaction
========================================================================================================================
This plugin is under development.

How To Create Your Source
------------------------------------------------------------------------------------------------------------------------
* Create your milqi-extension definition

    The definition is just a Dictionary.

    Common required attributes:

    * name

        The name of milqi-extension.

    * init(context)

        This attribute is a Funcref, and returns a List.

        See [candidate notation](#candidate-notation).

    Required attributes if it's candidate first:

    * enter(context)

        It is called when entered to milqi buffer.

    * exit(context)

    * accept(context, id)

    * get_abbr(context, id)

    * lazy_init(context, query)

        This attribute is a Funcref, and returns a Dictionary which has 2 attributes.

            reset - 1/0
            candidates - []

        This was called only if context.is_async is true.

    * async_init(context)

        This attribute is a Funcref, and returns a Dictionary which has 2 attributes.

            done - 1/0
            candidates - []

Interaction mode
------------------------------------------------------------------------------------------------------------------------
* query-first

    init() and lazy_init()

* candidate-first

    init() and async_init()

<a name="candidate-notation">Candidate Notation</a>
------------------------------------------------------------------------------------------------------------------------
A candidate is a Dictionary, it has attributes below:

* id

    It is any data type.

<a name="context-notation">Context Notation</a>
------------------------------------------------------------------------------------------------------------------------
A context is a Dictionary, it has no attributes.
