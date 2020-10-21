-- Existing Table with 3 columns id, email and name
CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `hibernate_sequence` (
  `next_val` bigint DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO hibernate_sequence (next_val) VALUES (1);

--------------------------------------------------------------------
-- UNDO Script
--------------------------------------------------------------------
-- DROP TABLE `users`;
-- DROP TABLE `hibernate_sequence`;
-- DELETE FROM flyway_schema_history WHERE installed_rank=0;