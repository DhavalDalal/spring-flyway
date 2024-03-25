-- Wrong way to set date in MySQL (results in failed migration)
UPDATE `users`
SET birthdate = '0000-00-00', `version` = `version` + 1
WHERE birthdate is null;

-- Correct way to set birth date to start
--UPDATE `users`
--SET birthdate = date('1000-01-01'), `version` = `version` + 1
--WHERE birthdate is null;