#! /bin/bash

IFS=';' read -ra ADDR <<< "$ECS_EXTRA_LOGS"
for i in "${ADDR[@]}"; do
    echo -e "\n\n[${i}.log]\ndatetime_format = %Y-%m-%d %H:%M:%S\nfile = /var/log/${i}.log\nbuffer_duration = 5000\nlog_stream_name = {instance_id}-{hostname}-{ip_address}-${i}.log\ninitial_position = start_of_file\nlog_group_name = ecs" >> awslogs.conf
    echo "if \$syslogfacility-text == 'local6' and \$programname == '$i' then /var/log/${i}-access.log" >> /etc/rsyslog.d/${i}.conf
    echo "if \$syslogfacility-text == 'local6' and \$programname == '$i' then ~" >> /etc/rsyslog.d/${i}.conf
    echo "if \$syslogfacility-text == 'local7' and \$programname == '$i' then /var/log/${i}-error.log" >> /etc/rsyslog.d/${i}.conf
    echo "if \$syslogfacility-text == 'local7' and \$programname == '$i' then ~" >> /etc/rsyslog.d/${i}.conf
done

python ./awslogs-agent-setup.py -n -r us-east-1 -c /awslogs.conf
exec "$@"
