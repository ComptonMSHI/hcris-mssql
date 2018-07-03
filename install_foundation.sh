# Assumes you pass in a password or env variable with the password as the third argument.
# ./install_foundation.sh "data.informatic.ist,37136" UABMSHIMCR $DB_PASS &

sqlcmd -S $1 -d $2 -U SA -P $3 -i psm-mcr-alpha-load.sql -o install_foundation.log
sqlcmd -S $1 -d $2 -U SA -P $3 -i psm-mcr-nmrc-load.sql -o install_foundation.log
sqlcmd -S $1 -d $2 -U SA -P $3 -i psm-mcr-rpt-load.sql -o install_foundation.log
sqlcmd -S $1 -d $2 -U SA -P $3 -i install_foundation.sql -o install_foundation.log