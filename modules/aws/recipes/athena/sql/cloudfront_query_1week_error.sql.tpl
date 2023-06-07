select distinct uri, host_header, status, referrer, method, user_agent, request_ip  FROM ${athena_database_name}.${athena_table_name} 
where status >= 400
and status != 403
and date_parse(partition_date, '%Y/%m/%d') between CURRENT_TIMESTAMP - INTERVAL '7' DAY and CURRENT_TIMESTAMP
limit 100;
