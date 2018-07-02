# Assumes you pass in a password or env variable with the password as the third argument.
# ./install.sh "data.informatic.ist,37136" UABMSHIMCR $DB_PASS &

sqlcmd -S $1 -d $2 -U SA -P $3 -i psm-crosswalk.sql -o psm.log
sqlcmd -S $1 -d $2 -U SA -P $3 -i psm-mcr-alpha-load.sql -o psm.log
sqlcmd -S $1 -d $2 -U SA -P $3 -i psm-mcr-nmrc-load.sql -o psm.log
sqlcmd -S $1 -d $2 -U SA -P $3 -i psm-mcr-rpt-load.sql -o psm.log
sqlcmd -S $1 -d $2 -U SA -P $3 -i psm-table-facts.sql -o psm.log
sqlcmd -S $1 -d $2 -U SA -P $3 -i psm-table-providers.sql -o psm.log
sqlcmd -S $1 -d $2 -U SA -P $3 -i psm-table-rows.sql -o psm.log
sqlcmd -S $1 -d $2 -U SA -P $3 -i psm-worksheets-availability.sql -o psm.log
sqlcmd -S $1 -d $2 -U SA -P $3 -i psm-worksheets-initialize.sql -o psm.log
sqlcmd -S $1 -d $2 -U SA -P $3 -i psm-worksheets-load.sql -o psm.log
sqlcmd -S $1 -d $2 -U SA -P $3 -i install.sql -o install.log
