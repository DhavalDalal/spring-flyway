-- Delete the database
drop database flywaydemo;

select user, host from mysql.user;
-- +------------------+-----------+
-- | user             | host      |
-- +------------------+-----------+
-- | springuser       | %         |
-- | mysql.infoschema | localhost |
-- | mysql.session    | localhost |
-- | mysql.sys        | localhost |
-- | root             | localhost |
-- +------------------+-----------+

-- Drop the user,
-- NOTE: Don't use delete from mysql.user where user = 'springuser';
DROP USER 'springuser'@'%';

FLUSH PRIVILEGES;

select user, host from mysql.user;
-- +------------------+-----------+
-- | user             | host      |
-- +------------------+-----------+
-- | mysql.infoschema | localhost |
-- | mysql.session    | localhost |
-- | mysql.sys        | localhost |
-- | root             | localhost |
-- +------------------+-----------+
