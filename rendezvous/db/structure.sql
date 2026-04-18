/*M!999999\- enable the sandbox mode */ 

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `active_storage_attachments` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `record_type` varchar(255) NOT NULL,
  `record_id` bigint NOT NULL,
  `blob_id` bigint NOT NULL,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_active_storage_attachments_uniqueness` (`record_type`,`record_id`,`name`,`blob_id`),
  KEY `index_active_storage_attachments_on_blob_id` (`blob_id`),
  CONSTRAINT `fk_rails_c3b3935057` FOREIGN KEY (`blob_id`) REFERENCES `active_storage_blobs` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=342 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `active_storage_blobs` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `key` varchar(255) NOT NULL,
  `filename` varchar(255) NOT NULL,
  `content_type` varchar(255) DEFAULT NULL,
  `metadata` text,
  `service_name` varchar(255) NOT NULL,
  `byte_size` bigint NOT NULL,
  `checksum` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_active_storage_blobs_on_key` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=342 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `active_storage_variant_records` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `blob_id` bigint NOT NULL,
  `variation_digest` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_active_storage_variant_records_uniqueness` (`blob_id`,`variation_digest`),
  CONSTRAINT `fk_rails_993965df05` FOREIGN KEY (`blob_id`) REFERENCES `active_storage_blobs` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `annual_questions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `year` int DEFAULT NULL,
  `question` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_annual_questions_on_year` (`year`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ar_internal_metadata` (
  `key` varchar(255) NOT NULL,
  `value` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `attendees` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `attendee_age` varchar(255) DEFAULT 'adult',
  `volunteer` tinyint(1) DEFAULT NULL,
  `sunday_dinner` tinyint(1) DEFAULT NULL,
  `registration_id` int DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_attendees_on_attendee_age` (`attendee_age`),
  KEY `index_attendees_on_volunteer` (`volunteer`),
  KEY `index_attendees_on_sunday_dinner` (`sunday_dinner`)
) ENGINE=InnoDB AUTO_INCREMENT=1869 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ballot_selections` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `ballot_id` bigint DEFAULT NULL,
  `votable_type` varchar(255) NOT NULL,
  `votable_id` bigint NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_ballot_selections_on_ballot_id` (`ballot_id`),
  KEY `index_ballot_selections_on_votable` (`votable_type`,`votable_id`),
  CONSTRAINT `fk_rails_5689a3c016` FOREIGN KEY (`ballot_id`) REFERENCES `ballots` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=76 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ballots` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `year` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `voter_id` varchar(36) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_ballots_on_year` (`year`),
  KEY `index_ballots_on_voter_id` (`voter_id`)
) ENGINE=InnoDB AUTO_INCREMENT=231 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cart_items` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `merchitem_id` bigint DEFAULT NULL,
  `purchase_id` bigint DEFAULT NULL,
  `number` int DEFAULT '1',
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_cart_items_on_merchitem_id` (`merchitem_id`),
  KEY `index_cart_items_on_purchase_id` (`purchase_id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `donations` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `registration_id` int DEFAULT NULL,
  `date` date DEFAULT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `amount` decimal(6,2) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `created_by_admin` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_donations_on_user_id` (`user_id`),
  KEY `index_donations_on_registration_id` (`registration_id`),
  KEY `index_donations_on_date` (`date`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `email_links` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `token` varchar(255) DEFAULT NULL,
  `expires_at` datetime(6) DEFAULT NULL,
  `user_id` bigint DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_email_links_on_user_id` (`user_id`),
  KEY `index_email_links_on_token` (`token`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `faqs` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `question` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `response` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `order` int DEFAULT NULL,
  `display` tinyint(1) DEFAULT '1',
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_faqs_on_order` (`order`),
  KEY `index_faqs_on_display` (`display`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `keyed_contents` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `key` varchar(255) DEFAULT NULL,
  `content` text,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_keyed_contents_on_key` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `main_pages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `merchandise` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `sku` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `unit_cost` decimal(6,2) DEFAULT NULL,
  `sale_price` decimal(6,2) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_merchandise_on_sku` (`sku`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `merchitems` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `sku` varchar(255) DEFAULT NULL,
  `size` varchar(255) DEFAULT NULL,
  `starting_inventory` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `merchandise_id` int DEFAULT NULL,
  `remaining` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_merchitems_on_sku` (`sku`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `modifications` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `status` varchar(255) NOT NULL DEFAULT 'new',
  `starting_adults` int NOT NULL DEFAULT '0',
  `starting_youths` int NOT NULL DEFAULT '0',
  `starting_children` int NOT NULL DEFAULT '0',
  `delta_adults` int NOT NULL DEFAULT '0',
  `delta_youths` int NOT NULL DEFAULT '0',
  `delta_children` int NOT NULL DEFAULT '0',
  `starting_lake_cruise` int NOT NULL DEFAULT '0',
  `delta_lake_cruise` int NOT NULL DEFAULT '0',
  `new_attendee_fee` decimal(8,2) DEFAULT '0.00',
  `new_lake_cruise_fee` decimal(8,2) DEFAULT '0.00',
  `modification_total` decimal(8,2) DEFAULT '0.00',
  `new_total` decimal(8,2) DEFAULT '0.00',
  `cancellation` tinyint(1) DEFAULT '0',
  `registration_id` int NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_modifications_on_registration_id` (`registration_id`),
  CONSTRAINT `fk_rails_1e2e171fd7` FOREIGN KEY (`registration_id`) REFERENCES `registrations` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `pictures` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `caption` varchar(255) DEFAULT NULL,
  `credit` varchar(255) DEFAULT NULL,
  `year` int DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=573 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `purchases` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `untracked_merchandise` text,
  `generic_amount` decimal(6,2) DEFAULT NULL,
  `category` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `cc_transaction_id` varchar(255) DEFAULT NULL,
  `transaction_amount` decimal(6,2) DEFAULT NULL,
  `cash_amount` decimal(6,2) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `postal_code` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `cash_check_paid` decimal(6,2) DEFAULT '0.00',
  `total` decimal(6,2) DEFAULT NULL,
  `paid_method` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_purchases_on_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `qr_codes` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(255) NOT NULL,
  `votable_type` varchar(255) DEFAULT NULL,
  `votable_id` bigint DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_qr_codes_on_code` (`code`),
  KEY `index_qr_codes_on_votable` (`votable_type`,`votable_id`)
) ENGINE=InnoDB AUTO_INCREMENT=784 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `registrations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `number_of_adults` int DEFAULT '0',
  `number_of_children` int DEFAULT '0',
  `registration_fee` decimal(8,2) DEFAULT '0.00',
  `events` text,
  `user_id` int DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `paid_amount` decimal(8,2) DEFAULT '0.00',
  `paid_method` varchar(255) DEFAULT NULL,
  `paid_date` datetime DEFAULT NULL,
  `year` varchar(255) DEFAULT NULL,
  `invoice_number` varchar(255) DEFAULT NULL,
  `donation` decimal(8,2) DEFAULT '0.00',
  `cc_transaction_id` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT 'pending',
  `total` decimal(8,2) DEFAULT '0.00',
  `number_of_seniors` int DEFAULT '0',
  `created_by_admin` tinyint(1) NOT NULL DEFAULT '0',
  `annual_answer` varchar(255) DEFAULT NULL,
  `vendor_fee` decimal(6,2) DEFAULT NULL,
  `is_admin_created` tinyint(1) NOT NULL DEFAULT '0',
  `number_of_youths` int DEFAULT '0',
  `sunday_lunch_number` int NOT NULL DEFAULT '0',
  `lake_cruise_number` int NOT NULL DEFAULT '0',
  `lake_cruise_fee` decimal(8,2) DEFAULT '0.00',
  `balance` decimal(8,2) NOT NULL DEFAULT '0.00',
  `refunded` decimal(8,2) NOT NULL DEFAULT '0.00',
  `step` varchar(255) DEFAULT 'creating',
  `late_period` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_registrations_on_paid_amount` (`paid_amount`),
  KEY `index_registrations_on_paid_method` (`paid_method`),
  KEY `index_registrations_on_paid_date` (`paid_date`),
  KEY `index_registrations_on_year` (`year`),
  KEY `index_registrations_on_invoice_number` (`invoice_number`),
  KEY `index_registrations_on_cc_transaction_id` (`cc_transaction_id`),
  KEY `index_registrations_on_status` (`status`),
  KEY `index_registrations_on_balance` (`balance`),
  KEY `index_registrations_on_refunded` (`refunded`),
  CONSTRAINT `lake_cruise_limit` CHECK (((`lake_cruise_number` >= 0) and (`lake_cruise_number` <= 8))),
  CONSTRAINT `sunday_lunch_limit` CHECK (((`sunday_lunch_number` >= 0) and (`sunday_lunch_number` <= 8)))
) ENGINE=InnoDB AUTO_INCREMENT=1034 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `registrations_vehicles` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `registration_id` int NOT NULL,
  `vehicle_id` int NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_registrations_vehicles_on_registration_id` (`registration_id`),
  KEY `index_registrations_vehicles_on_vehicle_id` (`vehicle_id`),
  CONSTRAINT `fk_rails_67ad1c8aaa` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles` (`id`),
  CONSTRAINT `fk_rails_c5b709feb4` FOREIGN KEY (`registration_id`) REFERENCES `registrations` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `scheduled_events` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `day` varchar(255) DEFAULT NULL,
  `time` varchar(255) DEFAULT NULL,
  `short_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `long_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `order` int DEFAULT NULL,
  `venue_id` bigint DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `has_subevents` tinyint(1) DEFAULT NULL,
  `main_event_id` bigint DEFAULT NULL,
  `extra_cost` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_scheduled_events_on_venue_id` (`venue_id`),
  KEY `index_scheduled_events_on_day` (`day`),
  KEY `index_scheduled_events_on_order` (`order`),
  KEY `index_scheduled_events_on_has_subevents` (`has_subevents`),
  KEY `index_scheduled_events_on_main_event_id` (`main_event_id`),
  CONSTRAINT `fk_rails_0f26856bbd` FOREIGN KEY (`main_event_id`) REFERENCES `scheduled_events` (`id`),
  CONSTRAINT `fk_rails_2b5df173eb` FOREIGN KEY (`venue_id`) REFERENCES `venues` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `site_settings` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `square_environment` varchar(255) DEFAULT NULL,
  `registration_is_open` tinyint(1) DEFAULT NULL,
  `voting_on` tinyint(1) DEFAULT '0',
  `debug_dates` tinyint(1) DEFAULT NULL,
  `debug_test_date` date DEFAULT NULL,
  `login_on` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `square_transactions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `registration_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `transaction_type` varchar(255) NOT NULL,
  `square_id` varchar(255) NOT NULL,
  `amount_cents` int DEFAULT '0',
  `currency` varchar(255) DEFAULT 'USD',
  `status` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `square_created_at` datetime(6) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_square_transactions_on_square_id` (`square_id`),
  KEY `index_square_transactions_on_registration_id` (`registration_id`),
  KEY `index_square_transactions_on_user_id` (`user_id`),
  KEY `index_square_transactions_on_email` (`email`),
  CONSTRAINT `fk_rails_1a5c19e480` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_f2eff85689` FOREIGN KEY (`registration_id`) REFERENCES `registrations` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=87 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `transactions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `transaction_method` varchar(255) DEFAULT NULL,
  `transaction_type` varchar(255) DEFAULT NULL,
  `cc_transaction_id` varchar(255) DEFAULT NULL,
  `amount` decimal(6,2) DEFAULT '0.00',
  `registration_id` int DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_transactions_on_transaction_method` (`transaction_method`),
  KEY `index_transactions_on_transaction_type` (`transaction_type`),
  KEY `index_transactions_on_cc_transaction_id` (`cc_transaction_id`)
) ENGINE=InnoDB AUTO_INCREMENT=907 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL DEFAULT '',
  `encrypted_password` varchar(255) NOT NULL DEFAULT '',
  `reset_password_token` varchar(255) DEFAULT NULL,
  `reset_password_sent_at` datetime DEFAULT NULL,
  `remember_created_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `provider` varchar(255) DEFAULT NULL,
  `uid` varchar(255) DEFAULT NULL,
  `role_mask` int DEFAULT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `receive_mailings` tinyint(1) DEFAULT '1',
  `address1` varchar(255) DEFAULT NULL,
  `address2` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `state_or_province` varchar(255) DEFAULT NULL,
  `postal_code` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `roles_mask` int DEFAULT NULL,
  `citroenvie` tinyint(1) DEFAULT NULL,
  `login_token` varchar(255) DEFAULT NULL,
  `login_token_sent_at` datetime(6) DEFAULT NULL,
  `is_testing` tinyint(1) DEFAULT '0',
  `recaptcha_whitelisted` tinyint(1) DEFAULT NULL,
  `last_active` datetime(6) DEFAULT NULL,
  `is_admin_created` tinyint(1) DEFAULT '0',
  `square_customer_id` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_email` (`email`),
  UNIQUE KEY `index_users_on_reset_password_token` (`reset_password_token`),
  UNIQUE KEY `index_users_on_login_token` (`login_token`),
  KEY `index_users_on_provider` (`provider`),
  KEY `index_users_on_uid` (`uid`),
  KEY `index_users_on_first_name` (`first_name`),
  KEY `index_users_on_last_name` (`last_name`),
  KEY `index_users_on_receive_mailings` (`receive_mailings`),
  KEY `index_users_on_state_or_province` (`state_or_province`),
  KEY `index_users_on_country` (`country`),
  KEY `index_users_on_roles_mask` (`roles_mask`),
  KEY `index_users_on_citroenvie` (`citroenvie`),
  KEY `index_users_on_last_active` (`last_active`),
  KEY `index_users_on_square_customer_id` (`square_customer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1172 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `vehicles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `year` varchar(255) DEFAULT NULL,
  `marque` varchar(255) DEFAULT NULL,
  `model` varchar(255) DEFAULT NULL,
  `other_info` text,
  `user_id` int DEFAULT NULL,
  `for_sale` tinyint(1) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_vehicles_on_year` (`year`),
  KEY `index_vehicles_on_marque` (`marque`),
  KEY `index_vehicles_on_marque_and_year_and_model` (`marque`,`year`,`model`),
  KEY `index_vehicles_on_marque_and_model` (`marque`,`model`),
  KEY `index_vehicles_on_model` (`model`),
  KEY `index_vehicles_on_user_id` (`user_id`),
  KEY `index_vehicles_on_for_sale` (`for_sale`),
  KEY `index_vehicles_on_code` (`code`),
  CONSTRAINT `fk_rails_9e34682d54` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=782 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `vendors` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `address` text,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `order` int DEFAULT NULL,
  `owner_id` int DEFAULT NULL,
  `owner_display_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_vendors_on_order` (`order`),
  KEY `index_vendors_on_owner_id` (`owner_id`),
  CONSTRAINT `fk_rails_9939c0dbd2` FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `venues` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `show_field_venue` tinyint(1) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `address` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `phone` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `details` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `reservation_url` varchar(255) DEFAULT NULL,
  `group_code` varchar(255) DEFAULT NULL,
  `rooms_available` int DEFAULT NULL,
  `close_date` date DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_venues_on_show_field_venue` (`show_field_venue`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

INSERT INTO `schema_migrations` (version) VALUES
('20260410001310'),
('20260404222829'),
('20260404203116'),
('20260404101159'),
('20260404091851'),
('20260324032035'),
('20260320003642'),
('20260319011608'),
('20260318221510'),
('20260316235622'),
('20260315112625'),
('20260312002254'),
('20260310000726'),
('20260306221930'),
('20260221163708'),
('20260221155934'),
('20260221155841'),
('20260131211345'),
('20260131170445'),
('20250607194355'),
('20250607131102'),
('20250606011153'),
('20250503122703'),
('20250503001120'),
('20250421190524'),
('20250421164129'),
('20250421105352'),
('20250420140854'),
('20250420140830'),
('20250420004900'),
('20250417014258'),
('20250413113902'),
('20250412201038'),
('20250412140011'),
('20250412135357'),
('20250412101611'),
('20250406173059'),
('20250406112214'),
('20250403042153'),
('20250330185843'),
('20250329165103'),
('20250329145533'),
('20250328034636'),
('20250328034339'),
('20250316171334'),
('20250316124156'),
('20250315152600'),
('20250314011805'),
('20250314010215'),
('20250312021503'),
('20250311044548'),
('20250309174912'),
('20250309041911'),
('20250308235459'),
('20250308171631'),
('20250302182633'),
('20250302180300'),
('20250302174507'),
('20250112042917'),
('20240613225050'),
('20240613195337'),
('20240613023222'),
('20240613021033'),
('20240613003857'),
('20240612045209'),
('20240612022335'),
('20240612012637'),
('20240612004930'),
('20240611233007'),
('20240611220334'),
('20240610015613'),
('20240610010550'),
('20240609221606'),
('20240608152601'),
('20240420142636'),
('20230331011833'),
('20230330005439'),
('20230324110603'),
('20230319114053'),
('20230311064101'),
('20230311062205'),
('20230311055929'),
('20170304211926'),
('20160417170008'),
('20160330022356'),
('20160325230626'),
('20160323182625'),
('20160317013543'),
('20160317013047'),
('20160313184539'),
('20160313183647'),
('20160311132646'),
('20160309014000'),
('20160306171254'),
('20160304034928'),
('20160304021209'),
('20160304015738'),
('20160228213009'),
('20160228184708'),
('20160225032918'),
('20160225021849'),
('20160225020233'),
('20160225010833'),
('20160103205046'),
('20151230194627'),
('20151229181255'),
('20151229174758'),
('20151212222349'),
('20151209021944'),
('20151209013640');

