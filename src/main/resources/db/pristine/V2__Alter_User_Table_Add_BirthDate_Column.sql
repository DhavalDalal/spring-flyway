ALTER TABLE `users`
  ADD COLUMN `birthdate` DATETIME DEFAULT NULL;

--------------------------------------------------------------------
-- UNDO Script
--------------------------------------------------------------------
-- ALTER TABLE `users` DROP COLUMN `birthdate`;

-- DELETE FROM flyway_schema_history WHERE installed_rank=2;