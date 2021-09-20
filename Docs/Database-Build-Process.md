
# Overview

This document describes common scenarios that would result in the alteration of a database model, and how to defensively script these out so that existing databases can be upgraded in-place, safely and effectively.

# Overall Build Process

The overall build process will be fairly straightforward. First, the **upgrade** scripts will run.
These scripts will modify tables, indexes, constraints, and other schema objects.
After that, all the scripts in the functions, then views, then procedures folder will be applied, regardless of whether or not anything has changed.
This has the benefit of allowing us to maintain all T-SQL scripts in one place for both full deploys and upgrades.

# Where to Place Upgrade Code

The build system will run all the scripts in the following order:

- UpgradeScripts
- Functions
- Views
- StoredProcedures

Code in any of the folders not listed above will only be run on local deploys
(CreateDatabase.bat – where the database is dropped and recreated).

Upgrade scripts run first because these are the scripts making changes to tables and columns -
objects that will potentially be required by code in the next 3 folders.

For any changes to the database schema, or to data, place these in the _UpgradeScripts_ folder.

For any changes to SQL code (functions/views/stored procedures), please follow these conventions listed below.

---------
## Build Database Process in Details

The build process is composed by two scripts.

The first one can be used to create a new local Database and the second one is used to Upgrade the Dabatase, applying necessary changes.

### 1 - Create Database

Run this to create a new LOCAL database,

**Note:** this also runs for Pull Request checks - DB test build on Jenkins - when you make changes and create a Pull Request on Github, we first create a new temp database to make sure the build process is consistent, and you are not breaking or forgetting anything.

**CreateDatabae** will run on jenkins only (not used by Octopus).

The Server, Database, Username, Password are parameters passed to the script:

```call CreateDatabase.bat [Server] [Database] [username] [password]```

For example:

```call CreateDatabase.bat localhost\sqlexpress CC3_local username password```


Inside each folder there is a ".bat" script to load and execute all ".sql" files inside that folder.

The CreateDatabase script will execute in the following order:
```
Create Database Steps:
	*[Drop and Create a new empty Database]
	ECHO ... Creating Assemblies .......... CALL .\Assemblies\CreateAssemblies.bat
	ECHO ... Creating Schemas ............. CALL .\Schemas\CreateSchemas.bat
	ECHO ... Creating Synonyms ............ CALL .\Synonyms\CreateSynonyms.bat
	ECHO ... Creating Sequences ........... CALL .\Sequences\CreateSequences.bat
	ECHO ... Creating Types ............... CALL ..\Types\CreateTypes.bat
	ECHO ... Creating Tables .............. CALL .\Tables\CreateTables.bat
	ECHO ... Creating Foreign Keys ........ CALL .\ForeignKeys\CreateFKs.bat
	ECHO ... Creating UDFs ................ CALL .\Functions\CreateFunctions.bat
	ECHO ... Creating Views ............... CALL .\Views\CreateViews.bat
	ECHO ... Creating Stored Procedures ... CALL .\StoredProcedures\CreateSprocs.bat
	ECHO ... Creating Users and Logins .... CALL .\Security\CreateSecurity.bat
	ECHO ... Generating Default Data ...... CALL .\Data\Default\CreateDefaultData.bat
	ECHO ... Generating Test Data ......... CALL .\Data\TestData\CreateTestData.bat
	ECHO ... Running Unit Tests ........... CALL .\StoredProcedures\UnitTests\RunUnitTests.bat
```

### 2 - Upgrade Database

This process runs in all environment to update the database to the last desired stated.

**Upgrade** will run in all environment by Octopus.

The Server, Database, Username, Password are parameters passed to the script:

```call Upgrade.bat [Server] [Database] [username] [password]```

For example:

```call Upgrade.bat localhost\sqlexpress CC3_local username password```


Inside each folder there is a ".bat" script to load and execute all ".sql" files inside that folder.

The Upgrade script will execute in the following order:
```
Upgrade Database Steps:
	ECHO ... Altering UDFs (Functions) .... CALL .\Functions\CreateFunctions.bat
	ECHO ... Running Upgrade Scripts ...... CALL .\UpgradeScripts\RunUpgradeScripts.bat
	ECHO ... Altering Views ............... CALL .\Views\CreateViews.bat
	ECHO ... Altering Stored Procedures ... CALL .\StoredProcedures\CreateSprocs.bat
```
