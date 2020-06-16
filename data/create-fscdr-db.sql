PRAGMA foreign_keys=OFF;

BEGIN TRANSACTION;

-- DROP TABLE cdr;

CREATE TABLE cdr (
    caller_id_name VARCHAR,
    caller_id_number VARCHAR,
    destination_number VARCHAR,
    start_stamp DATETIME,
    duration INTEGER,
    billsec INTEGER,
    hangup_cause VARCHAR,
    uuid VARCHAR,
    user_id INTEGER,
    callrequest_id INTEGER,
    nibble_total_billed VARCHAR,
    nibble_increment INTEGER,
    amd_result VARCHAR,
    legtype VARCHAR,
    hangup_cause_q850 INTEGER,
    campaign_id INTEGER,
    imported INTEGER DEFAULT 0,
    dialed_user VARCHAR
    CHECK (callrequest_id <> '' and callrequest_id is not null)
);
CREATE INDEX index_cdr_imported ON cdr (imported);

COMMIT;

-- 12 fields removed:
-- context, answer_stamp, end_stamp, bleg_uuid, account_code, start_uepoch, answer_uepoch, used_gateway_id, dialout_phone_number, pg_cdr_id, sip_to_host, sip_local_network_addr
