# Assumes you pass in a password or env variable with the password as the first argument.
# ./install.sh $DB_PASS > install.log &

sqlcmd -S "data.informatic.ist,37136" -d UABMSHIMCR -U SA -P $1 -i psm-crosswalk.sql > psm.log
sqlcmd -S "data.informatic.ist,37136" -d UABMSHIMCR -U SA -P $1 -i psm-mcr-alpha-load.sql >> psm.log
sqlcmd -S "data.informatic.ist,37136" -d UABMSHIMCR -U SA -P $1 -i psm-mcr-nmrc-load.sql >> psm.log
sqlcmd -S "data.informatic.ist,37136" -d UABMSHIMCR -U SA -P $1 -i psm-mcr-rpt-load.sql >> psm.log
sqlcmd -S "data.informatic.ist,37136" -d UABMSHIMCR -U SA -P $1 -i psm-table-facts.sql >> psm.log
sqlcmd -S "data.informatic.ist,37136" -d UABMSHIMCR -U SA -P $1 -i psm-table-providers.sql >> psm.log
sqlcmd -S "data.informatic.ist,37136" -d UABMSHIMCR -U SA -P $1 -i psm-table-rows.sql >> psm.log
sqlcmd -S "data.informatic.ist,37136" -d UABMSHIMCR -U SA -P $1 -i psm-worksheets-availability.sql >> psm.log
sqlcmd -S "data.informatic.ist,37136" -d UABMSHIMCR -U SA -P $1 -i psm-worksheets-initialize.sql >> psm.log
sqlcmd -S "data.informatic.ist,37136" -d UABMSHIMCR -U SA -P $1 -i psm-worksheets-load.sql >> psm.log
sqlcmd -S "data.informatic.ist,37136" -d UABMSHIMCR -U SA -P $1 -i install.sql > install.log
