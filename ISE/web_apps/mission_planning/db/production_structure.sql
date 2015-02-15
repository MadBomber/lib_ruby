CREATE TABLE `mp_batteries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `desc` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1762554556 DEFAULT CHARSET=utf8;

CREATE TABLE `mp_battery_configurations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `mp_battery_id` int(11) NOT NULL,
  `mp_launcher_id` int(11) NOT NULL,
  `mp_launcher_qty` int(11) NOT NULL DEFAULT '8',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1601665677 DEFAULT CHARSET=utf8;

CREATE TABLE `mp_interceptors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `desc` varchar(255) DEFAULT NULL,
  `pk_air` int(11) NOT NULL DEFAULT '100',
  `pk_space` int(11) NOT NULL DEFAULT '100',
  `velocity` int(11) NOT NULL DEFAULT '5000',
  `cost` int(11) NOT NULL DEFAULT '0',
  `eng_zone_scale_air` int(11) NOT NULL DEFAULT '1',
  `eng_zone_scale_space` int(11) NOT NULL DEFAULT '1',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `max_range_meters` int(11) DEFAULT '5000',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1985236339 DEFAULT CHARSET=utf8;

CREATE TABLE `mp_launcher_doctrines` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `desc` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1704768651 DEFAULT CHARSET=utf8;

CREATE TABLE `mp_launchers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `desc` varchar(255) DEFAULT NULL,
  `mp_interceptor_id` int(11) NOT NULL,
  `mp_interceptor_qty` int(11) NOT NULL DEFAULT '4',
  `abt_doctrine_id` int(11) NOT NULL,
  `tbm_doctrine_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1738076577 DEFAULT CHARSET=utf8;

CREATE TABLE `mp_scenarios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `desc` varchar(255) DEFAULT NULL,
  `idp_name` varchar(255) NOT NULL,
  `sg_name` varchar(255) NOT NULL,
  `executed_at` datetime DEFAULT NULL,
  `ise_guid` varchar(255) DEFAULT NULL,
  `selected` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `random_threat_count` int(11) DEFAULT '0',
  `auto_engage_tbm` tinyint(1) DEFAULT '0',
  `auto_engage_abt` tinyint(1) DEFAULT '0',
  `man_in_the_loop` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2114008841 DEFAULT CHARSET=utf8;

CREATE TABLE `mp_tewa_configurations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `desc` varchar(255) DEFAULT NULL,
  `doctrine` tinyint(1) NOT NULL DEFAULT '1',
  `selected` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=694016772 DEFAULT CHARSET=utf8;

CREATE TABLE `mp_tewa_factors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `desc` varchar(255) DEFAULT NULL,
  `category` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2042869307 DEFAULT CHARSET=utf8;

CREATE TABLE `mp_tewa_values` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `mp_tewa_factor_id` int(11) NOT NULL,
  `mp_tewa_configuration_id` int(11) NOT NULL,
  `value` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2146146363 DEFAULT CHARSET=utf8;

CREATE TABLE `mp_threats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `desc` varchar(255) DEFAULT NULL,
  `track_category` varchar(255) NOT NULL DEFAULT 'space',
  `effects_radius` float NOT NULL DEFAULT '1',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1679453423 DEFAULT CHARSET=utf8;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO schema_migrations (version) VALUES ('20100322150827');

INSERT INTO schema_migrations (version) VALUES ('20100322150844');

INSERT INTO schema_migrations (version) VALUES ('20100322150857');

INSERT INTO schema_migrations (version) VALUES ('20100322150905');

INSERT INTO schema_migrations (version) VALUES ('20100322150947');

INSERT INTO schema_migrations (version) VALUES ('20100322151031');

INSERT INTO schema_migrations (version) VALUES ('20100322151038');

INSERT INTO schema_migrations (version) VALUES ('20100322151055');

INSERT INTO schema_migrations (version) VALUES ('20100322194409');

INSERT INTO schema_migrations (version) VALUES ('20100322220501');

INSERT INTO schema_migrations (version) VALUES ('20100613201146');

INSERT INTO schema_migrations (version) VALUES ('20100615222358');

INSERT INTO schema_migrations (version) VALUES ('20100617163459');

INSERT INTO schema_migrations (version) VALUES ('20100624161337');

INSERT INTO schema_migrations (version) VALUES ('20101129150303');