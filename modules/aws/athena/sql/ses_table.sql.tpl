CREATE EXTERNAL TABLE IF NOT EXISTS ${athena_database_name}.${athena_table_name} (

eventType string,

complaint struct<arrivaldate:string,
complainedrecipients:array<struct<emailaddress:string>>,
complaintfeedbacktype:string,
feedbackid:string,
`timestamp`:string,
useragent:string>,

bounce struct<bouncedrecipients:array<struct<action:string,
diagnosticcode:string,
emailaddress:string,
status:string>>,
bouncesubtype:string,
bouncetype:string,
feedbackid:string,
reportingmta:string,
`timestamp`:string>,

mail struct<`timestamp`:string,
source:string,
sourceArn:string,
sendingAccountId:string,
messageId:string,
destination:string,
headersTruncated:boolean,
headers:array<struct<name:string,
value:string>>,
commonHeaders:struct<`from`:array<string>,
to:array<string>,
messageId:string,
subject:string>,
tags:struct<ses_configurationset:string,
ses_source_ip:string,
ses_outgoing_ip:string,
ses_from_domain:string,
ses_caller_identity:string> >,

send string,

delivery struct<processingtimemillis:int,
recipients:array<string>,
reportingmta:string,
smtpresponse:string,
`timestamp`:string>,

open struct<ipaddress:string,
`timestamp`:string,
userAgent:string>,

reject struct<reason:string>,

click struct<ipAddress:string,
`timestamp`:string,
userAgent:string,
link:string>
)
PARTITIONED BY
(
    `partition_date` STRING
)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
WITH SERDEPROPERTIES (
    "mapping.ses_configurationset" = "ses:configuration-set",
    "mapping.ses_source_ip" = "ses:source-ip",
    "mapping.ses_from_domain" = "ses:from-domain",
    "mapping.ses_caller_identity" = "ses:caller-identity",
    "mapping.ses_outgoing_ip" = "ses:outgoing-ip"
)
LOCATION '${log_bucket}'
TBLPROPERTIES (
    "skip.header.line.count" = "0",
    "projection.enabled" = "true",
    "projection.partition_date.type" = "date",
    "projection.partition_date.range" = "2022/01/01/00,NOW",
    "projection.partition_date.format" = "yyyy/MM/dd/HH",
    "projection.partition_date.interval" = "1",
    "projection.partition_date.interval.unit" = "HOURS",
    "storage.location.template" = "${log_bucket}\$\{partition_date\}"
)
