
newfies_dialer_db=# \d dialer_cdr
                                       Table "public.dialer_cdr"
      Column       |           Type           |                        Modifiers
-------------------+--------------------------+---------------------------------------------------------
 id                | integer                  | not null default nextval('dialer_cdr_id_seq'::regclass)
 request_uuid      | character varying(120)   |
 callid            | character varying(120)   | not null
 callerid          | character varying(120)   | not null
 phone_number      | character varying(120)   |
 starting_date     | timestamp with time zone | not null
 duration          | integer                  |
 billsec           | integer                  |
 -- hangup_cause      | character varying(40)    |
 hangup_cause_q850 | character varying(10)    |
 leg_type          | smallint                 |
 amd_status        | smallint                 |
 callrequest_id    | integer                  |
 -- used_gateway_id   | integer                  |
 user_id           | integer                  | not null
 billed_duration   | integer                  | not null
 call_cost         | numeric(10,5)            | not null
 campaign_id       | integer                  |

Indexes:
    "dialer_cdr_pkey" PRIMARY KEY, btree (id)
    "dialer_cdr_11a584c4" btree (starting_date)
    "dialer_cdr_e8701ad4" btree (user_id)
    "dialer_cdr_f14acec3" btree (campaign_id)
Foreign-key constraints:
    "dialer_cdr_user_id_e0635e5e_fk_auth_user_id" FOREIGN KEY (user_id) REFERENCES auth_user(id) DEFERRABLE INITIALLY DEFERRED

--------------------------------------------------------------------------

newfies_dialer_db=# SELECT * FROM dialer_cdr ORDER BY id dESC LIMIT 2;
-[ RECORD 1 ]-----+-------------------------------------
id                | 1706
request_uuid      |
callid            | 8f2bf043-8ed7-4b09-ad86-3e96e0f00b86
callerid          | 11111111111
phone_number      | 0034650784355
starting_date     | 2016-09-20 06:38:09.87433-04
duration          | 6
billsec           | 0
hangup_cause_q850 |
leg_type          | 1
amd_status        | 1
user_id           | 1
billed_duration   | 0
call_cost         | 0.00000
campaign_id       | 1
-[ RECORD 2 ]-----+-------------------------------------
id                | 1705
request_uuid      |
callid            | b470258f-c40b-47ce-8b93-f02872bc011c
callerid          | 11111111111
phone_number      | 0034650784355
starting_date     | 2016-09-20 06:38:25.234323-04
duration          | 5
billsec           | 0
hangup_cause_q850 |
leg_type          | 1
amd_status        | 1
user_id           | 1
billed_duration   | 0
call_cost         | 0.00000
campaign_id       | 1
-[ RECORD 4 ]-----+-------------------------------------
id                | 1703
request_uuid      |
callid            | 039ac1d3-aedd-4d3a-9eb1-2972f1db9141
callerid          | 0034650784355
phone_number      | 246142691889264@82.69.182.244
starting_date     | 2016-09-20 06:20:13.794359-04
duration          | 0
billsec           | 0
hangup_cause_q850 |
leg_type          | 2
amd_status        | 1
user_id           | 1
billed_duration   | 0
call_cost         | 0.00000
campaign_id       | 1
-[ RECORD 5 ]-----+-------------------------------------
id                | 1702
request_uuid      |
callid            | 039ac1d3-aedd-4d3a-9eb1-2972f1db9141
callerid          | 11111111111
phone_number      | 0034650784355
starting_date     | 2016-09-20 06:19:52.414324-04
duration          | 21
billsec           | 12
hangup_cause_q850 |
leg_type          | 1
amd_status        | 1
user_id           | 1
billed_duration   | 12
call_cost         | 0.00000
campaign_id       | 1
