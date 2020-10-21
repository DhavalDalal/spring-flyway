
# Getting Started

Hibernate DDL creation is a nice feature for PoCs or small projects. 
For more significant projects that have a complex deployment workflow 
and features like version rollback in case of a significant issue, 
the solution is not sufficient.

Also, in production, a Hibernate DDL updation would not be safe. Applied patches may have side effects which hbm2ddl hardly can predict (such as disabling triggers that were installed for table being modified). For complex schemas the safest way is manual.  Despite the best efforts of the Hibernate team, you simply cannot rely on automatic updates in production. Write your own patches, review them with DBA, test them, then apply them.

## How flyway works?
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
1. Add Flyway as a dependency ```compile('org.flywaydb:flyway-core')```
in your ```build.gradle```. 
3. When Spring Boot detects Flyway on the classpath, it will run it on 
startup.

## Prepare MySQL Database
1. Run the following commands after starting the mysql server using
```mysql.server start``` on the CLI.
2. Run mysql client on the CLI using ```mysql```.  It will take you to the ```mysql>``` prompt.
3. Run the commands below to create database and grant rights to the user

	```
	mysql> create database flywaydemo; -- Creates the new database
	mysql> create user 'springuser'@'%' identified by 'ThePassword'; -- Creates the user
	mysql> grant all on flywaydemo.* to 'springuser'@'%'; -- Gives all privileges to the new user on the newly created database
	```

## Running the application without Flyway
* Simulating an application without Flyway
* In the ```application.yaml``` or in ```application.properties``` add ```spring.jpa.hibernate.ddl-auto=update```
	* Disable flyway
	
	    ```
	    flyway:
	        enabled: false
	    ```
    * Make Hibernate update the schema automatically
    
	    ```
	  	 jpa:
	        hibernate:
	            ddl-auto: update
	    ```
    
* Start the application ```$> ./gradlew bootRun```    
* This creates the following tables in the ```flywaydemo```

   ```
   mysql> show tables;
	+----------------------+
	| Tables_in_flywaydemo |
	+----------------------+
	| hibernate_sequence   |
	| users                |
	+----------------------+
   ```
* Describing the two tables gives us:

	```
	mysql> desc users;
   +-------+--------------+------+-----+---------+-------+
   | Field | Type         | Null | Key | Default | Extra |
   +-------+--------------+------+-----+---------+-------+
   | id    | int          | NO   | PRI | NULL    |       |
   | email | varchar(255) | YES  |     | NULL    |       |
   | name  | varchar(255) | YES  |     | NULL    |       |
   +-------+--------------+------+-----+---------+-------+

   mysql> desc hibernate_sequence;
   +----------+--------+------+-----+---------+-------+
   | Field    | Type   | Null | Key | Default | Extra |
   +----------+--------+------+-----+---------+-------+
   | next_val | bigint | YES  |     | NULL    |       |
   +----------+--------+------+-----+---------+-------+ 
	```
   
* Run the following shell scripts from ```src/main/resources/shell_scripts``` folder in order:
	1. ```00_create_few_users.sh``` to create few users in the database
	2. ```01_get_all_users.sh``` to verify that the users are created
* Lets say we now want to deploy this application in production, so we create an sql script, say ```Create_User_Table.sql```  that will be applied to the production database:

	```
	CREATE TABLE `users` (
	  `id` int(11) NOT NULL,
	  `email` varchar(255) DEFAULT NULL,
	  `name` varchar(255) DEFAULT NULL,
	  PRIMARY KEY (`id`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	```
	
* Now, the appication can run in production.

## Introducing Flyway
Our journey so far was a standard JPA application and its deployment.  Lets look how Flaywa can be integrated in our development and deployment workflow:

* In the ```application.yaml``` 
	* Enable flyway
	
	    ```
	    flyway:
	        enabled: true
	    ```
    * Make Hibernate validate the schema automatically or in ```application.properties``` add ```spring.jpa.hibernate.ddl-auto=validate```
    
	    ```
	  	 jpa:
	        hibernate:
	            ddl-auto: validate
	    ```
