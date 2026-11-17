CREATE OR REPLACE VIEW ${athena_database_name}.view_${athena_table_name} AS
SELECT
detail.eventtype as eventtype
, detail.mail.messageId as mailmessageid
, detail.mail.timestamp as mailtimestamp
, detail.mail.source as mailsource
, detail.mail.sendingAccountId as mailsendingAccountId
, detail.mail.commonHeaders.subject as mailsubject
, detail.mail.tags.ses_configurationset as mailses_configurationset
, detail.mail.tags.ses_source_ip as mailses_source_ip
, detail.mail.tags.ses_from_domain as mailses_from_domain
, detail.mail.tags.ses_outgoing_ip as mailses_outgoing_ip
, detail.delivery.processingtimemillis as deliveryprocessingtimemillis
, detail.delivery.reportingmta as deliveryreportingmta
, detail.delivery.smtpresponse as deliverysmtpresponse
, detail.delivery.timestamp as deliverytimestamp
, detail.delivery.recipients[1] as deliveryrecipient
, detail.open.ipaddress as openipaddress
, detail.open.timestamp as opentimestamp
, detail.open.userAgent as openuseragent
, detail.bounce.bounceType as bouncebounceType
, detail.bounce.bouncesubtype as bouncebouncesubtype
, detail.bounce.feedbackid as bouncefeedbackid
, detail.bounce.timestamp as bouncetimestamp
, detail.bounce.reportingMTA as bouncereportingmta
, detail.click.ipAddress as clickipaddress
, detail.click.timestamp as clicktimestamp
, detail.click.userAgent as clickuseragent
, detail.click.link as clicklink
, detail.complaint.timestamp as complainttimestamp
, detail.complaint.userAgent as complaintuseragent
, detail.complaint.complaintFeedbackType as complaintcomplaintfeedbacktype
, detail.complaint.arrivalDate as complaintarrivaldate
, detail.reject.reason as rejectreason
, partition_date
FROM
${athena_database_name}.${athena_table_name};
