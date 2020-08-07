
# Getting Started

## How flyway works?
Hibernate DDL creation is a nice feature for PoCs or small projects. 
For more significant projects that have a complex deployment workflow 
and features like version rollback in case of a significant issue, 
the solution is not sufficient.

There are several tools to handle database migrations, and one of the 
most popular is Flyway, which works flawlessly with Spring Boot. 
Briefly, Flyway looks for SQL scripts on your project’s resource path 
and runs all scripts not previously executed in a defined order. 
Flyway stores what files were executed into a particular table 
called SCHEMA_VERSION.

To keep track of which migrations have already been applied, 
when and by whom, it adds a special bookkeeping table to your schema.
This metadata table also tracks migration checksums and whether or 
not the migrations were successful.

The framework performs the following steps to accommodate evolving 
database schemas:

* It checks a database schema to locate its metadata table (SCHEMA_VERSION by default). If the metadata table does not exist, it will create one
* It scans an application classpath for available migrations
* It compares migrations against the metadata table. If a version number is lower or equal to a version marked as current, it is ignored
* It marks any remaining migrations as pending migrations. These are sorted based on version number and are executed in order
* As each migration is applied, the metadata table is updated accordingly

## Prepare Spring Boot App for Flyway
First, add Flyway as a dependency ```compile('org.flywaydb:flyway-core')```
in your ```build.gradle```. 

When Spring Boot detects Flyway on the classpath, it will run it on 
startup:

By default, Flyway looks at files in the format ```V$X__$DESCRIPTION.sql```, 
where ```$X``` is the migration version name, in folder ```src/main/resources/db/migration```. 

## Prepare MySQL Database
```
mysql> create database flywaydemo; -- Creates the new database
mysql> create user 'springuser'@'%' identified by 'ThePassword'; -- Creates the user
mysql> grant all on flywaydemo.* to 'springuser'@'%'; -- Gives all privileges to the new user on the newly created database
```

## Run the application with ```spring.flyway.enabled=false```
* In the ```application.yaml``` disable flyway
    ```
    flyway:
        enabled: false
    ```
* Start the application ```$> ./gradlew bootRun```    
* Run shell script ```00_create_few_users.sh``` to create few users in the database
* Verify that the users are created using ```01_get_all_users.sh```

## Create few SQL Scripts
* Create ```V1__Baseline.sql```
* Create ```V2__Alter_User_Table_Add_BirthDate_Column.sql```
* Create ```V3__Set_Birth_Date_To_DefaultZeroValue.sql```

## Baselining Schema With Flyway
* Now stop the application
* Run ```$> ./gradlew flywayInfo``` and it will show you that there is no schema
    ```
      Schema version: << Empty Schema >>
      +-----------+---------+---------------------------------------+------+--------------+---------+
      | Category  | Version | Description                           | Type | Installed On | State   |
      +-----------+---------+---------------------------------------+------+--------------+---------+
      | Versioned | 0       | Baseline                              | SQL  |              | Pending |
      | Versioned | 1       | Alter User Table Add BirthDate Column | SQL  |              | Pending |
      | Versioned | 2       | Set Birth Date To DefaultZeroValue    | SQL  |              | Pending |
      +-----------+---------+---------------------------------------+------+--------------+---------+
    ```  
  
* Run ```$> ./gradlew flywayBaseline``` to create a baseline. This creates a schema 
  version table in the database.  You can check the table in there.
* Run ```$> ./gradlew flywayInfo``` and it will show you that you are schema version 1

    ```
    Schema version: 1
    +-----------+---------+---------------------------------------+----------+---------------------+----------+
    | Category  | Version | Description                           | Type     | Installed On        | State    |
    +-----------+---------+---------------------------------------+----------+---------------------+----------+
    |           | 1       | << Flyway Baseline >>                 | BASELINE | 2020-08-07 21:36:19 | Baseline |
    | Versioned | 2       | Alter User Table Add BirthDate Column | SQL      |                     | Pending  |
    | Versioned | 3       | Set Birth Date To DefaultZeroValue    | SQL      |                     | Pending  |
    +-----------+---------+---------------------------------------+----------+---------------------+----------+
    ```  

## Migrating Schema Changes With Flyway
* In the ```V3__Set_Birth_Date_To_DefaultZeroValue.sql``` script disable comments for the block:
    ``` to make it fail purposely:
    -- Wrong way to set date in MySQL (results in failed migration)
     UPDATE `users`
     SET birthdate = '0000-00-00'
     WHERE birthdate is null;
    ```
* Now, Run ```$> ./gradlew flywayMigrate``` to migrate the schema changes.  It
  should fail:

    ```
    Execution failed for task ':flywayMigrate'.
    > Error occurred while executing flywayMigrate
      
      Migration V3__Set_Birth_Date_To_DefaultZeroValue.sql failed
      -----------------------------------------------------------
      SQL State  : 22001
      Error Code : 1292
      Message    : Data truncation: Incorrect datetime value: '0000-00-00' for column 'birthdate' at row 1
      Location   : /Users/dhavald/Documents/workspace/spring-flyway/src/main/resources/db/migration/V3__Set_Birth_Date_To_DefaultZeroValue.sql (/Users/dhavald/Documents/workspace/spring-flyway/src/main/resources/db/migration/V3__Set_Birth_Date_To_DefaultZeroValue.sql)
      Line       : 1
      Statement  : -- Wrong way to set date in MySQL (results in failed migration)
       UPDATE `users`
       SET birthdate = '0000-00-00'
       WHERE birthdate is null
      
      
      Migration V3__Set_Birth_Date_To_DefaultZeroValue.sql failed
      -----------------------------------------------------------
      SQL State  : 22001
      Error Code : 1292
      Message    : Data truncation: Incorrect datetime value: '0000-00-00' for column 'birthdate' at row 1
      Location   : /Users/dhavald/Documents/workspace/spring-flyway/src/main/resources/db/migration/V3__Set_Birth_Date_To_DefaultZeroValue.sql (/Users/dhavald/Documents/workspace/spring-flyway/src/main/resources/db/migration/V3__Set_Birth_Date_To_DefaultZeroValue.sql)
      Line       : 1
      Statement  : -- Wrong way to set date in MySQL (results in failed migration)
       UPDATE `users`
       SET birthdate = '0000-00-00'
       WHERE birthdate is null
    ```

