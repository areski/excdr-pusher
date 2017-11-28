
IDEAS TO FIX THE ERROR ON DEADLOCK
----------------------------------

* [x] try make CDR insert faster by removing redundant info fields

    [x] remove from callrequest ->
        - last_attempt_time
        - created_date
        - timeout
        - timelimit
        - extra_dial_string
        - extra_data
        - callerid
        - caller_name
        - phone_number

    [x] replace callid, it should use UUID which is optimized for psql (size & index)

    [x] remove from dialer_cdr
        - used_gateway is not needed now
        - hangup_cause (we can use only hangup_cause_q850)


* [x] split trigger and insert CDRs, make it in different transaction,
  if the trigger fail is not such a big deal, we only lose the retry


* benchmark the insert only vs the insert with Trigger

    -- with trigger: 20-25ms for 10 insert - on laptop
    -- without trigger: 10-15ms for 10 insert - on laptop


* [x] use PLPGSQL where we can instead of Pllua

    -- with trigger pllua: 110ms for 100 inserts - on laptop
    -- with trigger plpgsql: 70ms for 100 inserts - on laptop (save 40ms)

  once we moved the dialer_cdr aggregate function too:

    -- with trigger plpgsql: 35ms for 100 inserts - on laptop


* excdr-pusher: track the import as done originally but implement a sqlite counter,
  it would be slower but that should be ok as the load would be on the slave servers.
  if 3 attempts to import fail, we dismiss them


* maybe delay the CDR trigger process with a job?
