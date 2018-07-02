# Assumes you pass in a password or env variable with the password as the first argument.
# ./install.sh $DB_PASS > install.log &

sqlcmd -S "data.informatic.ist,37136" -d UABMSHIMCR -U SA -P $1 -i psm-crosswalk.sql
sqlcmd -S "data.informatic.ist,37136" -d UABMSHIMCR -U SA -P $1 -i psm-mcr-alpha-load.sql
sqlcmd -S "data.informatic.ist,37136" -d UABMSHIMCR -U SA -P $1 -i psm-mcr-nmrc-load.sql
sqlcmd -S "data.informatic.ist,37136" -d UABMSHIMCR -U SA -P $1 -i psm-mcr-rpt-load.sql
sqlcmd -S "data.informatic.ist,37136" -d UABMSHIMCR -U SA -P $1 -i psm-table-facts.sql
sqlcmd -S "data.informatic.ist,37136" -d UABMSHIMCR -U SA -P $1 -i psm-table-providers.sql
sqlcmd -S "data.informatic.ist,37136" -d UABMSHIMCR -U SA -P $1 -i psm-table-rows.sql
sqlcmd -S "data.informatic.ist,37136" -d UABMSHIMCR -U SA -P $1 -i psm-worksheets-availability.sql
sqlcmd -S "data.informatic.ist,37136" -d UABMSHIMCR -U SA -P $1 -i psm-worksheets-initialize.sql
sqlcmd -S "data.informatic.ist,37136" -d UABMSHIMCR -U SA -P $1 -i psm-worksheets-load.sql
sqlcmd -S "data.informatic.ist,37136" -d UABMSHIMCR -U SA -P $1 -i install.sql
