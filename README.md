# pcfview

This script will create a list of all applications [name, state, instances, memory, disk_quota, created_at, org_name, space_name] in CSV format.

Requirements - jq must be installed - https://stedolan.github.io/jq/

Usage

where:
    -u  host of uaa
    -n  Username
    -p  Password"

./pcf-view.sh -u run.pivotal.io -n username@pivotal.io -p ##########

Example output

`Name	State	Instances	Memory	Disk Quota	Created	Org Name	Space Name
tomcat	STARTED	1	1024	1024	2016-10-20T13:38:53Z	Northeast / Canada	raviJag
jbpm	STOPPED	1	4096	2048	2016-10-24T16:45:51Z	Northeast / Canada	raviJag
goroute	STARTED	1	256	1024	2016-11-07T16:44:50Z	Northeast / Canada	raviJag`
