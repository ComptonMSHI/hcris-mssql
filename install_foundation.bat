@echo off

REM # Leave the username blank and press enter for windows authentication.
REM # ./install_analysis.bat localhost UABMSHIMCR &

set user=
set /p user=User: 

IF "%user%"=="" (

    sqlcmd -S %1 -d %2 -i foundation/psm-mcr-alpha-load.sql -o install_foundation.log
    sqlcmd -S %1 -d %2 -i foundation/psm-mcr-nmrc-load.sql -o install_foundation.log
    sqlcmd -S %1 -d %2 -i foundation/psm-mcr-rpt-load.sql -o install_foundation.log
    sqlcmd -S %1 -d %2 -i foundation/install_foundation.sql -o install_foundation.log

) ELSE (

    sqlcmd -S %1 -d %2 -U %user% -i foundation/psm-mcr-alpha-load.sql -o install_foundation.log
    sqlcmd -S %1 -d %2 -U %user% -i foundation/psm-mcr-nmrc-load.sql -o install_foundation.log
    sqlcmd -S %1 -d %2 -U %user% -i foundation/psm-mcr-rpt-load.sql -o install_foundation.log
    sqlcmd -S %1 -d %2 -U %user% -i foundation/install_foundation.sql -o install_foundation.log

)