PRAGMA foreign_keys=OFF;

BEGIN TRANSACTION;

DROP TABLE cdr;

CREATE TABLE cdr (
    caller_id_name VARCHAR,
    caller_id_number VARCHAR,
    destination_number VARCHAR,
    context VARCHAR,
    start_stamp DATETIME,
    answer_stamp DATETIME,
    end_stamp DATETIME,
    duration INTEGER,
    billsec INTEGER,
    hangup_cause VARCHAR,
    uuid VARCHAR,
    bleg_uuid VARCHAR,
    account_code VARCHAR,
    used_gateway_id INTEGER,
    callrequest_id INTEGER,
    nibble_total_billed VARCHAR,
    nibble_increment INTEGER,
    dialout_phone_number VARCHAR,
    amd_result VARCHAR,
    legtype VARCHAR,
    hangup_cause_q850 INTEGER,
    campaign_id INTEGER,
    job_uuid VARCHAR,
    imported INTEGER DEFAULT 0,
    pg_cdr_id INTEGER DEFAULT 0);


INSERT INTO "cdr" VALUES('0034650780000','0034650780000','246142691889264','default','2016-09-20 06:20:13','','2016-09-20 06:20:13',0,0,'NORMAL_TEMPORARY_FAILURE','1b16c95a-bab7-43b5-a219-01bc35d56bc4','','acc',1,1681,'','','246142691889264@127.0.0.1','','2',41, 1, '', 0, 0);

INSERT INTO "cdr" VALUES('Outbound Call','0034650780000','0034650780000','default','2016-09-20 06:19:52','2016-09-20 06:20:01','2016-09-20 06:20:13',21,12,'NORMAL_TEMPORARY_FAILURE','039ac1d3-aedd-4d3a-9eb1-2972f1db9141','','acc',1,1681,'','','0034650780000','','1',41, 1, '', 0, 0);

INSERT INTO "cdr" VALUES('Outbound Call','11111111111','0034650780000','default','2016-09-20 06:36:48','','2016-09-20 06:37:04',16, 1, 'USER_BUSY','58a2a8b9-469a-456b-afd9-5698a2fdfb24','','',1,1681,'','','0034650780000','','1',17, 1, '', 0, 0);

-- Good call
INSERT INTO "cdr" VALUES('Outbound Call','0034650780000','0034650780000','default','2016-09-20 10:11:43','2016-09-20 10:11:55','2016-09-20 10:12:05',22,10,'NORMAL_CLEARING','205e9f2f-c83d-4ba5-bc5b-cb7b7a7562e5','','',1,1681,'','','0034650780000','PERSON','1',16, 1, '', 0, 0);

-- Billed call
INSERT INTO "cdr" VALUES('Outbound Call','0034650780000','0034650780000','default','2016-09-20 10:14:37','2016-09-20 10:14:48','2016-09-20 10:15:00',23,12,'NORMAL_CLEARING','eb43ce0a-bd20-46aa-ba14-9a22d6d0193c','','',1,1681,'0.020000',6,'0034650780000','MACHINE','1',16, 1, '', 0, 0);

--
--  extra 5 (copied from above)
--
INSERT INTO "cdr" VALUES('0034650780000','0034650780000','246142691889264','default','2016-09-20 06:20:13','','2016-09-20 06:20:13',0,0,'NORMAL_TEMPORARY_FAILURE','1b16c95a-bab7-43b5-a219-01bc35d56bc4','','acc',1,1681,'','','246142691889264@127.0.0.1','','2',41, 1, '', 0, 0);
INSERT INTO "cdr" VALUES('Outbound Call','0034650780000','0034650780000','default','2016-09-20 06:19:52','2016-09-20 06:20:01','2016-09-20 06:20:13',21,12,'NORMAL_TEMPORARY_FAILURE','039ac1d3-aedd-4d3a-9eb1-2972f1db9141','','acc',1,1681,'','','0034650780000','','1',41, 1, '', 0, 0);
INSERT INTO "cdr" VALUES('Outbound Call','11111111111','0034650780000','default','2016-09-20 06:36:48','','2016-09-20 06:37:04',16, 1, 'USER_BUSY','58a2a8b9-469a-456b-afd9-5698a2fdfb24','','',1,1681,'','','0034650780000','','1',17, 1, '', 0, 0);

INSERT INTO "cdr" VALUES('Outbound Call','0034650780000','0034650780000','default','2016-09-20 10:11:43','2016-09-20 10:11:55','2016-09-20 10:12:05',22,10,'NORMAL_CLEARING','205e9f2f-c83d-4ba5-bc5b-cb7b7a7562e5','','',1,1681,'','','0034650780000','PERSON','1',16, 1, '', 0, 0);
INSERT INTO "cdr" VALUES('Outbound Call','0034650780000','0034650780000','default','2016-09-20 10:14:37','2016-09-20 10:14:48','2016-09-20 10:15:00',23,12,'NORMAL_CLEARING','eb43ce0a-bd20-46aa-ba14-9a22d6d0193c','','',1,1681,'0.020000',6,'0034650780000','MACHINE','1',16, 1, '', 0, 0);


-- ALTER TABLE cdr ADD COLUMN sip_to_host VARCHAR;
-- ALTER TABLE cdr ADD COLUMN sip_local_network_addr VARCHAR;

COMMIT;
