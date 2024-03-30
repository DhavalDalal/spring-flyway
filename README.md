
# Getting Started

Hibernate DDL creation is a nice feature for PoCs or small projects. 
For more significant projects that have a complex deployment workflow 
and features like version rollback in case of a significant issue, 
the solution is not sufficient.

Also, in production, a Hibernate DDL updation would not be safe. 
Applied patches may have side effects which ```hbm2ddl``` hardly can predict (such as disabling triggers that were installed for table being modified). For complex schemas the safest way is manual.  Despite the best efforts of the Hibernate team, you simply cannot rely on automatic updates in production. Write your own patches, review them with DBA, test them, then apply them.

## How flyway works?
There are several tools to handle database migrations, and one of the 
most popular is Flyway, which works flawlessly with Spring Boot. 
Briefly, Flyway looks for SQL scripts on your project’s resource path 
and runs all scripts not previously executed in a defined order. 
Flyway stores what files were executed into a particular table 
called ```schema_version```.

To keep track of which migrations have already been applied, 
when and by whom, it adds a special book-keeping table to your schema.
This metadata table also tracks migration checksums and whether the 
migrations were successfully applied.

The framework performs the following steps to accommodate evolving 
database schemas:

* It checks a database schema to locate its metadata table (```flyway_schema_version``` by default). If the metadata table does not exist, it will create one
* It scans an application classpath for available migrations
* It compares migrations against the metadata table. If a version number is lower or equal to a version marked as current, it is ignored
* It marks any remaining migrations as pending migrations. These are sorted based on version number and are executed in order
* As each migration is applied, the metadata table is updated accordingly

