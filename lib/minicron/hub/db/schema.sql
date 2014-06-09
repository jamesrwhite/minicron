# ************************************************************
# Sequel Pro SQL dump
# Version 4096
#
# http://www.sequelpro.com/
# http://code.google.com/p/sequel-pro/
#
# Host: 127.0.0.1 (MySQL 5.6.17)
# Database: minicron
# Generation Time: 2014-05-19 00:33:32 +0000
# ************************************************************


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


# Dump of table alerts
# ------------------------------------------------------------

DROP TABLE IF EXISTS `alerts`;

CREATE TABLE `alerts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job_id` int(11) NOT NULL,
  `execution_id` int(11) DEFAULT NULL,
  `schedule_id` int(11) DEFAULT NULL,
  `kind` varchar(4) NOT NULL DEFAULT '',
  `expected_at` datetime DEFAULT NULL,
  `medium` varchar(9) NOT NULL DEFAULT '',
  `sent_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `alerts_execution_id` (`execution_id`) USING BTREE,
  KEY `expected_at` (`expected_at`) USING BTREE,
  KEY `kind` (`kind`) USING BTREE,
  KEY `medium` (`medium`) USING BTREE,
  KEY `schedule_id` (`schedule_id`) USING BTREE,
  KEY `alerts_job_id` (`job_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table executions
# ------------------------------------------------------------

DROP TABLE IF EXISTS `executions`;

CREATE TABLE `executions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job_id` int(11) NOT NULL,
  `number` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `started_at` datetime DEFAULT NULL,
  `finished_at` datetime DEFAULT NULL,
  `exit_status` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_number_per_job` (`job_id`,`number`),
  KEY `executions_created_at` (`created_at`) USING BTREE,
  KEY `finished_at` (`finished_at`) USING BTREE,
  KEY `executions_job_id` (`job_id`) USING BTREE,
  KEY `started_at` (`started_at`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table hosts
# ------------------------------------------------------------

DROP TABLE IF EXISTS `hosts`;

CREATE TABLE `hosts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `fqdn` varchar(255) NOT NULL DEFAULT '',
  `user` varchar(32) NOT NULL DEFAULT '',
  `host` varchar(255) NOT NULL DEFAULT '',
  `port` int(11) NOT NULL,
  `public_key` text,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `hostname` (`fqdn`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table job_execution_outputs
# ------------------------------------------------------------

DROP TABLE IF EXISTS `job_execution_outputs`;

CREATE TABLE `job_execution_outputs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `execution_id` int(11) NOT NULL,
  `seq` int(11) NOT NULL,
  `output` text NOT NULL,
  `timestamp` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `job_execution_outputs_execution_id` (`execution_id`) USING BTREE,
  KEY `seq` (`seq`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table jobs
# ------------------------------------------------------------

DROP TABLE IF EXISTS `jobs`;

CREATE TABLE `jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `host_id` int(11) NOT NULL,
  `job_hash` varchar(32) NOT NULL DEFAULT '',
  `name` varchar(255) DEFAULT NULL,
  `user` varchar(32) NOT NULL,
  `command` text NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `job_hash` (`job_hash`) USING BTREE,
  KEY `jobs_created_at` (`created_at`) USING BTREE,
  KEY `host_id` (`host_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table schedules
# ------------------------------------------------------------

DROP TABLE IF EXISTS `schedules`;

CREATE TABLE `schedules` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job_id` int(11) NOT NULL,
  `minute` varchar(169) DEFAULT NULL,
  `hour` varchar(61) DEFAULT NULL,
  `day_of_the_month` varchar(83) DEFAULT NULL,
  `month` varchar(26) DEFAULT NULL,
  `day_of_the_week` varchar(13) DEFAULT NULL,
  `special` varchar(9) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `day_of_the_month` (`day_of_the_month`) USING BTREE,
  KEY `day_of_the_week` (`day_of_the_week`) USING BTREE,
  KEY `hour` (`hour`) USING BTREE,
  KEY `schedules_job_id` (`job_id`) USING BTREE,
  KEY `minute` (`minute`) USING BTREE,
  KEY `month` (`month`) USING BTREE,
  KEY `special` (`special`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table schema_migrations
# ------------------------------------------------------------

DROP TABLE IF EXISTS `schema_migrations`;




/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
