#!/bin/sh
#
# alarm-event.sh -- sample trigger script for nxgipd daemon
#
# This gets called in response to events in monitored alarm system.
# Information about the even is passed in environment variables to
# this script.
#
# Common environment variables (all events):
#
# ALARM_EVENT_TYPE This will be set to one the following
# values: "zone", "partition", or "log"
#
# ALARM_EVENT_STATUS This contains string describing the event
#
#
# Event type specific variables:
#
# Zone:
# ALARM_EVENT_ZONE Zone Number
# ALARM_EVENT_ZONE_NAME Zone Name
# ALARM_EVENT_ZONE_FAULT Zone Fault status: 1=Fault, 0=OK
# ALARM_EVENT_ZONE_TROUBLE Zone Trouble status: 1=Trouble, 0=No Trouble
# ALARM_EVENT_ZONE_TAMPER Zone Tamper status: 1=Tamper, 0=No Tamper
# ALARM_EVENT_ZONE_BYPASS Zone Bypass status: 1=Bypassed, 0=Not Bypassed
# ALARM_EVENT_ZONE_ARMED Zone Armed: 1=Armed, 0=Not Armed
#
# Partition:
# ALARM_EVENT_PARTITION Partition Number
# ALARM_EVENT_PARTITION_ARMED Partition Armed status: 1=Armed, 0=Not Armed
# ALARM_EVENT_PARTITION_READY Partition Ready: 1=Ready, 0=Not Ready
# ALARM_EVENT_PARTITION_STAY Partition Stay Mode: 1=On, 0=Off
# ALARM_EVENT_PARTITION_CHIME Partition Chime Mode: 1=On, 0=Off
# ALARM_EVENT_PARTITION_ENTRY Partition Entry Delay: 1=Start, 0=End
# ALARM_EVENT_PARTITION_EXIT Partition Exit Delay: 1=Start, 0=End
# ALARM_EVENT_PARTITION_ALARM Partition Alarm status: 1=On, 2=Off
#
# Log:
# ALARM_EVENT_LOG_TYPE Raw log entry type (see nx-584.c)
# ALARM_EVENT_LOG_NUM Log entry number
# ALARM_EVENT_LOG_LOGSIZE Max log number
# (following are only present if log entry defines them)
# ALARM_EVENT_LOG_PARTITION Partition this entry refers to (if defined)
# ALARM_EVENT_LOG_ZONE Zone this entry refers to (if defined)
# ALARM_EVENT_LOG_USER User this entry refers to (if defined)
# ALARM_EVENT_LOG_DEVICE Device this entry refers to (if defined)
# (following define the time event was recorded according alarm panel clock)
# ALARM_EVENT_LOG_MONTH Month (1..31)
# ALARM_EVENT_LOG_DAY Day (of Month) (1..12)
# ALARM_EVENT_LOG_HOUR Hour (0..23)
# ALARM_EVENT_LOG_MIN Minutes (0..59)
#

SYSLOGTAG="alarm-event"

##  echo $ALARM_EVENT_TYPE : $ALARM_EVENT_ZONE : $ALARM_EVENT_ZONE_NAME : $ALARM_EVENT_STATUS

case "${ALARM_EVENT_TYPE}" in

zone)
# logger -t $SYSLOGTAG "zone: $ALARM_EVENT_ZONE ($ALARM_EVENT_ZONE_NAME), status: $ALARM_EVENT_STATUS"

  case "${ALARM_EVENT_ZONE}" in
    1) lv_zone="FrontDoor" ;;
    2) lv_zone="BackDoor" ;;
    3) lv_zone="KitchenWindow" ;;
    4) lv_zone="MstrBathWindow" ;;
    5) lv_zone="TestZone" ;;
    6) lv_zone="BasementMWindow" ;;
    7) lv_zone="BasementMotion" ;;
    8) lv_zone="SmokeDetector" ;;
    9) lv_zone="GarageDoor" ;;
    10) lv_zone="BasementFrench" ;;
    11) lv_zone="LaundryWindow" ;;
    12) lv_zone="FoyerMotion" ;;
    13) lv_zone="KitchenMotion" ;;
    14) lv_zone="DiningWindow" ;;
    *) lv_zone="UnknownZone" ;;
  esac


  case "${ALARM_EVENT_ZONE_FAULT}" in
    1) lv_msg="OPEN" ;;
    0) lv_msg="CLOSED" ;;
  esac


# $MQTT_HOST is environment variable set in docker container
  nohup mosquitto_pub -h "mqtt.lan" -t "alarm/zone/$lv_zone" -m "$lv_zone - $lv_msg" -q 1 &

;;

# partition)
# logger -t $SYSLOGTAG "partition: $ALARM_EVENT_PARTITION, status: $ALARM_EVENT_STATUS"
# mosquitto_pub -t alarm/partition -m "Partition Ready=$ALARM_EVENT_PARTITION_READY" -q 1
# mosquitto_pub -t alarm/partition/test -m "test message" -q 1
# ;;

# log)
# logger -t $SYSLOGTAG "log: ${ALARM_EVENT_LOG_NUM}/${ALARM_EVENT_LOG_LOGSIZE}: ${ALARM_EVENT_HOUR}:${ALARM_EVENT_MIN} $ALARM_EVENT_STATUS"
# mosquitto_pub -t alarm/log/$ALARM_EVENT_ZONE_NAME -m status:$ALARM_EVENT_STATUS -q 1
# mosquitto_pub -t alarm/log/test -m "test message" -q 1
# ;;

# *)
# logger -t $SYSLOGTAG "unknown alarm event: '$ALARM_EVENT_TYPE'"
# mosquitto_pub -t alarm/else -m "Type:$ALARM_EVENT_TYPE" -q 1
# mosquitto_pub -t alarm/else/test -m "test message" -q 1
# exit 1
# ;;

esac

# eof :-)
