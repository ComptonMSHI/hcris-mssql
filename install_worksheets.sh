# Assumes you pass in a password or env variable with the password as the third argument.
# ./install_worksheets.sh "data.informatic.ist,37136" UABMSHIMCR $DB_PASS &

sqlcmd -S $1 -d $2 -U SA -P $3 -i psm-crosswalk.sql -o install_worksheets.log
sqlcmd -S $1 -d $2 -U SA -P $3 -i psm-worksheets-availability.sql -o install_worksheets.log
sqlcmd -S $1 -d $2 -U SA -P $3 -i psm-worksheets-initialize.sql -o install_worksheets.log
sqlcmd -S $1 -d $2 -U SA -P $3 -i psm-worksheets-load.sql -o install_worksheets.log
sqlcmd -S $1 -d $2 -U SA -P $3 -i install.sql -o install_worksheets.log
