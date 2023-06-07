select * from ${athena_database_name}.view_${athena_table_name}
where eventtype='Bounce'
and date_parse(partition_date, '%Y/%m/%d/%H') between CURRENT_TIMESTAMP - INTERVAL '7' DAY and CURRENT_TIMESTAMP
limit 100;
