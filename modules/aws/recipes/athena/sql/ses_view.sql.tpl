CREATE OR REPLACE VIEW ${athena_database_name}.view_${athena_table_name} AS
SELECT
eventtype as eventtype
, mail.messageId as mailmessageid
, mail.timestamp as mailtimestamp
, mail.source as mailsource
, mail.sendingAccountId as mailsendingAccountId
, mail.commonHeaders.subject as mailsubject
, mail.tags.ses_configurationset as mailses_configurationset
, mail.tags.ses_source_ip as mailses_source_ip
, mail.tags.ses_from_domain as mailses_from_domain
, mail.tags.ses_outgoing_ip as mailses_outgoing_ip
, delivery.processingtimemillis as deliveryprocessingtimemillis
, delivery.reportingmta as deliveryreportingmta
, delivery.smtpresponse as deliverysmtpresponse
, delivery.timestamp as deliverytimestamp
, delivery.recipients[1] as deliveryrecipient
, open.ipaddress as openipaddress
, open.timestamp as opentimestamp
, open.userAgent as openuseragent
, bounce.bounceType as bouncebounceType
, bounce.bouncesubtype as bouncebouncesubtype
, bounce.feedbackid as bouncefeedbackid
, bounce.timestamp as bouncetimestamp
, bounce.reportingMTA as bouncereportingmta
, click.ipAddress as clickipaddress
, click.timestamp as clicktimestamp
, click.userAgent as clickuseragent
, click.link as clicklink
, complaint.timestamp as complainttimestamp
, complaint.userAgent as complaintuseragent
, complaint.complaintFeedbackType as complaintcomplaintfeedbacktype
, complaint.arrivalDate as complaintarrivaldate
, reject.reason as rejectreason
, partition_date
FROM
${athena_database_name}.${athena_table_name};
