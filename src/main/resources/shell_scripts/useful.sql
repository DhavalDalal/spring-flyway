show databases;

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