* Run ```$> ./gradlew flywayInfo``` and it will show you that there is no schema and no migrations are found.

	```
	Schema version: << Empty Schema >>
	+----------+---------+-------------+------+--------------+-------+
	| Category | Version | Description | Type | Installed On | State |
	+----------+---------+-------------+------+--------------+-------+
	| No migrations found                                            |
	+----------+---------+-------------+------+--------------+-------+
	```

## Adding new Functionality
Let us now modify our User to add a ```birthDate``` field and the corresponding column in the database would be added automatically only-if we were using ```ddl-auto: update```. However, after introducing Flyway we have changed it to ```ddl-auto: validate```, and this automatic schema change by Hibernate would stop.  

So, we need to create sql scripts for new schema changes and let them be picked-up and applied by Flyway automatically for us.  By default, Flyway looks at files in the format ```V$X__$DESCRIPTION.sql```, where ```$X``` is the migration version name, in folder ```src/main/resources/db/migration```. Make sure you create that folder.

But before we make these changes, lets baseline existing schema.

## Baselining Schema With Flyway
1.  Let us create an SQL script ```V1__Baseline.sql``` having just one line:
 
	```
	select now();
	```
2. Run ```./gradlew flywayInfo``` and now it will show you

	```
	Schema version: << Empty Schema >>
	+-----------+---------+-------------+------+--------------+---------+
	| Category  | Version | Description | Type | Installed On | State   |
	+-----------+---------+-------------+------+--------------+---------+
	| Versioned | 1       | Baseline    | SQL  |              | Pending |
	+-----------+---------+-------------+------+--------------+---------+
	```
3. We now baseline this using Flyway. Under the flyway section in ```application.yml``` add

	```
  	flyway:
   	  table: schema_version
	```
   This is the table which Flyway creates for its book-keeping after running the step below.

4. Run ```$> ./gradlew flywayBaseline``` to create a baseline. This creates a schema version table in the database.  You can check the table in there.

	```
	desc schema_version;
	+----------------+---------------+------+-----+-------------------+-------------------+
	| Field          | Type          | Null | Key | Default           | Extra             |
	+----------------+---------------+------+-----+-------------------+-------------------+
	| installed_rank | int           | NO   | PRI | NULL              |                   |
	| version        | varchar(50)   | YES  |     | NULL              |                   |
	| description    | varchar(200)  | NO   |     | NULL              |                   |
	| type           | varchar(20)   | NO   |     | NULL              |                   |
	| script         | varchar(1000) | NO   |     | NULL              |                   |
	| checksum       | int           | YES  |     | NULL              |                   |
	| installed_by   | varchar(100)  | NO   |     | NULL              |                   |
	| installed_on   | timestamp     | NO   |     | CURRENT_TIMESTAMP | DEFAULT_GENERATED |
	| execution_time | int           | NO   |     | NULL              |                   |
	| success        | tinyint(1)    | NO   | MUL | NULL              |                   |
	+----------------+---------------+------+-----+-------------------+-------------------+
	```

5. Run ```./gradlew flywayInfo``` and it will show you:    

	```
	Schema version: 1
	+----------+---------+-----------------------+----------+---------------------+----------+
	| Category | Version | Description           | Type     | Installed On        | State    |
	+----------+---------+-----------------------+----------+---------------------+----------+
	|          | 1       | << Flyway Baseline >> | BASELINE | 2020-10-21 12:38:26 | Baseline |
	+----------+---------+-----------------------+----------+---------------------+----------+
	```

Woo Hoo! Our first SQL script is under Flyway's versioning scheme.

## Migrating Schema (DDL) Changes With Flyway 
1. Add the new ```birthDate``` field in ```User```

	```
	public class User {
	  @Id
	  @GeneratedValue(strategy = GenerationType.AUTO)
	  private Long id;
	  
	  private String name;
	
	  private String email;
	
	  private Date birthdate;
	}
	```

2. Create a DDL script ```V2__Alter_User_Table_Add_BirthDate_Column.sql```  that alters the ```user``` table and add the birthdate column.  

	```
	ALTER TABLE `users`
	  ADD COLUMN `birthdate` DATETIME DEFAULT NULL;
	```
