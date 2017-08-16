.. :changelog:

History
-------


0.7.0 - (2017-07-25)
--------------------

* [fix](cdr) split the insert and the function plpgsql call


0.6.0 - (2017-07-25)
--------------------

* [fix](cdr) refactor remove fields hangup_cause, used_gateway_id from CDR


0.5.0 - (2017-07-18)
--------------------

* [fix](cdr) get rid of disposition field in dialer_cdr
* smaller changes: improve test suits, add pool_size, etc...


0.4.2 - (2017-07-18)
--------------------

Last version working with disposition

* adding credo, clean-up code base, fix tests
* add pool_size for ecto
