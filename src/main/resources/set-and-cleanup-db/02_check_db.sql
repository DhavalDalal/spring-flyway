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
-- +----------------------+
-- | Tables_in_flywaydemo |
-- +----------------------+
-- | schema_version       |
-- | users                |
-- | users_seq            |
-- +----------------------+

desc users;
--  +---------+--------------+------+-----+---------+-------+
--  | Field   | Type         | Null | Key | Default | Extra |
--  +---------+--------------+------+-----+---------+-------+
--  | id      | bigint       | NO   | PRI | NULL    |       |
--  | email   | varchar(255) | YES  |     | NULL    |       |
--  | name    | varchar(255) | YES  |     | NULL    |       |
--  | version | bigint       | NO   |     | 0       |       |
--  +---------+--------------+------+-----+---------+-------+

desc users_seq;

--  +----------+--------+------+-----+---------+-------+
--  | Field    | Type   | Null | Key | Default | Extra |
--  +----------+--------+------+-----+---------+-------+
--  | next_val | bigint | YES  |     | NULL    |       |
--  +----------+--------+------+-----+---------+-------+

-- To get Create table statement of a table in MySQL
SHOW CREATE TABLE users_seq;

CREATE TABLE `users_seq` (
  `next_val` bigint DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci |

desc schema_version;
-- +----------------+---------------+------+-----+-------------------+-------------------+
-- | Field          | Type          | Null | Key | Default           | Extra             |
-- +----------------+---------------+------+-----+-------------------+-------------------+
-- | installed_rank | int           | NO   | PRI | NULL              |                   |
-- | version        | varchar(50)   | YES  |     | NULL              |                   |
-- | description    | varchar(200)  | NO   |     | NULL              |                   |
-- | type           | varchar(20)   | NO   |     | NULL              |                   |
-- | script         | varchar(1000) | NO   |     | NULL              |                   |
-- | checksum       | int           | YES  |     | NULL              |                   |
-- | installed_by   | varchar(100)  | NO   |     | NULL              |                   |
-- | installed_on   | timestamp     | NO   |     | CURRENT_TIMESTAMP | DEFAULT_GENERATED |
-- | execution_time | int           | NO   |     | NULL              |                   |
-- | success        | tinyint(1)    | NO   | MUL | NULL              |                   |
-- +----------------+---------------+------+-----+-------------------+-------------------+

SHOW CREATE TABLE schema_version;

CREATE TABLE `schema_version` (
  `installed_rank` int NOT NULL,
  `version` varchar(50) DEFAULT NULL,
  `description` varchar(200) NOT NULL,
  `type` varchar(20) NOT NULL,
  `script` varchar(1000) NOT NULL,
  `checksum` int DEFAULT NULL,
  `installed_by` varchar(100) NOT NULL,
  `installed_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `execution_time` int NOT NULL,
  `success` tinyint(1) NOT NULL,
  PRIMARY KEY (`installed_rank`),
  KEY `schema_version_s_idx` (`success`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * from users;
--  +----+--------------+--------+
--  | id | email        | name   |
--  +----+--------------+--------+
--  |  1 | B@Brahma.com | Brahma |
--  |  2 | V@Vishnu.com | Vishnu |
--  |  3 | M@Mahesh.com | Mahesh |
--  +----+--------------+--------+


select * from schema_version;
-- +----------------+---------+-----------------------+----------+-----------------------+----------+--------------+---------------------+----------------+---------+
-- | installed_rank | version | description           | type     | script                | checksum | installed_by | installed_on        | execution_time | success |
-- +----------------+---------+-----------------------+----------+-----------------------+----------+--------------+---------------------+----------------+---------+
-- |              1 | 1       | << Flyway Baseline >> | BASELINE | << Flyway Baseline >> |     NULL | springuser   | 2024-03-22 19:12:30 |              0 |       1 |
-- +----------------+---------+-----------------------+----------+-----------------------+----------+--------------+---------------------+----------------+---------+

drop table users_seq;
drop table users;
drop table schema_version;


desc users;
--+-----------+--------------+------+-----+---------+-------+
--| Field     | Type         | Null | Key | Default | Extra |
--+-----------+--------------+------+-----+---------+-------+
--| id        | int          | NO   | PRI | NULL    |       |
--| version   | int          | NO   |     | NULL    |       |
--| email     | varchar(255) | YES  |     | NULL    |       |
--| name      | varchar(255) | YES  |     | NULL    |       |
--| birthdate | datetime     | YES  |     | NULL    |       |
--+-----------+--------------+------+-----+---------+-------+