3. Run ```./gradlew flywayInfo``` and it shows that the new script is pending to be applied to the database

	```
	Schema version: 1
	+-----------+---------+---------------------------------------+----------+---------------------+----------+
	| Category  | Version | Description                           | Type     | Installed On        | State    |
	+-----------+---------+---------------------------------------+----------+---------------------+----------+
	|           | 1       | << Flyway Baseline >>                 | BASELINE | 2020-10-21 12:38:26 | Baseline |
	| Versioned | 2       | Alter User Table Add BirthDate Column | SQL      |                     | Pending  |
	+-----------+---------+---------------------------------------+----------+---------------------+----------+
	```
	
4. Now, Run ```./gradlew flywayMigrate``` to migrate the schema changes. 
5. To verify that this was also under Flyway, run ```./gradlew flywayInfo```.  It shows that it is at Schema version 2   

	```
	Schema version: 2
	+-----------+---------+---------------------------------------+----------+---------------------+----------+
	| Category  | Version | Description                           | Type     | Installed On        | State    |
	+-----------+---------+---------------------------------------+----------+---------------------+----------+
	|           | 1       | << Flyway Baseline >>                 | BASELINE | 2020-10-21 12:38:26 | Baseline |
	| Versioned | 2       | Alter User Table Add BirthDate Column | SQL      | 2020-10-21 12:52:14 | Success  |
	+-----------+---------+---------------------------------------+----------+---------------------+----------+
	```
6. Verify this column in the user table in the database.

	```
	mysql> desc users;
	+-----------+--------------+------+-----+---------+-------+
	| Field     | Type         | Null | Key | Default | Extra |
	+-----------+--------------+------+-----+---------+-------+
	| id        | bigint       | NO   | PRI | NULL    |       |
	| email     | varchar(255) | YES  |     | NULL    |       |
	| name      | varchar(255) | YES  |     | NULL    |       |
	| birthdate | datetime     | YES  |     | NULL    |       |
	+-----------+--------------+------+-----+---------+-------+
	
	mysql> select * from users;
	+----+--------------+--------+-----------+
	| id | email        | name   | birthdate |
	+----+--------------+--------+-----------+
	|  1 | B@Brahma.com | Brahma | NULL      |
	|  2 | V@Vishnu.com | Vishnu | NULL      |
	|  3 | M@Mahesh.com | Mahesh | NULL      |
	+----+--------------+--------+-----------+
	```

## Migrating Data (DML) Change with Flyway
We want to set birth date to default zero value.

1. 	Lets create the script ```V3__Set_Birth_Date_To_DefaultZeroValue.sql```  and lets say we make it fail purposely to simulate a failed migration.

2. In the ```V3__Set_Birth_Date_To_DefaultZeroValue.sql``` script disable comments for the block:

    ``` to make it fail purposely:
    -- Wrong way to set date in MySQL (results in failed migration)
     UPDATE `users`
     SET birthdate = '0000-00-00'
     WHERE birthdate is null;
    ```
3. Now, Run ```./gradlew flywayMigrate``` to migrate the schema changes.  It fails:

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

4. Run ```$> ./gradlew flywayInfo``` and it will show you that you are schema version 3 with a failed migration
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
5. In the ```V3__Set_Birth_Date_To_DefaultZeroValue.sql``` script enable comments for earlier 
  block to ignore it and disable comments for:
  
    ``` 
    -- Correct way to set birth date to start
    UPDATE `users`
    SET birthdate = date('1000-01-01')
    WHERE birthdate is null;
    ```
6. Now, Run ```./gradlew flywayMigrate``` to migrate the schema changes.  It fails again:
  
   ```
   > Error occurred while executing flywayMigrate
     Validate failed: 
     Detected failed migration to version 3 (Set Birth Date To DefaultZeroValue)
   ```
7. Now, Run ```./gradlew flywayRepair``` to repair it.
8. Now, Run ```./gradlew flywayInfo``` to see the repair done.

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
9. Run ```$> ./gradlew flywayMigrate``` again to migrate the schema changes.
10. Now, Run ```$> ./gradlew flywayInfo``` to see the applied changes.

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

