# HCRIS Cost Report Data for MS SQL Server

More information coming soon.

## Requirements

These scripts are prepared for Microsoft SQL Server 2017 (Windows or Linux).

## Dependencies

- [hcris-archiver](https://github.com/ComptonMSHI/hcris-archiver) - This application downloads and archives the data from the CMS website.

- [hcris-worksheets](https://github.com/ComptonMSHI/hcris-worksheets) - This script parses the 508 compliant versions of the 2552 forms to produce SQL code to import as worksheet data.

## Installation

### Linux

There are shell scripts (`.sh`) available to perform three different stages of data import:

- `install_foundation.sh` will drop and load a complete release of RPT, ALPHA and NMRC data from the hcris-archiver csv output.
- `install_worksheets.sh` will drop and load all required worksheet and crosswalk data. Note that only a limited set of worksheets are supported, but you can expand on this by using the hcris-worksheets project, and adding to the crosswalk psm.
- `install_analysis.sh` will drop and load the tables used for analysis, and as the final step before moving data into a multidimensional cube.

### Windows

There are no bat files yet to compliment the shell scripts for linux; however, the content of the `install_*.sql` files can be executed directly using SSMS or a similar tool for executing SQL.

## References
