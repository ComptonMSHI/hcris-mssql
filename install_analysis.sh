# Assumes you pass in a password or env variable with the password as the third argument.
# ./install_analysis.sh "localhost,1433" TEST_MCR $DB_PASS

date

sqlcmd -S $1 -d $2 -U SA -P $3 -i analysis/psm-table-checks.sql -o install_analysis.log
sqlcmd -S $1 -d $2 -U SA -P $3 -i analysis/psm-lookups.sql -o install_worksheets.log
sqlcmd -S $1 -d $2 -U SA -P $3 -i analysis/psm-table-coordinates.sql -o install_analysis.log
sqlcmd -S $1 -d $2 -U SA -P $3 -i analysis/psm-table-facts.sql -o install_analysis.log
sqlcmd -S $1 -d $2 -U SA -P $3 -i analysis/psm-table-providers.sql -o install_analysis.log
sqlcmd -S $1 -d $2 -U SA -P $3 -i analysis/psm-table-rows.sql -o install_analysis.log
sqlcmd -S $1 -d $2 -U SA -P $3 -i analysis/psm-table-form.sql -o install_analysis.log
sqlcmd -S $1 -d $2 -U SA -P $3 -i analysis/install_analysis.sql -o install_analysis.log

date