* Run ```$> ./gradlew flywayInfo``` and it will show you that you are schema version 3 with a failed migration
    ```
    Schema version: 3
    +-----------+---------+---------------------------------------+----------+---------------------+----------+
    | Category  | Version | Description                           | Type     | Installed On        | State    |
    +-----------+---------+---------------------------------------+----------+---------------------+----------+
    |           | 1       | << Flyway Baseline >>                 | BASELINE | 2020-08-07 21:59:50 | Baseline |
    | Versioned | 2       | Alter User Table Add BirthDate Column | SQL      | 2020-08-07 22:00:09 | Success  |
    | Versioned | 3       | Set Birth Date To DefaultZeroValue    | SQL      | 2020-08-07 22:00:09 | Failed   |
    +-----------+---------+---------------------------------------+----------+---------------------+----------+
    ```
* In the ```V3__Set_Birth_Date_To_DefaultZeroValue.sql``` script enable comments for earlier 
  block to ignore it and disable comments for:
    ``` 
    -- Correct way to set birth date to start
    UPDATE `users`
    SET birthdate = date('1000-01-01')
    WHERE birthdate is null;
    ```
* Now, Run ```$> ./gradlew flywayMigrate``` to migrate the schema changes.  It
  fails again:
   ```
   > Error occurred while executing flywayMigrate
     Validate failed: 
     Detected failed migration to version 3 (Set Birth Date To DefaultZeroValue)
   ```
* Now, Run ```$> ./gradlew flywayRepair``` to repair it.
* Now, Run ```$> ./gradlew flywayInfo``` to see the repair done.
   ```
   Schema version: 2
   +-----------+---------+---------------------------------------+----------+---------------------+----------+
   | Category  | Version | Description                           | Type     | Installed On        | State    |
   +-----------+---------+---------------------------------------+----------+---------------------+----------+
   |           | 1       | << Flyway Baseline >>                 | BASELINE | 2020-08-07 21:59:50 | Baseline |
   | Versioned | 2       | Alter User Table Add BirthDate Column | SQL      | 2020-08-07 22:00:09 | Success  |
   | Versioned | 3       | Set Birth Date To DefaultZeroValue    | SQL      |                     | Pending  |
   +-----------+---------+---------------------------------------+----------+---------------------+----------+
   ```
* Run ```$> ./gradlew flywayMigrate``` again to migrate the schema changes.
* Now, Run ```$> ./gradlew flywayInfo``` to see the applied changes.
    ```
    Schema version: 3
    +-----------+---------+---------------------------------------+----------+---------------------+----------+
    | Category  | Version | Description                           | Type     | Installed On        | State    |
    +-----------+---------+---------------------------------------+----------+---------------------+----------+
    |           | 1       | << Flyway Baseline >>                 | BASELINE | 2020-08-07 21:59:50 | Baseline |
    | Versioned | 2       | Alter User Table Add BirthDate Column | SQL      | 2020-08-07 22:00:09 | Success  |
    | Versioned | 3       | Set Birth Date To DefaultZeroValue    | SQL      | 2020-08-07 22:11:38 | Success  |
    +-----------+---------+---------------------------------------+----------+---------------------+----------+
    ```

## Versioning Schema Changes With Flyway
* In the ```application.yaml``` enable flyway
     ```
     flyway:
         enabled: true
     ```
* In ```application.properties```, change the ```ddl-auto=update``` 
  configuration to validate: ```spring.jpa.hibernate.ddl-auto=validate```. 
  This causes Hibernate to validate the schema to see if it matches with 
  what’s defined in Java. If no match is found, the application will 
  not start.


### Reference Documentation
For further reference, please consider the following sections:

* [Official Gradle documentation](https://docs.gradle.org)
* [Spring Boot Gradle Plugin Reference Guide](https://docs.spring.io/spring-boot/docs/2.3.2.RELEASE/gradle-plugin/reference/html/)
* [Create an OCI image](https://docs.spring.io/spring-boot/docs/2.3.2.RELEASE/gradle-plugin/reference/html/#build-image)
* [Spring Web](https://docs.spring.io/spring-boot/docs/2.3.2.RELEASE/reference/htmlsingle/#boot-features-developing-web-applications)
* [Spring Boot DevTools](https://docs.spring.io/spring-boot/docs/2.3.2.RELEASE/reference/htmlsingle/#using-boot-devtools)
* [Spring Configuration Processor](https://docs.spring.io/spring-boot/docs/2.3.2.RELEASE/reference/htmlsingle/#configuration-metadata-annotation-processor)

### Guides
The following guides illustrate how to use some features concretely:

* [Building a RESTful Web Service](https://spring.io/guides/gs/rest-service/)
* [Serving Web Content with Spring MVC](https://spring.io/guides/gs/serving-web-content/)
* [Building REST services with Spring](https://spring.io/guides/tutorials/bookmarks/)

### Additional Links
These additional references should also help you:

* [Gradle Build Scans – insights for your project's build](https://scans.gradle.com#gradle)

