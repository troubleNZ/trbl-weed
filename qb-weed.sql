CREATE TABLE IF NOT EXISTS `house_plants` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `building` varchar(50) DEFAULT NULL,
  `stage` varchar(50) DEFAULT 'stage-a',
  `sort` varchar(50) DEFAULT NULL,
  `gender` varchar(50) DEFAULT NULL,
  `food` int(11) DEFAULT 100,
  `health` int(11) DEFAULT 100,
  `progress` int(11) DEFAULT 0,
  `coords` text DEFAULT NULL,
  `plantid` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `building` (`building`),
  KEY `plantid` (`plantid`)
) ENGINE=InnoDB AUTO_INCREMENT=7123 DEFAULT CHARSET=utf8mb4;

CREATE TABLE `outdoor_plants` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`citizenid` VARCHAR(10) NULL DEFAULT NULL,
	`stage` VARCHAR(50) NULL DEFAULT 'stage-a',
	`sort` VARCHAR(50) NULL DEFAULT NULL,
	`gender` VARCHAR(50) NULL DEFAULT NULL,
	`food` INT(11) NULL DEFAULT 100,
	`health` INT(11) NULL DEFAULT 100,
	`progress` INT(11) NULL DEFAULT 0,
	`coords` TEXT NULL DEFAULT NULL,
	`plantid` VARCHAR(50) NULL DEFAULT NULL,
	PRIMARY KEY (`id`),
	INDEX `owner` (`citizenid`),
	INDEX `plantid` (`plantid`)
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=2
;