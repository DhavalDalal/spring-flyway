-- Wrong way to set date in MySQL (results in failed migration)
-- UPDATE `users`
-- SET birthdate = '0000-00-00'
-- WHERE birthdate is null;

-- Correct way to set birth date to start
UPDATE `users`
SET birthdate = date('1000-01-01')
WHERE birthdate is null;

--------------------------------------------------------------------
-- UNDO Script
--------------------------------------------------------------------
-- UPDATE `users`
-- SET birthdate = null
-- WHERE birthdate is not null;

-- delete from flyway_schema_history where installed_rank=3;