milqi - MILd Query Interaction
========================================================================================================================
This plugin is under development.

How To Create Your Source
------------------------------------------------------------------------------------------------------------------------
* milqi#source#define()

    Creates a new milqi source object.

    Attributes:

    * name

        The name of milqi-extension.

    * enter(context)

        It is called when entered to milqi buffer.

    * exit(context)

    * accept(context, id)

    * get_abbr(context, id)

    * init(context)

        This attribute is a Funcref, and returns a List of candidates.
        It takes 2 arguments, "args" and "context".
        See [candidate notation](#candidate-notation).

    * lazy_init(context)

        This attribute is a Funcref, and returns a List of candidates.
        This was called only if context.is_async is true.

<a name="candidate-notation">Candidate Notation</a>
------------------------------------------------------------------------------------------------------------------------
A candidate is a Dictionary, it has attributes below:

* id

    It is any data type.
