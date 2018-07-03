# Assumes you pass in a password or env variable with the password as the third argument.
# ./install_analysis.sh "data.informatic.ist,37136" UABMSHIMCR $DB_PASS &

sqlcmd -S $1 -d $2 -U SA -P $3 -i psm-table-facts.sql -o install_analysis.log
sqlcmd -S $1 -d $2 -U SA -P $3 -i psm-table-providers.sql -o install_analysis.log
sqlcmd -S $1 -d $2 -U SA -P $3 -i psm-table-rows.sql -o install_analysis.log
sqlcmd -S $1 -d $2 -U SA -P $3 -i psm-table-form.sql -o install_analysis.log
sqlcmd -S $1 -d $2 -U SA -P $3 -i install.sql -o install_analysis.log