## Download Flyway Community or Flyway Teams
Download [Flyway Community](https://www.red-gate.com/products/flyway/editions).  It is perfect for individual developers, 
or non-commercial projects looking for a basic and reliable framework for versioning and 
automating the deployment of database changes.  It has following features:
* Flyway API/CLI core functionality
* Flyway Desktop GUI
* 6 basic commands: Migrate, Clean, Info, Validate, Baseline and Repair
* Support for current DB versions
* Community support

## Prepare Spring Boot App for Flyway
1. Add the Flyway Plugin in the plugins section in your ```build.gradle```.
    ```
    plugins {
        id "org.flywaydb.flyway" version "10.10.0"
    }
    ```
   
2. Add buildscript section so that Gradle Flyway tasks can communicate with underlying DB.
    ```
    buildscript {
        repositories {
            mavenCentral()
        }
        dependencies {
            classpath 'org.flywaydb:flyway-mysql:10.10.0'
        }
    }
    ```
3. Add Flyway as a dependency along with Flyway connector for your database.  Also,
   don't forget to add JDBC driver for your database for the application to connect. 
    ```
    dependencies {
        implementation 'org.flywaydb:flyway-core:10.10.0'
        implementation 'org.flywaydb:flyway-mysql:10.10.0'
        implementation 'mysql:mysql-connector-java:8.0.33'
    }
    ```

4. When Spring Boot detects Flyway on the classpath, it will run it on 
startup.

## Prepare MySQL Database
### Using Local Installation of MySQL Server
1. Run the following commands after starting the mysql server using
```mysql.server start``` on the CLI or if you are using Docker ```mysql``` Container.  
    Make sure you run it with correct privileges.
2. Run mysql client on the CLI using ```mysql```.  It will take you to the ```mysql>``` prompt.
3. Run the commands below to create database and grant rights to the user

    ```
    mysql> create database flywaydemo; -- Creates the new database
    mysql> create user 'springuser'@'%' identified by 'ThePassword'; -- Creates the user
    mysql> grant all on flywaydemo.* to 'springuser'@'%'; -- Gives all privileges to the new user on the newly created database
    mysql> flush privileges; -- let the rights take effect immediately
    ```
	OR 
	
    Execute the Script:  [01_create_db_and_user.sql](src%2Fmain%2Fresources%2Fset-and-cleanup-db%2F01_create_db_and_user.sql)
	and verify:
	```
	mysql> show databases; 
	+--------------------+
	| Database           |
	+--------------------+
	| flywaydemo         |
	| information_schema |
	| mysql              |
	| ...                |
	| ...                |
	| sys                |
	+--------------------+
	
	mysql> select user, host from mysql.user;
	+------------------+-----------+
	| user             | host      |
	+------------------+-----------+
	| ...              | %         |
	| springuser       | %         |
	| mysql.infoschema | localhost |
	| mysql.session    | localhost |
	| mysql.sys        | localhost |
	| root             | localhost |
	+------------------+-----------+
	```
4. 	Let's look inside the ```flywaydemo``` database.

	```
	mysql> use flywaydemo;
	Database changed
	mysql> show tables;
	Empty set (0.01 sec)
	```

### Using Docker Image of MySQL Server
1. Pull the latest image of MySQL Server ```docker pull mysql/mysql-server:latest```
2. Run the Image:
    1. Using Docker Desktop, Start the image and in the Optional Settings:
       1. Ports section: add ```3306``` against ```3306/tcp```, add ```33060``` against ```33060/tcp```, 
          and add ```33061``` against ```33061/tcp```.
       2. Environmental Variable section: Add 2 environmental variables
          1. ```MYSQL_USER``` ```root```
          2. ```MYSQL_ROOT_PASSWORD``` ```root``` 
       3. In EXEC tab of the running container (which opens a shell),
          create Database and User in the Container by executing steps 2, 3 and 4 from the above [section](#using-local-installation-of-mysql-server)
            ```
            sh> mysql -u root -p
            Enter Password:
            mysql>
            ```
    2. Using the following command on CLI: 
       1. ```docker run -p 3306:3306 -p 33060:33060 -p 33061:33061 --name flywaydemo_container mysql/mysql-server:latest```
       2. Look at the line in the console output for ```[Entrypoint] GENERATED ROOT PASSWORD: <Password>```.  
          Copy that password.
       3. From another terminal, let us connect to the container using shell:
            ```
            docker run -it --rm flywaydemo_container bash
            sh> mysql -u root -p
            Enter Password: <Paste the above generated password>
            mysql> ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';
            mysql> exit
            
            sh> mysql -u root -p
            Enter Password: root
            mysql> 
            ```
       4. Create Database and User in the Container by executing steps 2, 3 and 4 from the above [section](#using-local-installation-of-mysql-server)
       
4. Connect to the Container from CLI on localhost from outside the container:
    ```mysql -h localhost --protocol=tcp -u springuser -p ThePassword```

**NOTE:** Though not advisable, in case you want root access from outside the container, 
you will need to fire the query ```UPDATE mysql.user SET host='%' WHERE user='root';``` from within 
the container ```mysql``` session and then connect from CLI on localhost using ```mysql -h localhost --protocol=tcp -u root -p``` 

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
* This creates the following tables in the ```flywaydemo``` schema

   ```
   mysql> show tables;
   +----------------------+
   | Tables_in_flywaydemo |
   +----------------------+
   | users                |
   | users_seq            |
   +----------------------+
   ```
  
* Describing the two tables gives us:

    ```
    mysql> desc users;
    +---------+--------------+------+-----+---------+-------+
    | Field   | Type         | Null | Key | Default | Extra |
    +---------+--------------+------+-----+---------+-------+
    | id      | bigint       | NO   | PRI | NULL    |       |
    | email   | varchar(255) | YES  |     | NULL    |       |
    | name    | varchar(255) | YES  |     | NULL    |       |
    | version | bigint       | NO   |     | 0       |       |
    +---------+--------------+------+-----+---------+-------+    
    
    mysql> desc users_seq;
    +----------+--------+------+-----+---------+-------+
    | Field    | Type   | Null | Key | Default | Extra |
    +----------+--------+------+-----+---------+-------+
    | next_val | bigint | YES  |     | NULL    |       |
    +----------+--------+------+-----+---------+-------+ 
    ```
  
  * Run ```./gradlew flywayInfo``` and it will give you:
    ```
    Schema version: << Empty Schema >>
    +----------+---------+-------------+------+--------------+-------+----------+
    | Category | Version | Description | Type | Installed On | State | Undoable |
    +----------+---------+-------------+------+--------------+-------+----------+
    | No migrations found                                                       |
    +----------+---------+-------------+------+--------------+-------+----------+
    ```  

  * Run the following shell scripts from ```src/main/resources/shell_scripts``` folder in order:
      1. ```00_create_few_users.sh``` to create few users in the database.
      2. ```01_get_all_users.sh``` to verify that the users are created.
      3. Verify in the database as well:
         ```
         mysql> select * from users;
         +----+------------+------------------------+---------+
         | id | email      | name                   | version |
         +----+------------+------------------------+---------+
         |  1 | B@tsys.com | Brahma Supreme Creator |       0 |
         |  2 | V@tsys.com | Vishnu S. Maintainer   |       0 |
         |  3 | M@tsys.com | Mahesh Destroyer       |       0 |
         +----+------------+------------------------+---------+
         ```
  
* Let's say we now want to deploy this application in production, so we create a sql script, 
  say ```Create_User_Table.sql```  that will be applied to the production database:

    ```
    CREATE TABLE `users` (
      `id` int(11) NOT NULL,
      `email` varchar(255) DEFAULT NULL,
      `name` varchar(255) DEFAULT NULL,
      `version` int(11) NOT NULL DEFAULT 0,
      PRIMARY KEY (`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

    mysql> desc users;
    +---------+--------------+------+-----+---------+-------+
    | Field   | Type         | Null | Key | Default | Extra |
    +---------+--------------+------+-----+---------+-------+
    | id      | bigint       | NO   | PRI | NULL    |       |
    | email   | varchar(255) | YES  |     | NULL    |       |
    | name    | varchar(255) | YES  |     | NULL    |       |
    | version | bigint       | NO   |     | 0       |       |
    +---------+--------------+------+-----+---------+-------+    
    ```
	
* Now, the application can run in production.

## Introducing Flyway
Our journey so far was a standard JPA application with its schema and its deployment using Hibernate.  

Let's first look at how Flyway can be integrated in our existing schema, development and deployment workflow.  
But if you are starting from a clean slate i.e. wanting to introduce Flyway from the beginning of the project, then you 
may want to read the section [Starting from Scratch](#starting-from-scratch) after you finish reading below to get some 
grounding on Flyway first.

1. In the ```application.yaml``` 
	* Enable flyway
	
	    ```
	    flyway:
	        enabled: true
	    ```
   * Also, under the flyway section add

     ```
     flyway:
        table: schema_version
        ```
        This is the internal table that Flyway creates for its book-keeping purposes.

   * Make Hibernate validate the schema automatically or in ```application.properties``` add ```spring.jpa.hibernate.ddl-auto=validate```
    
      ```
         jpa:
          hibernate:
              ddl-auto: validate
      ```
   * As in our case, we already had ```users``` and ```users_seq``` tables, we need to tell 
     Flyway that we already have an existing schema.  We do that with:
     ```
      flyway:
          baseline-on-migrate: true
     ```
      This helps Flyway create the first BASELINE entry when we [baseline schema](#baselining-schema-with-flyway).

2. Now, Run ```./gradlew flywayInfo``` and it will show you that there is no schema and no migrations are found.

	```
    Schema version: << Empty Schema >>
    +----------+---------+-------------+------+--------------+-------+----------+
    | Category | Version | Description | Type | Installed On | State | Undoable |
    +----------+---------+-------------+------+--------------+-------+----------+
    | No migrations found                                                       |
    +----------+---------+-------------+------+--------------+-------+----------+
	```

## Baselining Schema With Flyway
There are 2 ways to Baseline Schema in Flyway, depending on the context.
1. You may simply start the application using ```gradle bootRun```
   * As soon as the application starts, Flyway creates ```schema_version``` table in the schema 
     for it's book-keeping.  
   * Go to the ```mysql``` client and execute:
       ```
       mysql> use flywaydemo;
       mysql> show tables;
       +----------------------+
       | Tables_in_flywaydemo |
       +----------------------+
       | schema_version       |
       | users                |
       | users_seq            |
       +----------------------+
       
       mysql> desc schema_version;
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
    
       mysql> select * from schema_version;
       +----------------+---------+-----------------------+----------+-----------------------+----------+--------------+---------------------+----------------+---------+
       | installed_rank | version | description           | type     | script                | checksum | installed_by | installed_on        | execution_time | success |
       +----------------+---------+-----------------------+----------+-----------------------+----------+--------------+---------------------+----------------+---------+
       |              1 | 1       | << Flyway Baseline >> | BASELINE | << Flyway Baseline >> |     NULL | springuser   | 2024-03-22 20:13:04 |              0 |       1 |
       +----------------+---------+-----------------------+----------+-----------------------+----------+--------------+---------------------+----------------+---------+
       ```
     Hence, Flyway creates that first BASELINE entry as ```baseline-on-migrate``` is set to ```true```. 
   * Run ```./gradlew flywayInfo``` and now it will show you

        ```
        Schema version: 1
        +----------+---------+-----------------------+----------+---------------------+----------+----------+
        | Category | Version | Description           | Type     | Installed On        | State    | Undoable |
        +----------+---------+-----------------------+----------+---------------------+----------+----------+
        |          | 1       | << Flyway Baseline >> | BASELINE | 2024-03-22 20:55:36 | Baseline | No       |
        +----------+---------+-----------------------+----------+---------------------+----------+----------+
        ```
     **NOTE:** If ```baseline-on-migrate``` is set to ```false```, 
               and you start the application first time after Flyway is introduced (no ```schema_version``` table 
               exists), then Flyway detects that Schema already exists as there is no BASELINING done and 
               prevents the application from starting.  You will see an exception trace like this:

        ```
        o.s.boot.SpringApplication               : Application run failed
        org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'flywayInitializer' defined in class path resource [org/springframework/boot/autoconfigure/flyway/FlywayAutoConfiguration$FlywayConfiguration.class]: Found non-empty schema(s) `flywaydemo` but no schema history table. 
        Use baseline() or set baselineOnMigrate to true to initialize the schema history table.
        ```

2. The other way is to run ```./gradlew flywayBaseline``` to create a baseline. This creates a ```schema_version``` table in the database.  You can check the table and the entries in there.
    * Run ```./gradlew flywayInfo``` and now it will show you
        ```
        Schema version: 1
        +----------+---------+-----------------------+----------+---------------------+----------+----------+
        | Category | Version | Description           | Type     | Installed On        | State    | Undoable |
        +----------+---------+-----------------------+----------+---------------------+----------+----------+
        |          | 1       | << Flyway Baseline >> | BASELINE | 2024-03-22 20:55:36 | Baseline | No       |
        +----------+---------+-----------------------+----------+---------------------+----------+----------+
        ```


## Flyway Naming Convention for SQL Migration Scripts
In order that the schema changes for migration are picked-up and applied by Flyway automatically for us, we need to create sql scripts for each new schema change.   
By default, Flyway looks at files in the format ```V$X__$DESCRIPTION.sql```, 
where ```$X``` is the migration version number, in folder ```src/main/resources/db/migration```. 
Make sure you create that folder.

**NOTE:** In earlier versions of Flyway, we used to create a baseline SQL script to Baseline the existing schema:
SQL script ```V1__Baseline.sql``` would have just one line:

```mysql-sql
select now();
```

In order that it need not be picked up by Flyway, prefix two underscores ```__``` before the script ```__V1__Baseline.sql```. 
In case you don't do that, the newer version of Flyway will ignore it even if you have this script. 

## Starting from Scratch
We could have started with a clean slate in the database, but it is very straight forward to introduce Flyway from the 
start of the project. Let's create that starting context.

1. Drop the ```users``` and the ```users_seq``` tables and also ```schema_version``` from the earlier run:
    ```mysql-sql
    mysql> drop table users;
    mysql> drop table users_seq;
    mysql> drop table schema_version;
    ```

2. Rename the script in the folder ```src/main/resources/db/migration``` from 
```__V1__Create_User_Table_And_Hiberate_Sequence_Table.sql```  to
```V1__Create_User_Table_And_Hiberate_Sequence_Table.sql```

3. Make sure you set ```baseline-on-migrate``` to ```false``` in ```application.yaml```
   ```
   flyway:
       baseline-on-migrate: false
   ```
4. Run ```./gradlew flywayInfo``` and now it will show you:
    ```
    Schema version: << Empty Schema >>
    +-----------+---------+-----------------------------------------------+------+--------------+---------+----------+
    | Category  | Version | Description                                   | Type | Installed On | State   | Undoable |
    +-----------+---------+-----------------------------------------------+------+--------------+---------+----------+
    | Versioned | 1       | Create User Table And Hiberate Sequence Table | SQL  |              | Pending | No       |
    +-----------+---------+-----------------------------------------------+------+--------------+---------+----------+
    ```
   Note that the State is ```PENDING```, it is not applied yet.

5. Now, either run ```./gradlew flywayMigrate``` or simply start the application using ```./gradlew bootRun```.  
   This will apply the first migration of creating ```users``` and ```users_seq``` tables and
   raise the schema version to 1.  To verify, run ```./gradlew flywayInfo``` and now it will show you:
    ```
    Schema version: 1
    +-----------+---------+-----------------------------------------------+------+---------------------+---------+----------+
    | Category  | Version | Description                                   | Type | Installed On        | State   | Undoable |
    +-----------+---------+-----------------------------------------------+------+---------------------+---------+----------+
    | Versioned | 1       | Create User Table And Hiberate Sequence Table | SQL  | 2024-03-23 06:56:58 | Success | No       |
    +-----------+---------+-----------------------------------------------+------+---------------------+---------+----------+
    ```
   Note that the State is ```Success```.

6. Go to the ```mysql``` client and execute:
   ```
   mysql> use flywaydemo;
   mysql> show tables;
   +----------------------+
   | Tables_in_flywaydemo |
   +----------------------+
   | schema_version       |
   | users                |
   | users_seq            |
   +----------------------+

   mysql> desc schema_version;
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
    
   mysql> select * from schema_version;
   +----------------+---------+-----------------------------------------------+------+-------------------------------------------------------+------------+--------------+---------------------+----------------+---------+
   | installed_rank | version | description                                   | type | script                                                | checksum   | installed_by | installed_on        | execution_time | success |
   +----------------+---------+-----------------------------------------------+------+-------------------------------------------------------+------------+--------------+---------------------+----------------+---------+
   |              1 | 1       | Create User Table And Hiberate Sequence Table | SQL  | V1__Create_User_Table_And_Hiberate_Sequence_Table.sql | -812994792 | springuser   | 2024-03-23 06:56:58 |             15 |       1 |
   +----------------+---------+-----------------------------------------------+------+-------------------------------------------------------+------------+--------------+---------------------+----------------+---------+
   ```
   
## Adding new Functionality  
#### Story #2: Wish a User on their birthday!
```
When it is user's birthday,
The system will send an email wishing them,
So that he/she feels good.
```

### I. Migrating Schema (DDL) Changes With Flyway 
1. As a part of implementing the story, let us now modify our User to add a ```birthDate``` field 
and the corresponding column in the database would be added automatically 
only-if we were using ```ddl-auto: update```. However, after introducing 
Flyway we have changed it to ```ddl-auto: validate```, and this automatic 
schema change by Hibernate would stop.

2. Add the new ```birthDate``` field in ```User```

    ```java
    public class User {
      @Id
      @GeneratedValue(strategy = GenerationType.AUTO)
      private Long id;
      
      @Version
      private Long version;
          
      private String name;
        
      private String email;
        
      private Date birthdate;
    }
    ```

3. Create a DDL script ```V2__Alter_User_Table_Add_BirthDate_Column.sql```  that alters the ```user``` table and add the birthdate column.  

	```
	ALTER TABLE `users`
	  ADD COLUMN `birthdate` DATETIME DEFAULT NULL;
	```
4. Run ```./gradlew flywayInfo``` and it shows that the new script is pending to be applied to the database

	```
	Schema version: 1
    +-----------+---------+-----------------------------------------------+------+---------------------+---------+----------+
    | Category  | Version | Description                                   | Type | Installed On        | State   | Undoable |
    +-----------+---------+-----------------------------------------------+------+---------------------+---------+----------+
    |           | 1       | << Flyway Baseline >>                         | BASELINE | 2024-03-22 20:55:36 | Baseline | No       |
	| Versioned | 2       | Alter User Table Add BirthDate Column         | SQL      |                     | Pending  |
	+-----------+---------+---------------------------------------+----------+---------------------+----------+
	```
   Woo Hoo! Our first SQL script is under Flyway's versioning scheme.

5. Now, Run ```./gradlew flywayMigrate``` to migrate the schema changes. 
6. To verify that this was also under Flyway, run ```./gradlew flywayInfo```.  It shows that it is at Schema version 2   

	```
	Schema version: 2
	+-----------+---------+---------------------------------------+----------+---------------------+----------+
	| Category  | Version | Description                           | Type     | Installed On        | State    |
	+-----------+---------+---------------------------------------+----------+---------------------+----------+
	|           | 1       | << Flyway Baseline >>                 | BASELINE | 2020-10-21 12:38:26 | Baseline |
	| Versioned | 2       | Alter User Table Add BirthDate Column | SQL      | 2020-10-21 12:52:14 | Success  |
	+-----------+---------+---------------------------------------+----------+---------------------+----------+
	```

7. Verify this column in the user table in the database.

	```
	mysql> desc users;
	+-----------+--------------+------+-----+---------+-------+
	| Field     | Type         | Null | Key | Default | Extra |
	+-----------+--------------+------+-----+---------+-------+
	| id        | bigint       | NO   | PRI | NULL    |       |
	| email     | varchar(255) | YES  |     | NULL    |       |
	| name      | varchar(255) | YES  |     | NULL    |       |
    | version   | bigint       | NO   |     | 0       |       |
	| birthdate | datetime     | YES  |     | NULL    |       |
	+-----------+--------------+------+-----+---------+-------+
    
    mysql> select * from users;
    +----+------------+------------------------+---------+-----------+
    | id | email      | name                   | version | birthdate |
    +----+------------+------------------------+---------+-----------+
    |  1 | B@tsys.com | Brahma Supreme Creator |       0 | NULL      |
    |  2 | V@tsys.com | Vishnu S. Maintainer   |       0 | NULL      |
    |  3 | M@tsys.com | Mahesh Destroyer       |       0 | NULL      |
    +----+------------+------------------------+---------+-----------+
	```
 
8. Verify from the application API by running the script:
    [01_get_all_users.sh](src%2Fmain%2Fresources%2Fshell_scripts%2F01_get_all_users.sh)

### II. Migrating Data (DML) Change with Flyway
We want to set birth date to default zero value.

1. 	Lets create the script ```V3__Set_Birth_Date_To_DefaultZeroValue.sql```  and 
    we make it fail purposely to simulate a failed migration.

2. In the ```V3__Set_Birth_Date_To_DefaultZeroValue.sql``` script disable comments for the block:

    ``` to make it fail purposely:
    -- Wrong way to set date in MySQL (results in failed migration)
     UPDATE `users`
     SET birthdate = '0000-00-00', `version` = `version` + 1
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
    +-----------+---------+-----------------------------------------------+------+---------------------+---------+----------+
    | Category  | Version | Description                                   | Type | Installed On        | State   | Undoable |
    +-----------+---------+-----------------------------------------------+------+---------------------+---------+----------+
    | Versioned | 1       | Create User Table And Hiberate Sequence Table | SQL  | 2024-03-23 13:50:26 | Success | No       |
    | Versioned | 2       | Alter User Table Add BirthDate Column         | SQL  | 2024-03-23 13:50:26 | Success | No       |
    | Versioned | 3       | Set Birth Date To DefaultZeroValue            | SQL  | 2024-03-23 13:50:27 | Failed  | No       |
    +-----------+---------+-----------------------------------------------+------+---------------------+---------+----------+
    ```
   
5. In the ```V3__Set_Birth_Date_To_DefaultZeroValue.sql``` script enable comments for earlier 
  block to ignore it and disable comments for:
  
    ``` 
    -- Correct way to set birth date to start
    UPDATE `users`
    SET birthdate = date('1000-01-01'), `version` = `version` + 1
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
   +-----------+---------+-----------------------------------------------+------+---------------------+---------+----------+
   | Category  | Version | Description                                   | Type | Installed On        | State   | Undoable |
   +-----------+---------+-----------------------------------------------+------+---------------------+---------+----------+
   | Versioned | 1       | Create User Table And Hiberate Sequence Table | SQL  | 2024-03-23 13:50:26 | Success | No       |
   | Versioned | 2       | Alter User Table Add BirthDate Column         | SQL  | 2024-03-23 13:50:26 | Success | No       |
   | Versioned | 3       | Set Birth Date To DefaultZeroValue            | SQL  |                     | Pending | No       |
   +-----------+---------+-----------------------------------------------+------+---------------------+---------+----------+
   ```
9. Run ```./gradlew flywayMigrate``` again to migrate the schema changes.
10. Finally, Run ```./gradlew flywayInfo``` to see the applied changes.

    ```
    Schema version: 3
    +-----------+---------+-----------------------------------------------+------+---------------------+---------+----------+
    | Category  | Version | Description                                   | Type | Installed On        | State   | Undoable |
    +-----------+---------+-----------------------------------------------+------+---------------------+---------+----------+
    | Versioned | 1       | Create User Table And Hiberate Sequence Table | SQL  | 2024-03-23 13:50:26 | Success | No       |
    | Versioned | 2       | Alter User Table Add BirthDate Column         | SQL  | 2024-03-23 13:50:26 | Success | No       |
    | Versioned | 3       | Set Birth Date To DefaultZeroValue            | SQL  | 2024-03-23 15:19:02 | Success | No       |
    +-----------+---------+-----------------------------------------------+------+---------------------+---------+----------+
    ```
    
11. Verify this column in the user table in the database.
    ```
    mysql> select * from users;
    +----+------------+------------------------+---------+---------------------+
    | id | email      | name                   | version | birthdate           |
    +----+------------+------------------------+---------+---------------------+
    |  1 | B@tsys.com | Brahma Supreme Creator |       1 | 1000-01-01 00:00:00 |
    |  2 | V@tsys.com | Vishnu S. Maintainer   |       1 | 1000-01-01 00:00:00 |
    |  3 | M@tsys.com | Mahesh Destroyer       |       1 | 1000-01-01 00:00:00 |
    +----+------------+------------------------+---------+---------------------+
    ```
12. Verify from the application API by running the script:
       [01_get_all_users.sh](src%2Fmain%2Fresources%2Fshell_scripts%2F01_get_all_users.sh)

## Rollback newly added functionality
Let's say that a bug was found in the code, and there is a need to Rollback the jar and it's corresponding
schema (version 3) to earlier version 2.  Can Flyway help with that?

### Using Flyway Undo Scripts
In order that the schema changes for undo are picked-up and applied by Flyway automatically for us, we need to create sql scripts for each undo schema change.  So

By default, Flyway looks at files in the format U$X__$DESCRIPTION.sql, where $X is the undo version number, in folder ```src/main/resources/db/migration```. 

Thus, each migration schema file has a corresponding undo schema file.  Hence, we have 1:1 correspondence between migrate and undo scripts as shown below:

[U2__Alter_User_Table_Add_BirthDate_Column.sql](src%2Fmain%2Fresources%2Fdb%2Fpristine%2FU2__Alter_User_Table_Add_BirthDate_Column.sql)
[V2__Alter_User_Table_Add_BirthDate_Column.sql](src%2Fmain%2Fresources%2Fdb%2Fpristine%2FV2__Alter_User_Table_Add_BirthDate_Column.sql)
[U3__Set_Birth_Date_To_DefaultZeroValue.sql](src%2Fmain%2Fresources%2Fdb%2Fpristine%2FU3__Set_Birth_Date_To_DefaultZeroValue.sql)
[V3__Set_Birth_Date_To_DefaultZeroValue.sql](src%2Fmain%2Fresources%2Fdb%2Fpristine%2FV3__Set_Birth_Date_To_DefaultZeroValue.sql)

**NOTE:** It is a good practice to create both the migration and the undo scripts at the same time.

Run ```./gradlew flywayUndo```, to undo the schema to a particular version.  But when you run this, you get:
```
Execution failed for task ':flywayUndo'.
> Error occurred while executing flywayUndo
  Flyway Redgate Edition Required: undo is not supported by OSS Edition
  Download Redgate Edition for free: https://rd.gt/3GGIXhh
```

1. Either download Flyway binaries for your OS from the above link, place them in the ```bin``` folder and run ```./setup_flyway_cli.sh```.  
   Alternatively, explode and add it to your ```PATH```, so that it is available on your command line.
2. Flyway will look at the project root for picking up ```flyway.conf``` for configuration parameters.  The project 
   root the directory from where we will be running Flyway all the times. 
   I've set-up the file according to the needs of this project.
3. Run ```./flyway list-engines``` to give you the list of supported databases by Flyway.
4. Run ```./flyway info``` or ```./flyway info -X``` to see the debug output.  You should see:
   ```
   Schema version: 3
   +-----------+---------+---------------------------------------+----------+---------------------+----------+----------+
   | Category  | Version | Description                           | Type     | Installed On        | State    | Undoable |
   +-----------+---------+---------------------------------------+----------+---------------------+----------+----------+
   |           | 1       | << Flyway Baseline >>                 | BASELINE | 2024-03-23 15:58:14 | Baseline | No       |
   | Versioned | 2       | Alter User Table Add BirthDate Column | SQL      | 2024-03-25 10:00:54 | Success  | No       |
   | Versioned | 3       | Set Birth Date To DefaultZeroValue    | SQL      | 2024-03-25 10:06:56 | Success  | No       |
   +-----------+---------+---------------------------------------+----------+---------------------+----------+----------+
   ```
5. Now, copy the undo files U2 and U3 corresponding to V2 and V3 migrations respectively from the ```pristine``` into 
   ```migration``` folder and then run ```./flyway info```.  You should see the ```Undoable``` column status change 
   for versions 2 and 3 as ```Yes``` as opposed to earlier ```No```:
    ```
    Schema version: 3
    +-----------+---------+---------------------------------------+----------+---------------------+----------+----------+
    | Category  | Version | Description                           | Type     | Installed On        | State    | Undoable |
    +-----------+---------+---------------------------------------+----------+---------------------+----------+----------+
    |           | 1       | << Flyway Baseline >>                 | BASELINE | 2024-03-23 15:58:14 | Baseline | No       |
    | Versioned | 2       | Alter User Table Add BirthDate Column | SQL      | 2024-03-25 10:00:54 | Success  | Yes      |
    | Versioned | 3       | Set Birth Date To DefaultZeroValue    | SQL      | 2024-03-25 10:06:56 | Success  | Yes      |
    +-----------+---------+---------------------------------------+----------+---------------------+----------+----------+
    ```

6. Now lets undo only the last version 3 using ```./flyway undo -target=3```.  When you do that you may get the following error message, if you have not 
   registered to teams trial:
   ```
   ERROR: Unexpected error
    org.flywaydb.core.internal.license.FlywayEditionUpgradeRequiredException: Teams upgrade required: undo is not supported by Community. If you would like to start a free Teams trial, please run auth -startTeamsTrial -IAgreeToTheEula.
    at org.flywaydb.core.extensibility.LicenseGuard.guard(LicenseGuard.java:62)
    at org.flywaydb.migration.undo.UndoCommandExtension.handle(UndoCommandExtension.java:53)
    at org.flywaydb.core.internal.util.CommandExtensionUtils.lambda$runCommandExtension$1(CommandExtensionUtils.java:32)
    at java.base/java.util.Optional.map(Unknown Source)
    at org.flywaydb.core.internal.util.CommandExtensionUtils.runCommandExtension(CommandExtensionUtils.java:32)
    at org.flywaydb.commandline.Main.executeOperation(Main.java:294)
    at org.flywaydb.commandline.Main.executeFlyway(Main.java:171)
    at org.flywaydb.commandline.Main.main(Main.java:114)
   ```
7. Run ```./flyway auth -startTeamsTrial -IAgreeToTheEul``` and do the needful to get the License key in your email.
8. Run ```./flyway undo -target=3 -X```
    ```
    Flyway Teams Edition 10.10.0 by Redgate
    Licensed to ...
    Licensed until ...
    WARNING: You are using a limited Flyway trial license, valid until 2024-04-24. In 29 days you must either upgrade to a full Teams license or downgrade to Community.
    
    Current version of schema `flywaydemo`: 3
    Undoing migration of schema `flywaydemo` to version 3 - Set Birth Date To DefaultZeroValue
    Successfully undid 1 migration to schema `flywaydemo`, now at version v2 (execution time 00:00.097s)
    ```
9. Run ```./flyway info```
    ```
    Flyway Teams Edition 10.10.0 by Redgate
    Licensed to ...
    Licensed until ...
    WARNING: You are using a limited Flyway trial license, valid until 2024-04-24. In 29 days you must either upgrade to a full Teams license or downgrade to Community.
    
    Schema version: 2
    +-----------+---------+---------------------------------------+----------+---------------------+----------+----------+
    | Category  | Version | Description                           | Type     | Installed On        | State    | Undoable |
    +-----------+---------+---------------------------------------+----------+---------------------+----------+----------+
    |           | 1       | << Flyway Baseline >>                 | BASELINE | 2024-03-23 15:58:14 | Baseline | No       |
    | Versioned | 2       | Alter User Table Add BirthDate Column | SQL      | 2024-03-25 10:00:54 | Success  | Yes      |
    | Versioned | 3       | Set Birth Date To DefaultZeroValue    | SQL      | 2024-03-25 10:06:56 | Undone   |          |
    | Versioned | 3       | Set Birth Date To DefaultZeroValue    | SQL      |                     | Pending  | Yes      |
    +-----------+---------+---------------------------------------+----------+---------------------+----------+----------+
    ```
    
    and check the mysql database:
    ```
    mysql> select * from users;
    +----+------------+------------------------+---------+-----------+
    | id | email      | name                   | version | birthdate |
    +----+------------+------------------------+---------+-----------+
    |  1 | B@tsys.com | Brahma Supreme Creator |       0 | NULL      |
    |  2 | V@tsys.com | Vishnu S. Maintainer   |       0 | NULL      |
    |  3 | M@tsys.com | Mahesh Destroyer       |       0 | NULL      |
    +----+------------+------------------------+---------+-----------+
    ```  

10. Verify from the application API by running the script:
        [01_get_all_users.sh](src%2Fmain%2Fresources%2Fshell_scripts%2F01_get_all_users.sh)

11. Let's rollback one more version: Run ```./flyway undo target=2```
    ```
    Flyway Teams Edition 10.10.0 by Redgate
    Licensed to ...
    Licensed until ...
    WARNING: You are using a limited Flyway trial license, valid until 2024-04-24. In 29 days you must either upgrade to a full Teams license or downgrade to Community.

    Current version of schema `flywaydemo`: 2
    Undoing migration of schema `flywaydemo` to version 2 - Alter User Table Add BirthDate Column
    Successfully undid 1 migration to schema `flywaydemo`, now at version v1 (execution time 00:00.102s)
    ```
    and now run ```./flyway info```, you should see:

    ```
    Flyway Teams Edition 10.10.0 by Redgate
    Licensed to ...
    Licensed until ...
    WARNING: You are using a limited Flyway trial license, valid until 2024-04-24. In 29 days you must either upgrade to a full Teams license or downgrade to Community.
    
    Schema version: 1
    +-----------+---------+---------------------------------------+----------+---------------------+----------+----------+
    | Category  | Version | Description                           | Type     | Installed On        | State    | Undoable |
    +-----------+---------+---------------------------------------+----------+---------------------+----------+----------+
    |           | 1       | << Flyway Baseline >>                 | BASELINE | 2024-03-23 15:58:14 | Baseline | No       |
    | Versioned | 2       | Alter User Table Add BirthDate Column | SQL      | 2024-03-25 10:00:54 | Undone   |          |
    | Versioned | 3       | Set Birth Date To DefaultZeroValue    | SQL      | 2024-03-25 10:06:56 | Undone   |          |
    | Versioned | 2       | Alter User Table Add BirthDate Column | SQL      |                     | Pending  | Yes      |
    | Versioned | 3       | Set Birth Date To DefaultZeroValue    | SQL      |                     | Pending  | Yes      |
    +-----------+---------+---------------------------------------+----------+---------------------+----------+----------+
    ```
    
    and Check the mysql database: 
    ```
    mysql> select * from users;
    +----+------------+------------------------+---------+
    | id | email      | name                   | version |
    +----+------------+------------------------+---------+
    |  1 | B@tsys.com | Brahma Supreme Creator |       0 |
    |  2 | V@tsys.com | Vishnu S. Maintainer   |       0 |
    |  3 | M@tsys.com | Mahesh Destroyer       |       0 |
    +----+------------+------------------------+---------+
    ```
    
12. Verify from the application API by running the script:
    [01_get_all_users.sh](src%2Fmain%2Fresources%2Fshell_scripts%2F01_get_all_users.sh)

## Implement the database part of the Story

```
When an approval/rejection is made
the system sends confirmation email to the user,
So that the system can comply with government regulatory requirements.
```

Currently, the Name field contains names in the format - ```<first name> [middle name or initial] <last name>```.  This
needs to be split into 3 fields in the database to implement the above story as the confirmation message
greets the user with first name only, though all the details exist.  In order to do this,

You will need to modify the User object to include a domain rich abstraction - ```Name``` already provided
in the ```com.tsys.springflyway.model``` package.  Accordingly modify the existing database schema and data to implement
this story.  After implementation of the story, you will need to remove the old ```name``` column from the 
database - contraction phase.  Accordingly, use Flyway to achieve both the expansion and contraction of the schema and 
data integrity.

```java
import jakarta.persistence.Embedded;

@Entity
public class User {
  @Id
  @GeneratedValue(strategy = GenerationType.AUTO)
  private Long id;

  @Version
  private Long version;
  
  @Embedded
  private Name name;

  private String email;

  private Date birthdate;
}
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

