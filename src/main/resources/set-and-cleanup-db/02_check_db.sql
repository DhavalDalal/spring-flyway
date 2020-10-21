show databases;
--  +--------------------+
--  | Database           |
--  +--------------------+
--  | flywaydemo         |
--  | information_schema |
--  | mysql              |
--  | performance_schema |
--  | sys                |
--  +--------------------+

use flywaydemo;
--  Database changed

show tables;
--  +----------------------+
--  | Tables_in_flywaydemo |
--  +----------------------+
--  | hibernate_sequence   |
--  | schema_version       |
--  | users                |
--  +----------------------+

desc users;

--  +-------+--------------+------+-----+---------+-------+
--  | Field | Type         | Null | Key | Default | Extra |
--  +-------+--------------+------+-----+---------+-------+
--  | id    | int          | NO   | PRI | NULL    |       |
--  | email | varchar(255) | YES  |     | NULL    |       |
--  | name  | varchar(255) | YES  |     | NULL    |       |
--  +-------+--------------+------+-----+---------+-------+

desc hibernate_sequence;

--  +----------+--------+------+-----+---------+-------+
--  | Field    | Type   | Null | Key | Default | Extra |
--  +----------+--------+------+-----+---------+-------+
--  | next_val | bigint | YES  |     | NULL    |       |
--  +----------+--------+------+-----+---------+-------+

-- To get Create table statement of a table in MySQL
SHOW CREATE TABLE hibernate_sequence;

CREATE TABLE `hibernate_sequence` (
  `next_val` bigint DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci |

select * from users;
--  +----+--------------+--------+
--  | id | email        | name   |
--  +----+--------------+--------+
--  |  1 | B@Brahma.com | Brahma |
--  |  2 | V@Vishnu.com | Vishnu |
--  |  3 | M@Mahesh.com | Mahesh |
--  +----+--------------+--------+


desc schema_version;
--  +----------------+---------------+------+-----+-------------------+-------------------+
--  | Field          | Type          | Null | Key | Default           | Extra             |
--  +----------------+---------------+------+-----+-------------------+-------------------+
--  | installed_rank | int           | NO   | PRI | NULL              |                   |
--  | version        | varchar(50)   | YES  |     | NULL              |                   |
--  | description    | varchar(200)  | NO   |     | NULL              |                   |
--  | type           | varchar(20)   | NO   |     | NULL              |                   |
--  | script         | varchar(1000) | NO   |     | NULL              |                   |
--  | checksum       | int           | YES  |     | NULL              |                   |
--  | installed_by   | varchar(100)  | NO   |     | NULL              |                   |
--  | installed_on   | timestamp     | NO   |     | CURRENT_TIMESTAMP | DEFAULT_GENERATED |
--  | execution_time | int           | NO   |     | NULL              |                   |
--  | success        | tinyint(1)    | NO   | MUL | NULL              |                   |
--  +----------------+---------------+------+-----+-------------------+-------------------+

drop table hibernate_sequence;
drop table schema_version;
drop table users;


desc users;
--+-----------+--------------+------+-----+---------+-------+
--| Field     | Type         | Null | Key | Default | Extra |
--+-----------+--------------+------+-----+---------+-------+
--| id        | int          | NO   | PRI | NULL    |       |
--| email     | varchar(255) | YES  |     | NULL    |       |
--| name      | varchar(255) | YES  |     | NULL    |       |
--| birthdate | datetime     | YES  |     | NULL    |       |
--+-----------+--------------+------+-----+---------+-------+
