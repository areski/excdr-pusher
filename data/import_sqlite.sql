PRAGMA foreign_keys=OFF;

BEGIN TRANSACTION;

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
    user_id INTEGER,
    used_gateway_id INTEGER,
    callrequest_id INTEGER,
    nibble_total_billed VARCHAR,
    nibble_increment INTEGER,
    dialout_phone_number VARCHAR,
    amd_status VARCHAR,
    legtype VARCHAR,
    hangup_cause_q850 INTEGER,
    job_uuid VARCHAR);

INSERT INTO "cdr" VALUES('Outbound Call','246142691889264','246142691889264','default','2016-09-09 13:19:49','2016-09-09 13:19:49','2016-09-09 13:20:06',17,17,'NORMAL_CLEARING','59d88d1a-39ab-4bfe-9219-3bce6fb01590','','',1,1,1597,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "cdr" VALUES('Outbound Call','246142691889264','246142691889264','default','2016-09-09 16:40:59','2016-09-09 16:40:59','2016-09-09 16:41:16',17,17,'NORMAL_CLEARING','4ca0cb3c-9064-4a2d-9d0d-af128dbe3abc','','',1,1,1597,'','','246142691889264@82.69.182.244','','',16,'');
INSERT INTO "cdr" VALUES('Outbound Call','246142691889264','246142691889264','default','2016-09-09 17:05:32','2016-09-09 17:05:32','2016-09-09 17:05:50',18,18,'NORMAL_CLEARING','7ed526f0-7442-4aa4-b36e-6e9d852e7bbe','','',1,1,1597,'','','246142691889264@82.69.182.244','','aleg',16,'');
INSERT INTO "cdr" VALUES('','516584646','246142691889264','default','2016-09-12 09:32:56','','2016-09-12 09:33:28',32,0,'RECOVERY_ON_TIMER_EXPIRE','2c2d2cc1-b8eb-4da0-abcc-c78e14e699e1','','',1,1,1597,'','','246142691889264@82.69.182.244','','aleg',102,'');
INSERT INTO "cdr" VALUES('','516584646','246142691889264','default','2016-09-12 09:33:52','','2016-09-12 09:34:24',32,0,'RECOVERY_ON_TIMER_EXPIRE','563e3372-7c45-40fc-8053-f0d68b392b5a','','',1,1,1597,'','','246142691889264@82.69.182.244','','aleg',102,'');
INSERT INTO "cdr" VALUES('','516584646','123','default','2016-09-12 09:35:10','','2016-09-12 09:35:42',32,0,'RECOVERY_ON_TIMER_EXPIRE','dfd3e018-d6c6-4e66-afe3-6ba0356c0859','','',1,1,1597,'','','246142691889264@82.69.182.244','','aleg',102,'');
COMMIT;
