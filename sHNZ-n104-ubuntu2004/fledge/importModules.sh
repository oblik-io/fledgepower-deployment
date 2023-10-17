#!/bin/bash

# Constants
s1_south_service_name="hnzsouth_s1"
s2_south_service_name="hnzsouth_s2"
s1_south_service_name_advanced="${s1_south_service_name}Advanced"
s2_south_service_name_advanced="${s2_south_service_name}Advanced"

n1_north_service_name="iec104north_c1"
n2_north_service_name="iec104north_c2"

snmp_north_service_name="auditsnmpnorth"

plugin_1="iec104_pivot_filter"
plugin_2="transientsp"
plugin_3="hnz_pivot_filter"
plugin_4="mvscale"

name_service_notif="notif"
notif_plugin_1="systemspr"
notif_plugin_2="systemspn"
notif_name_1='systemsp'

# Create service south
curl -sX POST http://localhost:8081/fledge/service -d '{"name":"'$s1_south_service_name'","type":"south","plugin":"hnz","enabled":false}'
curl -sX POST http://localhost:8081/fledge/service -d '{"name":"'$s2_south_service_name'","type":"south","plugin":"hnz","enabled":false}'

# Create service north
curl -sX POST http://localhost:8081/fledge/service -d '{"name":"'$n1_north_service_name'","type":"north","plugin":"iec104","enabled":false}'
curl -sX POST http://localhost:8081/fledge/service -d '{"name":"'$n2_north_service_name'","type":"north","plugin":"iec104","enabled":false}'
curl -sX POST http://localhost:8081/fledge/service -d '{"name":"'$snmp_north_service_name'","type":"north","plugin":"auditsnmp","enabled":false}'

# Create service notification
curl -sX POST http://localhost:8081/fledge/service -d '{"name":"'$name_service_notif'","type":"notification","enabled":true}'

# Create plugins
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$plugin_1'", "plugin": "'$plugin_1'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$plugin_2'", "plugin": "'$plugin_2'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$plugin_3'", "plugin": "'$plugin_3'"}'
curl -X POST http://localhost:8081/fledge/filter -d '{"name": "'$plugin_4'", "plugin": "'$plugin_4'"}'

# Create of south pipelines
curl -X PUT http://localhost:8081/fledge/filter/$s1_south_service_name/pipeline -d  '{"pipeline": ["'$plugin_3'", "'$plugin_2'", "'$plugin_4'"]}'
curl -X PUT http://localhost:8081/fledge/filter/$s2_south_service_name/pipeline -d  '{"pipeline": ["'$plugin_3'", "'$plugin_2'", "'$plugin_4'"]}'

# Create of north pipelines
curl -X PUT http://localhost:8081/fledge/filter/$n1_north_service_name/pipeline -d  '{"pipeline": ["'$plugin_1'"]}'
curl -X PUT http://localhost:8081/fledge/filter/$n2_north_service_name/pipeline -d  '{"pipeline": ["'$plugin_1'"]}'

# Param advanced south
sleep 5
curl -X PUT --data '{"maxSendLatency":"100"}' http://localhost:8081/fledge/category/$s1_south_service_name_advanced
curl -X PUT --data '{"maxSendLatency":"100"}' http://localhost:8081/fledge/category/$s2_south_service_name_advanced

# Param purge
curl -X PUT --data '{"value":"1"}' http://localhost:8081/fledge/category/PURGE_READ/age
curl -X PUT --data '{"value":"100000"}' http://localhost:8081/fledge/category/PURGE_READ/size

# Create Notification plugins
curl -sX POST http://localhost:8081/fledge/notification -d '{"name":"'$notif_name_1'","description":"'$notif_name_1' notification instance","rule":"'$notif_plugin_1'","channel":"'$notif_plugin_2'","notification_type":"retriggered","enabled":true,"retrigger_time":"1","rule_config":{},"delivery_config":{}}'
# Workaround for delay between notifications (we want 0 but Fledge does not allow it, and -1 is rejected at notification instance creation)
curl -X PUT --data '{"retrigger_time":"-1"}' http://localhost:8081/fledge/category/$notif_name_1

