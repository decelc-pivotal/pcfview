#!/bin/bash
usage="$(basename "$0") [-h] [-d] [-n] [-p] -- program to 

where:
    -d  domain (i.e. run.pivotal.io)
    -n  Username
    -p  Password"
	
DATE=`date +"%T-%m:%d:%Y"`

while getopts h:d:p:n: option
do
        case "${option}"
        in
                h) echo "$usage"
                   exit;;
                d) DOMAIN=${OPTARG};;
                n) USERNAME=${OPTARG};;
                p) PASSWORD=${OPTARG};;
        esac
done

echo $DOMAIN
echo $USERNAME
#echo $PASSWORD
echo "###################################################################################"
echo "# Getting PCF application for $DOMAIN as $USERNAME"
echo "###################################################################################"
TOKEN=`curl -s -k --insecure -H 'Accept: application/json;charset=utf-8' -d 'grant_type=password' -d 'username='"$USERNAME"'' -d 'password='"$PASSWORD"'' -u 'cf:' https://login.$DOMAIN/oauth/token | jq -r .access_token`
#echo $TOKEN
echo "Getting token"

#List all organizations
ORGS=`curl -s -k --insecure -H 'Accept: application/json;charset=utf-8' "https://api.$DOMAIN/v2/organizations" -X GET -H "Authorization: bearer $TOKEN" -H "Host: api.$DOMAIN" -H "Cookie: " |  jq -r '.resources '`
SPACES=""
APPS=""

echo "Getting orgs"
while read i; do
	ORG_GUID=`echo $i | jq -r '.metadata.guid'`
	ORG_NAME=`echo $i | jq -r '.entity.name'`
	#echo $ORG_GUID
	echo $ORG_NAME
	SPACES+=`curl -s -k --insecure -H 'Accept: application/json;charset=utf-8' "https://api.$DOMAIN/v2/organizations/$ORG_GUID/spaces" -X GET -H "Authorization: bearer $TOKEN" -H "Host: api.$DOMAIN" -H "Cookie: " |  jq --arg org_guid "$ORG_GUID" --arg org_name "$ORG_NAME"  '.resources[] | [{name: .entity.name, guid: .metadata.guid, created_at: .metadata.created_at, org_guid: $org_guid, org_name: $org_name}] []'`
	#echo $SPACES
done < <(echo $ORGS | jq -c '.[]')

while read k; do
	SPACE_GUID=`echo $k | jq -r '.guid'`
	SPACE_NAME=`echo $k | jq -r '.name'`
	ORG_GUID=`echo $k | jq -r '.org_guid'`
	ORG_NAME=`echo $k | jq -r '.org_name'`
	echo "Getting apps for - $SPACE_NAME [$ORG_NAME]"
	APPS+=`curl -s -k --insecure -H 'Accept: application/json;charset=utf-8' "https://api.$DOMAIN/v2/spaces/$SPACE_GUID/apps" -X GET -H "Authorization: bearer $TOKEN" -H "Host: api.$DOMAIN" -H "Cookie: " |  jq --arg org_guid "$ORG_GUID" --arg org_name "$ORG_NAME"  --arg space_guid "$SPACE_GUID" --arg space_name "$SPACE_NAME" '.resources[] | [{name: .entity.name, guid: .metadata.guid, state: .entity.state, instances: .entity.instances, memory: .entity.memory, disk_quota: .entity.disk_quota, created_at: .metadata.created_at, org_guid: $org_guid, org_name: $org_name, space_guid: $space_guid, space_name: $space_name}] []'`
	#echo $APPS
done < <(echo $SPACES | jq -c '.')
	
#echo "Conveting to cvs format"
APPS=`echo $APPS | jq -s '.' #`
echo $APPS | jq -r -s '.[] | ["Name", "State", "Instances", "Memory", "Disk Quota", "Created", "Org Name", "Space Name"], map([.name, .state, .instances, .memory, .disk_quota, .created_at, .org_name, .space_name]) [] | @csv ' >> pcf-view-$DATE.csv

echo "###################################################################################"
echo "# Complete - results stored in pcf-view-$DATE.csv"
echo "###################################################################################"
