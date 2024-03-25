ALTER TABLE `users` DROP COLUMN `birthdate`;

-- WARNING:
-- If you try to manually rollback it fails miserably, because Flyway implements
-- checksum mechanism to detect manual intervention.  Hence, you should never tun this
-- line below manually.  LET THE TOOL DO THIS FOR YOU!
-- DELETE FROM schema_version WHERE installed_rank=2;