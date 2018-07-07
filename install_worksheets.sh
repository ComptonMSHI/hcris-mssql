# Assumes you pass in a password or env variable with the password as the third argument.
# ./install_worksheets.sh "data.informatic.ist,37136" UABMSHIMCR $DB_PASS &

sqlcmd -S $1 -d $2 -U SA -P $3 -i worksheets/psm-crosswalk.sql -o install_worksheets.log
sqlcmd -S $1 -d $2 -U SA -P $3 -i worksheets/psm-worksheets-availability.sql -o install_worksheets.log
sqlcmd -S $1 -d $2 -U SA -P $3 -i worksheets/psm-worksheets-initialize.sql -o install_worksheets.log
sqlcmd -S $1 -d $2 -U SA -P $3 -i worksheets/psm-worksheets-load.sql -o install_worksheets.log
sqlcmd -S $1 -d $2 -U SA -P $3 -i worksheets/install_worksheets.sql -o install_worksheets.log
