CREATE TABLE `fe_areas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fe_run_id` int(11) DEFAULT NULL,
  `label` varchar(255) DEFAULT NULL,
  `category` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1795157272 DEFAULT CHARSET=utf8;

CREATE TABLE `fe_engagements` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fe_run_id` int(11) DEFAULT NULL,
  `fe_launcher_id` int(11) DEFAULT NULL,
  `fe_threat_id` int(11) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1642706487 DEFAULT CHARSET=utf8;

CREATE TABLE `fe_interceptors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fe_run_id` int(11) DEFAULT NULL,
  `label` varchar(255) DEFAULT NULL,
  `category` varchar(255) DEFAULT NULL,
  `fe_engagement_id` int(11) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1100307657 DEFAULT CHARSET=utf8;

CREATE TABLE `fe_launchers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fe_run_id` int(11) DEFAULT NULL,
  `label` varchar(255) DEFAULT NULL,
  `category` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=858127133 DEFAULT CHARSET=utf8;

CREATE TABLE `fe_runs` (
  `id` int(11) DEFAULT NULL,
  `mp_scenario_id` int(11) DEFAULT NULL,
  `mp_tewa_configuration_id` int(11) DEFAULT NULL,
  `first_frame` int(11) DEFAULT NULL,
  `last_frame` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `mps_idp_name` varchar(255) DEFAULT '',
  `mps_sg_name` varchar(255) DEFAULT '',
  `mptc_name` varchar(255) DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `fe_threats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fe_run_id` int(11) DEFAULT NULL,
  `label` varchar(255) DEFAULT NULL,
  `category` varchar(255) DEFAULT NULL,
  `target_area_id` int(11) DEFAULT NULL,
  `source_area_id` int(11) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=901799964 DEFAULT CHARSET=utf8;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO schema_migrations (version) VALUES ('20100426205721');

INSERT INTO schema_migrations (version) VALUES ('20100426222425');

INSERT INTO schema_migrations (version) VALUES ('20100426222540');

INSERT INTO schema_migrations (version) VALUES ('20100426222608');

INSERT INTO schema_migrations (version) VALUES ('20100426222710');

INSERT INTO schema_migrations (version) VALUES ('20100426222800');

INSERT INTO schema_migrations (version) VALUES ('20100712175744');