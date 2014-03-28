# ************************************************************
# Sequel Pro SQL dump
# Version 4096
#
# http://www.sequelpro.com/
# http://code.google.com/p/sequel-pro/
#
# Host: 127.0.0.1 (MySQL 5.6.16)
# Database: minicron
# Generation Time: 2014-03-28 07:49:15 +0000
# ************************************************************


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


# Dump of table executions
# ------------------------------------------------------------

CREATE TABLE `executions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `started_at` datetime DEFAULT NULL,
  `finished_at` datetime DEFAULT NULL,
  `exit_status` int(11) DEFAULT NULL,
  `alert_sent` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `created_at` (`created_at`),
  KEY `finished_at` (`finished_at`),
  KEY `job_id` (`job_id`),
  KEY `started_at` (`started_at`),
  KEY `alert_sent` (`alert_sent`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table hosts
# ------------------------------------------------------------

CREATE TABLE `hosts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `fqdn` varchar(255) NOT NULL DEFAULT '',
  `host` varchar(255) NOT NULL DEFAULT '',
  `port` int(11) NOT NULL DEFAULT '22',
  `public_key` text,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `hostname` (`fqdn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table job_execution_outputs
# ------------------------------------------------------------

CREATE TABLE `job_execution_outputs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `execution_id` int(11) NOT NULL,
  `seq` int(11) NOT NULL,
  `output` text NOT NULL,
  `timestamp` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `execution_id` (`execution_id`),
  KEY `seq` (`seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table jobs
# ------------------------------------------------------------

CREATE TABLE `jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job_hash` varchar(32) NOT NULL DEFAULT '',
  `name` varchar(255) DEFAULT NULL,
  `command` text NOT NULL,
  `host_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `job_hash` (`job_hash`),
  KEY `created_at` (`created_at`),
  KEY `host_id` (`host_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table schedules
# ------------------------------------------------------------

CREATE TABLE `schedules` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job_id` int(11) NOT NULL,
  `minute` varchar(179) DEFAULT NULL,
  `hour` varchar(71) DEFAULT NULL,
  `day_of_the_month` varchar(92) DEFAULT NULL,
  `month` varchar(25) DEFAULT NULL,
  `day_of_the_week` varchar(20) DEFAULT NULL,
  `special` varchar(9) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `day_of_the_month` (`day_of_the_month`),
  KEY `day_of_the_week` (`day_of_the_week`),
  KEY `hour` (`hour`),
  KEY `job_id` (`job_id`),
  KEY `minute` (`minute`),
  KEY `month` (`month`),
  KEY `special` (`special`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table schema_migrations
# ------------------------------------------------------------

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;




/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
