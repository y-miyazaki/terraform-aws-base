CREATE EXTERNAL TABLE IF NOT EXISTS ${athena_database_name}.${athena_table_name} (
    `date` DATE,
    `time` STRING,
    `location` STRING,
    `bytes` BIGINT,
    `request_ip` STRING,
    `method` STRING,
    `host` STRING,
    `uri` STRING,
    `status` INT,
    `referrer` STRING,
    `user_agent` STRING,
    `query_string` STRING,
    `cookie` STRING,
    `result_type` STRING,
    `request_id` STRING,
    `host_header` STRING,
    `request_protocol` STRING,
    `request_bytes` BIGINT,
    `time_taken` FLOAT,
    `xforwarded_for` STRING,
    `ssl_protocol` STRING,
    `ssl_cipher` STRING,
    `response_result_type` STRING,
    `http_version` STRING,
    `fle_status` STRING,
    `fle_encrypted_fields` INT,
    `c_port` INT,
    `time_to_first_byte` FLOAT,
    `x_edge_detailed_result_type` STRING,
    `sc_content_type` STRING,
    `sc_content_len` BIGINT,
    `sc_range_start` BIGINT,
    `sc_range_end` BIGINT
)
PARTITIONED BY
(
    `partition_date` STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
LOCATION '${log_bucket}/'
TBLPROPERTIES (
    "skip.header.line.count" = "2",
    "projection.enabled" = "true",
    "projection.partition_date.type" = "date",
    "projection.partition_date.range" = "2022/01/01,NOW",
    "projection.partition_date.format" = "yyyy/MM/dd",
    "projection.partition_date.interval" = "1",
    "projection.partition_date.interval.unit" = "DAYS",
    "storage.location.template" = "${log_bucket}\$\{partition_date\}"
)
