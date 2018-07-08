@echo off

REM # Leave the username blank and press enter for windows authentication.
REM # ./install_analysis.bat localhost UABMSHIMCR

date /T
time /T

set user=
set /p user=User: 

IF "%user%"=="" (

    sqlcmd -S %1 -d %2 -i worksheets/psm-crosswalk.sql -o install_worksheets.log
    sqlcmd -S %1 -d %2 -i worksheets/psm-worksheets-availability.sql -o install_worksheets.log
    sqlcmd -S %1 -d %2 -i worksheets/psm-worksheets-initialize.sql -o install_worksheets.log
    sqlcmd -S %1 -d %2 -i worksheets/psm-worksheets-load.sql -o install_worksheets.log
    sqlcmd -S %1 -d %2 -i worksheets/install_worksheets.sql -o install_worksheets.log

) ELSE (

    sqlcmd -S %1 -d %2 -U %user% -i worksheets/psm-crosswalk.sql -o install_worksheets.log
    sqlcmd -S %1 -d %2 -U %user% -i worksheets/psm-worksheets-availability.sql -o install_worksheets.log
    sqlcmd -S %1 -d %2 -U %user% -i worksheets/psm-worksheets-initialize.sql -o install_worksheets.log
    sqlcmd -S %1 -d %2 -U %user% -i worksheets/psm-worksheets-load.sql -o install_worksheets.log
    sqlcmd -S %1 -d %2 -U %user% -i worksheets/install_worksheets.sql -o install_worksheets.log

)

date /T
time /T