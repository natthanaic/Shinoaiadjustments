-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Dec 19, 2025 at 11:00 AM
-- Server version: 10.11.6-MariaDB-0+deb12u1-log
-- PHP Version: 8.4.14

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `lantava_soapview`
--

-- --------------------------------------------------------

--
-- Table structure for table `appointments`
--

CREATE TABLE `appointments` (
  `id` int(11) NOT NULL,
  `patient_id` int(11) DEFAULT NULL,
  `walk_in_name` varchar(200) DEFAULT NULL,
  `walk_in_phone` varchar(50) DEFAULT NULL,
  `walk_in_email` varchar(255) DEFAULT NULL COMMENT 'Email address for walk-in bookings (optional)',
  `booking_type` enum('WALK_IN','OLD_PATIENT') NOT NULL DEFAULT 'OLD_PATIENT',
  `clinic_id` int(11) NOT NULL,
  `pt_id` int(11) DEFAULT NULL,
  `appointment_date` date NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `status` enum('SCHEDULED','CONFIRMED','IN_PROGRESS','COMPLETED','CANCELLED','NO_SHOW') NOT NULL DEFAULT 'SCHEDULED',
  `appointment_type` varchar(100) DEFAULT NULL,
  `reason` text DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `calendar_event_id` varchar(255) DEFAULT NULL COMMENT 'Google Calendar Event ID',
  `cancellation_reason` text DEFAULT NULL,
  `cancelled_by` int(11) DEFAULT NULL,
  `cancelled_at` timestamp NULL DEFAULT NULL,
  `pn_case_id` int(11) DEFAULT NULL COMMENT 'Links to PN case if auto-created',
  `auto_created_pn` tinyint(1) DEFAULT 0 COMMENT 'Whether PN was auto-created from appointment',
  `course_id` int(11) DEFAULT NULL COMMENT 'Links to course for course cutting',
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp(),
  `pn_id` int(11) DEFAULT NULL COMMENT 'Link to pn_cases for status sync',
  `client_ip_address` varchar(45) DEFAULT NULL COMMENT 'IP address of client who created the appointment (for walk-in bookings)',
  `body_annotation_id` int(11) DEFAULT NULL COMMENT 'Reference to body annotation (for initial assessments)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `audit_logs`
--

CREATE TABLE `audit_logs` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `action` varchar(100) NOT NULL,
  `entity_type` varchar(50) DEFAULT NULL,
  `entity_id` int(11) DEFAULT NULL,
  `old_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`old_values`)),
  `new_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`new_values`)),
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Audit trail of system actions';

-- --------------------------------------------------------

--
-- Table structure for table `bills`
--

CREATE TABLE `bills` (
  `id` int(11) NOT NULL,
  `bill_code` varchar(50) NOT NULL,
  `patient_id` int(11) DEFAULT NULL,
  `walk_in_name` varchar(200) DEFAULT NULL,
  `walk_in_phone` varchar(50) DEFAULT NULL,
  `clinic_id` int(11) NOT NULL,
  `bill_date` date NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  `discount` decimal(10,2) DEFAULT 0.00,
  `tax` decimal(10,2) DEFAULT 0.00,
  `total_amount` decimal(10,2) NOT NULL,
  `payment_method` enum('CASH','CREDIT_CARD','BANK_TRANSFER','INSURANCE','OTHER') DEFAULT 'CASH',
  `payment_status` enum('UNPAID','PAID','PARTIAL','CANCELLED') DEFAULT 'UNPAID',
  `payment_date` date DEFAULT NULL COMMENT 'Date when bill payment was received',
  `payment_notes` text DEFAULT NULL,
  `bill_notes` text DEFAULT NULL,
  `appointment_id` int(11) DEFAULT NULL,
  `pn_case_id` int(11) DEFAULT NULL COMMENT 'Links to PN case if bill created from PN',
  `course_id` int(11) DEFAULT NULL COMMENT 'Links to course if course cutting',
  `is_course_cutting` tinyint(1) DEFAULT 0 COMMENT 'Whether this bill cuts from a course',
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `bill_items`
--

CREATE TABLE `bill_items` (
  `id` int(11) NOT NULL,
  `bill_id` int(11) NOT NULL,
  `service_id` int(11) DEFAULT NULL,
  `service_name` varchar(200) NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT 1,
  `unit_price` decimal(10,2) NOT NULL,
  `discount` decimal(10,2) DEFAULT 0.00,
  `total_price` decimal(10,2) NOT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `bodychecks`
--

CREATE TABLE `bodychecks` (
  `id` int(11) NOT NULL,
  `pn_id` int(11) NOT NULL COMMENT 'Reference to pn_cases.id',
  `patient_id` int(11) NOT NULL COMMENT 'Reference to patients.id',
  `all_regions` tinyint(1) DEFAULT 0 COMMENT 'If true, all body regions are included',
  `status` enum('DRAFT','SAVED','ACCEPTED') NOT NULL DEFAULT 'DRAFT' COMMENT 'Bodycheck status',
  `created_by` int(11) NOT NULL COMMENT 'User who created this bodycheck',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Stores body check records linked to PN cases';

-- --------------------------------------------------------

--
-- Table structure for table `bodycheck_regions`
--

CREATE TABLE `bodycheck_regions` (
  `id` int(11) NOT NULL,
  `bodycheck_id` int(11) NOT NULL COMMENT 'Reference to bodychecks.id',
  `region_name` varchar(100) NOT NULL COMMENT 'Name of body region (e.g., Head and Neck, Thorax, etc.)',
  `image_path` varchar(500) DEFAULT NULL COMMENT 'Path to region-specific body image',
  `pain_count` int(11) DEFAULT 0 COMMENT 'Number of pain marks drawn',
  `spasm_count` int(11) DEFAULT 0 COMMENT 'Number of spasm marks drawn',
  `radicular_count` int(11) DEFAULT 0 COMMENT 'Number of radicular (arrow) marks drawn',
  `numbness_count` int(11) DEFAULT 0 COMMENT 'Number of numbness marks drawn',
  `strokes_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Drawing strokes with symptom types' CHECK (json_valid(`strokes_json`)),
  `image_width` int(11) DEFAULT 800 COMMENT 'Canvas width in pixels',
  `image_height` int(11) DEFAULT 1200 COMMENT 'Canvas height in pixels',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Stores individual region drawings for body checks';

-- --------------------------------------------------------

--
-- Table structure for table `body_annotations`
--

CREATE TABLE `body_annotations` (
  `id` int(11) NOT NULL,
  `entity_type` enum('appointment','pn_case') NOT NULL COMMENT 'Type of entity this annotation belongs to',
  `entity_id` int(11) NOT NULL COMMENT 'ID of the appointment or pn_case',
  `annotation_type` varchar(50) DEFAULT 'body_part_marking' COMMENT 'Type of annotation (future: may support different types)',
  `created_by` int(11) NOT NULL COMMENT 'User ID of PT/Admin who created this',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `strokes_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'Drawing strokes with normalized coordinates (0-1)' CHECK (json_valid(`strokes_json`)),
  `image_width` int(11) DEFAULT 800 COMMENT 'Original canvas width in pixels',
  `image_height` int(11) DEFAULT 1200 COMMENT 'Original canvas height in pixels'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Stores body diagram annotations with normalized stroke coordinates';

-- --------------------------------------------------------

--
-- Table structure for table `body_annotation_metadata`
--

CREATE TABLE `body_annotation_metadata` (
  `id` int(11) NOT NULL,
  `annotation_id` int(11) NOT NULL COMMENT 'Reference to body_annotations.id',
  `constant_pain` tinyint(1) DEFAULT 0 COMMENT 'Patient experiences constant pain',
  `intermittent_pain` tinyint(1) DEFAULT 0 COMMENT 'Patient experiences intermittent pain',
  `pain_type` varchar(255) DEFAULT NULL COMMENT 'Description of pain type (e.g., "Sharp, shooting")',
  `aggravation` text DEFAULT NULL COMMENT 'Activities or positions that aggravate pain',
  `easing_factor` text DEFAULT NULL COMMENT 'Activities or positions that ease pain',
  `notes` text DEFAULT NULL COMMENT 'Additional notes from PT/Admin',
  `severity` int(11) DEFAULT NULL COMMENT 'Pain severity rating (1-10 scale)',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Stores pain assessment metadata for body annotations';

-- --------------------------------------------------------

--
-- Table structure for table `broadcast_campaigns`
--

CREATE TABLE `broadcast_campaigns` (
  `id` int(11) NOT NULL,
  `campaign_name` varchar(255) NOT NULL,
  `campaign_type` enum('sms','email','both') NOT NULL,
  `subject` varchar(500) DEFAULT NULL COMMENT 'Email subject line',
  `message_text` text NOT NULL COMMENT 'Plain text message for SMS',
  `message_html` text DEFAULT NULL COMMENT 'HTML content for email',
  `target_audience` enum('all_customers','all_patients','custom') NOT NULL DEFAULT 'all_patients',
  `custom_recipients` text DEFAULT NULL COMMENT 'JSON array of custom recipient emails/phones',
  `schedule_type` enum('immediate','scheduled') NOT NULL DEFAULT 'immediate',
  `scheduled_time` datetime DEFAULT NULL COMMENT 'When to send if scheduled',
  `status` enum('draft','scheduled','sending','sent','failed') NOT NULL DEFAULT 'draft',
  `total_recipients` int(11) DEFAULT 0,
  `sent_count` int(11) DEFAULT 0,
  `failed_count` int(11) DEFAULT 0,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `sent_at` datetime DEFAULT NULL,
  `error_log` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `broadcast_logs`
--

CREATE TABLE `broadcast_logs` (
  `id` int(11) NOT NULL,
  `campaign_id` int(11) NOT NULL,
  `recipient_type` enum('email','phone') NOT NULL,
  `recipient` varchar(255) NOT NULL,
  `status` enum('pending','sent','failed') NOT NULL DEFAULT 'pending',
  `sent_at` datetime DEFAULT NULL,
  `error_message` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `certificate_settings`
--

CREATE TABLE `certificate_settings` (
  `id` int(11) NOT NULL,
  `clinic_id` int(11) DEFAULT NULL COMMENT 'NULL = default for all clinics',
  `clinic_logo_url` varchar(500) DEFAULT NULL,
  `clinic_name` varchar(255) DEFAULT NULL,
  `clinic_address` text DEFAULT NULL,
  `clinic_phone` varchar(50) DEFAULT NULL,
  `clinic_email` varchar(100) DEFAULT NULL,
  `header_text` text DEFAULT NULL,
  `footer_text` text DEFAULT NULL,
  `show_pt_diagnosis` tinyint(1) DEFAULT 1,
  `show_subjective` tinyint(1) DEFAULT 1,
  `show_treatment_period` tinyint(1) DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `chat_conversations`
--

CREATE TABLE `chat_conversations` (
  `id` int(11) NOT NULL,
  `user1_id` int(11) NOT NULL,
  `user2_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `last_message_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `chat_messages`
--

CREATE TABLE `chat_messages` (
  `id` int(11) NOT NULL,
  `conversation_id` int(11) NOT NULL,
  `sender_id` int(11) NOT NULL,
  `recipient_id` int(11) NOT NULL,
  `message` text NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `read_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `clinics`
--

CREATE TABLE `clinics` (
  `id` int(11) NOT NULL,
  `code` varchar(20) NOT NULL,
  `name` varchar(200) NOT NULL,
  `address` text DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `contact_person` varchar(100) DEFAULT NULL,
  `active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `clinics`
--

INSERT INTO `clinics` (`id`, `code`, `name`, `address`, `phone`, `email`, `contact_person`, `active`, `created_at`, `updated_at`) VALUES
(1, 'CL001', 'LANTAVAFIX', '486/2 Moo.3 Saladan, Koh Lanta, Krabi 81150', '098-0946349', 'info@lantavafix.com', 'Suttida Chooluan', 1, '2025-10-30 13:06:38', '2025-11-01 08:02:47'),
(2, 'CL002', 'THONBURI LANTA CLINIC', '486/2 Moo.2 Saladan, Ko Lanta, Krabi 81150', '098-0946349', 'thonburilanta@gmail.com', 'CHAINAKORN.C', 1, '2025-10-30 13:06:38', '2025-11-01 08:03:58'),
(3, 'CL003', 'SOUTH LANTA CLINIC', 'Saladan, Klongthom, Krabi', '02-345-6789', 'partner.b@clinic.com', 'Dr. Williams', 1, '2025-10-30 13:06:38', '2025-11-01 08:04:36');

-- --------------------------------------------------------

--
-- Table structure for table `clinic_service_pricing`
--

CREATE TABLE `clinic_service_pricing` (
  `id` int(11) NOT NULL,
  `clinic_id` int(11) NOT NULL,
  `service_id` int(11) NOT NULL,
  `clinic_price` decimal(10,2) DEFAULT NULL COMMENT 'Clinic-specific price override',
  `is_enabled` tinyint(1) DEFAULT 1 COMMENT 'Service enabled for this clinic',
  `updated_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `courses`
--

CREATE TABLE `courses` (
  `id` int(11) NOT NULL,
  `course_code` varchar(50) NOT NULL,
  `course_name` varchar(200) NOT NULL,
  `course_description` text DEFAULT NULL,
  `patient_id` int(11) NOT NULL COMMENT 'Patient who purchased the course',
  `clinic_id` int(11) NOT NULL COMMENT 'Clinic where course was purchased',
  `total_sessions` int(11) NOT NULL DEFAULT 0,
  `used_sessions` int(11) NOT NULL DEFAULT 0,
  `remaining_sessions` int(11) NOT NULL DEFAULT 0,
  `course_price` decimal(10,2) NOT NULL DEFAULT 0.00,
  `price_per_session` decimal(10,2) NOT NULL DEFAULT 0.00,
  `purchase_date` date NOT NULL,
  `expiry_date` date DEFAULT NULL COMMENT 'Course expiry date (optional)',
  `status` enum('ACTIVE','COMPLETED','EXPIRED','CANCELLED') NOT NULL DEFAULT 'ACTIVE',
  `bill_id` int(11) DEFAULT NULL COMMENT 'Link to billing record',
  `notes` text DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Course packages purchased by patients for physiotherapy sessions';

-- --------------------------------------------------------

--
-- Table structure for table `course_shared_users`
--

CREATE TABLE `course_shared_users` (
  `id` int(11) NOT NULL,
  `course_id` int(11) NOT NULL COMMENT 'Reference to the course being shared',
  `patient_id` int(11) NOT NULL COMMENT 'Patient who can use this course',
  `shared_by` int(11) NOT NULL COMMENT 'User who granted sharing access',
  `shared_date` date NOT NULL COMMENT 'Date sharing was granted',
  `notes` text DEFAULT NULL COMMENT 'Notes about this sharing arrangement',
  `is_active` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Whether this sharing is still active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tracks which patients can use a shared course (family sharing)';

-- --------------------------------------------------------

--
-- Table structure for table `course_templates`
--

CREATE TABLE `course_templates` (
  `id` int(11) NOT NULL,
  `template_name` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `total_sessions` int(11) NOT NULL,
  `default_price` decimal(10,2) NOT NULL,
  `validity_days` int(11) DEFAULT NULL COMMENT 'Number of days course is valid',
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Templates for creating course packages';

-- --------------------------------------------------------

--
-- Table structure for table `course_usage_history`
--

CREATE TABLE `course_usage_history` (
  `id` int(11) NOT NULL,
  `course_id` int(11) NOT NULL,
  `bill_id` int(11) DEFAULT NULL COMMENT 'Related bill if from billing',
  `pn_id` int(11) DEFAULT NULL COMMENT 'Related PN case if used for PN',
  `sessions_used` int(11) NOT NULL DEFAULT 1,
  `usage_date` date NOT NULL,
  `action_type` enum('USE','RETURN','ADJUST') NOT NULL DEFAULT 'USE' COMMENT 'USE=deduct, RETURN=refund, ADJUST=manual adjustment',
  `notes` text DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='History of course session usage, returns, and adjustments';

-- --------------------------------------------------------

--
-- Table structure for table `expenses`
--

CREATE TABLE `expenses` (
  `id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `description` text DEFAULT NULL,
  `expense_date` date NOT NULL,
  `receipt_number` varchar(50) DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `expense_categories`
--

CREATE TABLE `expense_categories` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `gift_cards`
--

CREATE TABLE `gift_cards` (
  `id` int(11) NOT NULL,
  `gift_card_code` varchar(50) NOT NULL,
  `member_id` int(11) NOT NULL,
  `points_redeemed` int(11) NOT NULL,
  `gift_card_value` decimal(10,2) NOT NULL,
  `status` enum('ACTIVE','REDEEMED','EXPIRED','CANCELLED') DEFAULT 'ACTIVE',
  `issued_date` datetime DEFAULT current_timestamp(),
  `expiry_date` date DEFAULT NULL,
  `redeemed_date` datetime DEFAULT NULL,
  `redeemed_by_user` int(11) DEFAULT NULL,
  `bill_id_used` int(11) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `gift_card_catalog`
--

CREATE TABLE `gift_card_catalog` (
  `id` int(11) NOT NULL,
  `name` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `points_required` int(11) NOT NULL,
  `gift_card_value` decimal(10,2) NOT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `stock_quantity` int(11) DEFAULT -1 COMMENT '-1 means unlimited',
  `display_order` int(11) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `invoices`
--

CREATE TABLE `invoices` (
  `id` int(11) NOT NULL,
  `invoice_number` varchar(50) NOT NULL,
  `customer_name` varchar(200) NOT NULL,
  `customer_email` varchar(100) DEFAULT NULL,
  `customer_phone` varchar(50) DEFAULT NULL,
  `customer_address` text DEFAULT NULL,
  `invoice_date` date NOT NULL,
  `due_date` date DEFAULT NULL,
  `subtotal` decimal(10,2) NOT NULL DEFAULT 0.00,
  `tax_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `discount_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `total_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `payment_status` enum('unpaid','paid','partially_paid','cancelled') NOT NULL DEFAULT 'unpaid',
  `payment_date` date DEFAULT NULL,
  `payment_method` varchar(50) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `clinic_id` int(11) NOT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `invoice_items`
--

CREATE TABLE `invoice_items` (
  `id` int(11) NOT NULL,
  `invoice_id` int(11) NOT NULL,
  `service_id` int(11) DEFAULT NULL,
  `item_name` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `quantity` int(11) NOT NULL DEFAULT 1,
  `unit_price` decimal(10,2) NOT NULL,
  `total_price` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `loyalty_members`
--

CREATE TABLE `loyalty_members` (
  `id` int(11) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `membership_tier` enum('BRONZE','SILVER','GOLD','PLATINUM') DEFAULT 'BRONZE',
  `total_points` int(11) DEFAULT 0,
  `available_points` int(11) DEFAULT 0,
  `lifetime_spending` decimal(10,2) DEFAULT 0.00,
  `current_year_spending` decimal(10,2) DEFAULT 0.00,
  `member_since` date NOT NULL,
  `last_activity` datetime DEFAULT NULL,
  `status` enum('ACTIVE','INACTIVE','SUSPENDED') DEFAULT 'ACTIVE',
  `notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `loyalty_tier_rules`
--

CREATE TABLE `loyalty_tier_rules` (
  `id` int(11) NOT NULL,
  `tier` enum('BRONZE','SILVER','GOLD','PLATINUM') NOT NULL,
  `min_spending` decimal(10,2) NOT NULL,
  `points_per_100_baht` int(11) DEFAULT 1,
  `discount_percentage` decimal(5,2) DEFAULT 0.00,
  `description` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `loyalty_transactions`
--

CREATE TABLE `loyalty_transactions` (
  `id` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `transaction_type` enum('EARN','REDEEM','EXPIRE','ADJUST') NOT NULL,
  `points` int(11) NOT NULL,
  `bill_id` int(11) DEFAULT NULL,
  `gift_card_id` int(11) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `performed_by` int(11) DEFAULT NULL,
  `transaction_date` datetime DEFAULT current_timestamp(),
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `notification_settings`
--

CREATE TABLE `notification_settings` (
  `id` int(11) NOT NULL,
  `setting_type` varchar(50) NOT NULL COMMENT 'Type: smtp, line',
  `setting_value` text NOT NULL COMMENT 'JSON encoded settings',
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `patients`
--

CREATE TABLE `patients` (
  `id` int(11) NOT NULL,
  `hn` varchar(50) NOT NULL,
  `pt_number` varchar(50) NOT NULL,
  `pid` varchar(13) DEFAULT NULL,
  `passport_no` varchar(50) DEFAULT NULL,
  `title` varchar(20) DEFAULT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `dob` date DEFAULT NULL,
  `gender` enum('M','F','O') DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `emergency_contact` varchar(100) DEFAULT NULL,
  `emergency_phone` varchar(50) DEFAULT NULL,
  `diagnosis` text NOT NULL,
  `rehab_goal` text DEFAULT NULL,
  `rehab_goal_other` text DEFAULT NULL,
  `body_area` varchar(200) DEFAULT NULL,
  `frequency` varchar(100) DEFAULT NULL,
  `expected_duration` varchar(100) DEFAULT NULL,
  `doctor_note` text DEFAULT NULL,
  `precaution` text DEFAULT NULL,
  `contraindication` text DEFAULT NULL,
  `medical_history` text DEFAULT NULL,
  `clinic_id` int(11) NOT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `patients`
--

INSERT INTO `patients` (`id`, `hn`, `pt_number`, `pid`, `passport_no`, `title`, `first_name`, `last_name`, `dob`, `gender`, `phone`, `email`, `address`, `emergency_contact`, `emergency_phone`, `diagnosis`, `rehab_goal`, `rehab_goal_other`, `body_area`, `frequency`, `expected_duration`, `doctor_note`, `precaution`, `contraindication`, `medical_history`, `clinic_id`, `created_by`, `created_at`, `updated_at`) VALUES
(6, 'PT250003', 'PT20251107151516840', '3910100302293', NULL, 'Mr.', 'อภิสฤษฎ์', 'อาคาสุวรรณ', NULL, '', '0980946351', 'info@lantavafix', NULL, '0980946351', '0980946351', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '3 time/week', '6 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(7, 'PT250004', 'PT20251107151516298', 'C4KNGJ22K', NULL, 'Mr.', 'Toni', 'Seeman', NULL, '', '0980946352', 'info@lantavafix', NULL, '0980946352', '0980946352', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '4 time/week', '7 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(8, 'PT250005', 'PT20251107151516875', '642659092', NULL, 'Mrs.', 'CARTER-SCOTT', 'POMIJE', NULL, '', '0980946353', 'info@lantavafix', NULL, '0980946353', '0980946353', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '5 time/week', '8 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(9, 'PT250006', 'PT20251107151516542', '6426590736', NULL, 'Mr.', 'Michael Anthony', 'Pomije', NULL, '', '0980946354', 'michaelpomije@gmail.com', NULL, '0980946354', '0980946354', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '6 time/week', '9 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(10, 'PT250007', 'PT20251107151516568', 'NPBPD2201', NULL, 'Mr.', 'DANNY', 'KOPPERS', NULL, '', '0980946355', 'info@lantavafix', NULL, '0980946355', '0980946355', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '7 time/week', '10 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(11, 'PT250008', 'PT20251107151516460', '3740100163066', NULL, 'Mrs.', 'ภริตพร', 'อินสว่าง', NULL, '', '0980946356', 'info@lantavafix', NULL, '0980946356', '0980946356', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '8 time/week', '11 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(12, 'PT250009', 'PT20251107151516284', '1349900578355', NULL, 'Mr.', 'อนุชา', 'แก้วหิน', NULL, '', '0980946357', 'info@lantavafix', NULL, '0980946357', '0980946357', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '9 time/week', '12 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(13, 'PT250010', 'PT20251107151516572', '1810300050128', NULL, 'Mr.', 'สถาพร', 'ไทรบุรี', NULL, '', '0980946358', 'info@lantavafix', NULL, '0980946358', '0980946358', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '10 time/week', '13 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(14, 'PT250011', 'PT20251107151516765', '3110300902496', NULL, 'Mrs.', 'เหมือนฝัน', 'ศิริสัมพันธ์', NULL, '', '0980946359', 'info@lantavafix', NULL, '0980946359', '0980946359', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '11 time/week', '14 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(15, 'PT250012', 'PT20251107151516408', '17FV18341', NULL, 'Mr.', 'Pages', 'Olivier', NULL, '', '0980946360', 'info@lantavafix', NULL, '0980946360', '0980946360', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '12 time/week', '15 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(16, 'PT250013', 'PT20251107151516586', '22H150986', NULL, 'Mr.', 'Kane', 'Tidiane', NULL, '', '0980946361', 'info@lantavafix', NULL, '0980946361', '0980946361', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '13 time/week', '16 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(17, 'PT250014', 'PT20251107151516382', '3930200001601', NULL, 'Mr.', 'เสวก', 'เหล็มปาน', NULL, '', '0980946362', 'info@lantavafix', NULL, '0980946362', '0980946362', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '14 time/week', '17 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(18, 'PT250015', 'PT20251107151516063', '3809900547745', NULL, 'Mrs.', 'โสภิดา', 'นาคทองทิพย์', NULL, '', '0980946363', 'info@lantavafix', NULL, '0980946363', '0980946363', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '15 time/week', '18 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(19, 'PT250016', 'PT20251107151516085', 'LT7988792', NULL, 'Mrs.', 'Maeve', 'Henry', NULL, '', '0980946364', 'maevehenry@gmail.com', NULL, '0980946364', '0980946364', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '16 time/week', '19 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-16 05:26:50'),
(20, 'PT250017', 'PT20251107151516261', '3810400085108', NULL, 'Mrs.', 'สุวรรณา', 'หลานอา', NULL, '', '0980946365', 'info@lantavafix', NULL, '0980946365', '0980946365', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '17 time/week', '20 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(21, 'PT250018', 'PT20251107151516585', '1810300054891', NULL, 'Mr.', 'ฤทธา', 'ก๊กใหญ่', NULL, '', '0980946366', 'info@lantavafix', NULL, '0980946366', '0980946366', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '18 time/week', '21 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(22, 'PT250019', 'PT20251107151516202', 'AA2778445', NULL, 'Mr.', 'FURQAN', 'SHAYK', NULL, '', '0980946367', 'info@lantavafix', NULL, '0980946367', '0980946367', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '19 time/week', '22 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(23, 'PT250020', 'PT20251107151516165', '3841300160117', NULL, 'Mrs.', 'วิสรา', 'ทองน้อย', NULL, '', '0980946368', 'info@lantavafix', NULL, '0980946368', '0980946368', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '20 time/week', '23 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(24, 'PT250021', 'PT20251107151516685', 'AC4571886', NULL, 'Mrs.', 'Alesha', 'Leslie', NULL, '', '0980946369', 'info@lantavafix', NULL, '0980946369', '0980946369', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '21 time/week', '24 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(25, 'PT250023', 'PT20251107151516992', 'Unknow2', NULL, 'Mrs.', 'Oksana', 'Koliyk', NULL, '', '0980946371', 'info@lantavafix', NULL, '0980946371', '0980946371', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '23 time/week', '26 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(26, 'PT250024', 'PT20251107151516527', '1810300002085', NULL, 'Mr.', 'สุวิทย์', 'กสิคุณ', NULL, '', '0980946372', 'info@lantavafix', NULL, '0980946372', '0980946372', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '24 time/week', '27 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(27, 'PT250026', 'PT20251107151516900', '1959900554353', NULL, 'Mr.', 'ณัฐวัฒน์', 'ทองหนูนุ้ย', NULL, '', '0980946374', 'info@lantavafix', NULL, '0980946374', '0980946374', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '26 time/week', '29 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(28, 'PT250027', 'PT20251107151516838', 'RA8340672', NULL, 'Mr.', 'PATRICK', 'BONHAM', NULL, '', '0980946375', 'patb17@gmail.com', NULL, '0980946375', '0980946375', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '27 time/week', '30 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(29, 'PT250028', 'PT20251107151516180', '1819900413785', NULL, 'Mrs.', 'ชนัษฎา', 'ก๊กใหม่', NULL, '', '0980946376', 'info@lantavafix', NULL, '0980946376', '0980946376', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '28 time/week', '31 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(30, 'PT250029', 'PT20251107151516869', '3930100073791', NULL, 'Mr.', 'ปราโมทย์', 'สุขสุวรรณ์', NULL, '', '0980946377', 'info@lantavafix', NULL, '0980946377', '0980946377', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '29 time/week', '32 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(31, 'PT250030', 'PT20251107151516449', 'Unknow3', NULL, 'Mrs.', 'วิภาวดี', 'ศรีทอง', NULL, '', '0980946378', 'info@lantavafix', NULL, '0980946378', '0980946378', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '30 time/week', '33 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(32, 'PT250031', 'PT20251107151516110', 'AAI306535', NULL, 'Mrs.', 'Cintia', 'Artola', NULL, '', '0980946379', 'info@lantavafix', NULL, '0980946379', '0980946379', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '31 time/week', '34 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(33, 'PT250032', 'PT20251107151516061', '381030041061', NULL, 'Mr.', 'กุศล', 'จะเดดัง', NULL, '', '0980946380', 'info@lantavafix', NULL, '0980946380', '0980946380', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '32 time/week', '35 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(34, 'PT250033', 'PT20251107151516879', 'Unknow4', NULL, 'Mr.', 'Borin', 'Brice', NULL, '', '0980946381', 'bborin@gmail.com', NULL, '0980946381', '0980946381', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '33 time/week', '36 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(35, 'PT250034', 'PT20251107151516086', '16AL12562', NULL, 'Mrs.', 'Nanorillion', 'Chloe', NULL, '', '0980946382', 'info@lantavafix', NULL, '0980946382', '0980946382', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '34 time/week', '37 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(36, 'PT250035', 'PT20251107151516176', '17AT73981', NULL, 'Mrs.', 'Elhaimour', 'Shainez', NULL, '', '0980946383', 'info@lantavafix', NULL, '0980946383', '0980946383', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '35 time/week', '38 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(37, 'PT250036', 'PT20251107151516213', 'Unknow5', NULL, 'Mr.', 'ARTUR', 'KRUEGER', NULL, '', '0980946384', 'info@lantavafix', NULL, '0980946384', '0980946384', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '36 time/week', '39 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(38, 'PT250037', 'PT20251107151516844', '1810300062304', NULL, 'Mrs.', 'ทัศวรรณ', 'กุลสถาพร', NULL, '', '0980946385', 'porhallowwiz@gmail.com', '59 ม.2 ต.เกาะลันตาใหญ่ อ.เกาะลันตา จ.กระบี่', '0980946385', '0980946385', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '37 time/week', '40 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(39, 'PT250038', 'PT20251107151516567', '3101900348067', NULL, 'Mr.', 'วิสุทธิ์', 'เจียวก๊ก', NULL, '', '0980946386', 'info@lantavafix', NULL, '0980946386', '0980946386', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '38 time/week', '41 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(40, 'PT250039', 'PT20251107151516312', '151495187', NULL, 'Mrs.', 'Audreea', 'Papillon', NULL, '', '0980946387', 'info@lantavafix', NULL, '0980946387', '0980946387', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '39 time/week', '42 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(41, 'PT250040', 'PT20251107151516876', '3801100438723', NULL, 'Mr.', 'สิทธิพร', 'บุญชู', NULL, '', '0980946388', 'info@lantavafix', NULL, '0980946388', '0980946388', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '40 time/week', '43 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(42, 'PT250041', 'PT20251107151516706', '3909900115071', NULL, 'Mr.', 'โกเมน', 'คงเจียมศิริ', NULL, '', '0980946389', 'info@lantavafix', NULL, '0980946389', '0980946389', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '41 time/week', '44 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(43, 'PT250042', 'PT20251107151516282', '1869900160763', NULL, 'Mrs.', 'ณัฐณิชา', 'เอื้ออารีศักดา', NULL, '', '0980946390', 'Yean_natnicha@hotmail.com', NULL, '0980946390', '0980946390', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '42 time/week', '45 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(44, 'PT250043', 'PT20251107151516143', '1800800006829', NULL, 'Mrs.', 'วิชฎา', 'ก๊กใหญ่', NULL, '', '0980946391', 'info@lantavafix', NULL, '0980946391', '0980946391', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '43 time/week', '46 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(45, 'PT250044', 'PT20251107151516839', '1103701431601', NULL, 'Mrs.', 'น้ำทิพย์', 'สิทธิ', NULL, '', '0980946392', 'info@lantavafix', NULL, '0980946392', '0980946392', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '44 time/week', '47 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(46, 'PT250045', 'PT20251107151516759', '3810300058567', NULL, 'Mr.', 'ทัศพล', 'กสิคุณ', NULL, '', '0980946393', 'info@lantavafix', NULL, '0980946393', '0980946393', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '45 time/week', '48 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(47, 'PT250046', 'PT20251107151516604', 'C26609625', NULL, 'Mr.', 'FERGAL', 'O SHEA', '1987-08-12', 'M', '0980946394', 'fosemm@gmail.com', NULL, '0980946394', '0980946394', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '46 time/week', '49 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-11-20 11:04:10'),
(48, 'PT250047', 'PT20251107151516466', 'Unknow6', NULL, 'Mrs.', 'นิลัทธนา', 'ก๊กใหญ่', NULL, '', '0980946395', 'info@lantavafix', NULL, '0980946395', '0980946395', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '47 time/week', '50 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(49, 'PT250048', 'PT20251107151516459', '3810300042539', NULL, 'Mrs.', 'สุชาตา', 'ก๊กใหญ่', NULL, '', '0980946396', 'info@lantavafix', NULL, '0980946396', '0980946396', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '48 time/week', '51 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(50, 'PT250049', 'PT20251107151516124', 'Unknow7', NULL, 'Mr.', 'หมาดนะ', 'จำเริศราญ', NULL, '', '0980946397', 'info@lantavafix', NULL, '0980946397', '0980946397', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '49 time/week', '52 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(51, 'PT250050', 'PT20251107151516591', '565894684', NULL, 'Mrs.', 'Marilyn', 'Ryan', NULL, '', '0980946398', 'info@lantavafix', NULL, '0980946398', '0980946398', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '50 time/week', '53 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(52, 'PT250051', 'PT20251107151516548', 'CF44TNNTP', NULL, 'Mrs.', 'Kathasina', 'Goj', NULL, '', '0980946399', 'info@lantavafix', NULL, '0980946399', '0980946399', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '51 time/week', '54 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(53, 'PT250052', 'PT20251107151516828', 'Unknow8', NULL, 'Mr.', 'อาทิตย์', 'และตี', NULL, '', '0980946400', 'info@lantavafix', NULL, '0980946400', '0980946400', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '52 time/week', '55 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(54, 'PT250053', 'PT20251107151516413', 'Unknow9', NULL, 'Mrs.', 'สุดา', 'ก๊กใหญ่', NULL, '', '0980946401', 'info@lantavafix', NULL, '0980946401', '0980946401', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '53 time/week', '56 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(55, 'PT250054', 'PT20251107151516521', '4849900004006', NULL, 'Mrs.', 'สุทิศา', 'นันต์ธนะ', NULL, '', '0980946402', 'info@lantavafix', NULL, '0980946402', '0980946402', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '54 time/week', '57 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(56, 'PT250055', 'PT20251107151516903', '1102001910123', NULL, 'Mrs.', 'ธนัญญา', 'เพรียวพานิช', NULL, '', '0980946403', 'info@lantavafix', NULL, '0980946403', '0980946403', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '55 time/week', '58 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(57, 'PT250057', 'PT20251107151516394', 'Unknow10', NULL, 'Mr.', 'Nils', 'Finge', NULL, '', '0980946405', 'info@lantavafix', NULL, '0980946405', '0980946405', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '57 time/week', '60 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(58, 'PT250058', 'PT20251107151516192', '1820390002217', NULL, 'Mr.', 'นฤพนธ์', 'อินทร์กำเนิด', NULL, '', '0980946406', 'info@lantavafix', NULL, '0980946406', '0980946406', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '58 time/week', '61 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(59, 'PT250059', 'PT20251107151516363', '20AD24621', NULL, 'Mr.', 'Sanuel', 'Doualle', NULL, '', '0980946407', 'info@lantavafix', NULL, '0980946407', '0980946407', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '59 time/week', '62 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(60, 'PT250060', 'PT20251107151516718', 'XOP93M28', NULL, 'Mrs.', 'Lelia', 'Elpidine', NULL, '', '0980946408', 'info@lantavafix', NULL, '0980946408', '0980946408', 'Pain relief', 'Relief pain', NULL, 'Multipoints', '60 time/week', '63 weeks', NULL, NULL, NULL, NULL, 1, 1, '2025-11-07 08:15:16', '2025-12-15 18:11:01'),
(61, 'PT250061', 'PT20251107154339840', NULL, 'BB819946227', '', 'Jurai', 'Dorosenko', '1998-08-31', 'M', '-', 'tobiasfunke250@gmail.com', 'Slovakia', '-', '-', 'Lt.lower back pain', 'Pain reduction, Improve ROM', '', 'Lower Back', 'As needed', '1-2 weeks', '', '', '', '-', 1, 1, '2025-11-07 08:43:39', '2025-11-18 09:32:10'),
(62, 'PT250062', 'PT20251108121841791', '1910500044903', NULL, 'Mrs.', 'อามีเราะฮ์', 'สาลีมีน', '1984-01-01', 'F', '0624861183', 'ameeroh6047@gmail.com', 'เกาะลันตา กระบี่', '0624861183', '0624861183', 'มีอาการชาปวดร้าวไปถึงปลาย ขาทั้ง 2 ข้าง ในท่าหดกล้ามเนื้อ', 'Pain reduction, Improve ROM', '', 'Hip', '2 times/week', '2-4 weeks', '', '', '', 'เคยคลอดลูกด้วยการบล้อกหลัง 3 ครั้ง ', 1, 1, '2025-11-08 05:18:41', '2025-11-18 09:32:10'),
(63, 'PT250063', 'PT20251108154324520', '3800101233661', NULL, 'Mr.', 'สุภกิจ ', 'นาคทองทิพย์', '1972-05-26', 'M', '0651155548', '', 'เกาะลันตา Yellow bistro', '', '', 'Rt.SI joint dysfuction', 'Pain reduction, Improve ROM', '', 'Lower Back', 'Daily', '1-2 weeks', '', '', '', 'pt.มีอาการปวดหลังขวา มา 2 วัน', 1, 1, '2025-11-08 08:43:24', '2025-11-19 04:44:13'),
(64, 'PT250064', 'PT20251110093508798', 'Foreginer01', NULL, 'Mr.', 'Alexander', 'Svanberg', '1987-01-01', 'M', '+46709983894', '', '', '', '', 'Hip stiffness', 'Pain reduction, Improve ROM', '', 'Hip', '2 times/week', '1-2 weeks', '', '', '', 'Testicle opration', 1, 1, '2025-11-10 02:35:08', '2025-11-18 09:32:10'),
(65, 'PT250065', 'PT20251110112823216', 'Foreginer02', NULL, 'Mr.', 'VAN NIEUWISUG ', 'WILLIAM', '1975-01-01', 'M', '0937819684', 'WANN777@gmail.com', 'krabi', '', '', 'neck stiffness', 'Improve ROM', '', 'Neck', 'As needed', '1-2 weeks', '', '', '', 'rising on the bed feel neck stiffness', 1, 1, '2025-11-10 04:28:23', '2025-11-18 09:32:10'),
(66, 'PT250066', 'PT20251110180232781', 'Foreginer03', NULL, 'Ms.', 'ARZUM', 'KUZAY', '1973-01-28', 'F', '0650350911', 'akuzay@hotmail.com', 'Koh lanta, Krabi ', '+90 532 5496269', '', 'Heel', 'Pain reduction, Improve ROM', '', 'Ankle/Foot', '2 times/week', '2-4 weeks', '', '', '', 'Thyroid operation ', 1, 1, '2025-11-10 11:02:32', '2025-11-18 09:32:10'),
(68, 'PT250067', 'PT20251112105157715', 'Thai01', NULL, 'Mr.', 'ทศพล', 'กุลสถาพร', '1897-09-09', 'M', '801438858', 'porhallowwiz@gmail.com', '59 ม.2 ต.เกาะลันตาใหญ่ อ.เกาะลันตา จ.กระบี่', '', '', 'Hip pain', 'Pain reduction, Improve ROM, Strengthen muscles', '', 'Lower Back', '2 times/week', '1-2 weeks', '', '', '', 'Thyroid toxicosis', 1, 1, '2025-11-12 03:51:57', '2025-11-20 11:24:07'),
(69, 'PT250068', 'PT20251112151840376', '191990279522', NULL, 'Mr.', 'ธีรศักดิ์', 'ฮะยีตำมะลัง', '2000-10-24', 'M', '0822474284', '', '', '', '', 'Knee accident', 'Pain reduction, Improve ROM', '', 'Knee', '2 times/week', '2-4 weeks', '', '', '', 'no', 1, 1, '2025-11-12 08:18:40', '2025-11-18 09:32:10'),
(70, 'PT250069', 'PT20251113102739276', '21CK94280', NULL, 'Mr.', 'FORCUE', 'PABLO', '1999-01-01', 'M', '-', 'pablo.f6531@gmail.com', 'Koh Lanta', '-', '', 'Muay thai elbow pain', 'Pain reduction, Improve ROM', '', 'Elbow', 'As needed', '1-2 weeks', '', '', '', '-', 1, 1, '2025-11-13 03:27:39', '2025-11-18 09:32:10'),
(72, 'PT250070', 'PT20251114091904914', 'Foreginer04', NULL, 'Mr.', 'Mark', 'Wichmann', '1995-10-30', 'M', '0961754602', 'wichmann_mark@web.de', 'Germanny stay Dusit Long Beach', '0961754602', '0961754602', 'Muay thai class ', 'Pain reduction, Improve ROM, Strengthen muscles', '', 'Elbow', 'As needed', '1-2 weeks', '', '', '', 'metal insertion at right ring finger', 1, 1, '2025-11-14 02:19:04', '2025-11-18 09:32:10'),
(73, 'PT250071', 'PT20251114140940420', 'NT51BLLP6', NULL, 'Mr.', 'DANNY', 'BUIS', '1995-01-20', 'M', '+316263268065', 'fs-danny@hotmail.com', 'Marina hub Nethelands', '+316263268065', '+316263268065', 'Muscle Hight Tension', 'Pain reduction, Improve ROM', '', 'Lower Back', 'Daily', '1-2 weeks', '', '', '', 'Hay Fever', 1, 1, '2025-11-14 07:09:40', '2025-11-18 09:32:10'),
(77, 'PT250072', 'PT20251114165315024', 'Foreginer05', NULL, 'Mrs.', 'JOAHCHIM ', 'EUC', '2025-11-01', 'F', '', '', 'Germany', ' ', '', 'Knee pain', 'Pain reduction, Improve ROM, Strengthen muscles', '', 'Knee', 'As needed', '1-2 weeks', '', '', '', '', 1, 1, '2025-11-14 09:53:15', '2025-11-18 09:32:10'),
(78, 'PT250073', 'PT20251115121623313', NULL, 'A36670632', 'Mr.', 'Andrew', 'Harris', '1990-11-20', 'M', '+1 7192875884', 'footstepsandfootage@gmail.com', '1265 Alley Dr.SPring C.O.', '', '', 'Broken Wrist', 'Pain reduction, Improve ROM, Strengthen muscles, Improve function', '', 'Wrist/Hand', '2 times/week', '2-4 weeks', '', '', '', 'Broken Wrist(Left arm), Septioplasty (Screw/1plate)', 1, 1, '2025-11-15 05:16:23', '2025-11-18 09:32:10'),
(79, 'PT250074', 'PT20251115165200328', NULL, 'AA5754296', 'Mr.', 'TOBIAS HENRIK', 'KLERBORG', '1978-01-10', 'M', '0610572352', 'tobiasklerborg@gmail.com', 'Slowdown', '', '', 'Frozen stuck', 'Improve ROM, Strengthen muscles', '', 'Shoulder', 'As needed', '1-2 weeks', '', '', '', '', 1, 1, '2025-11-15 09:52:00', '2025-11-18 09:32:10'),
(80, 'PT250075', 'PT20251117093644976', '3450200166167', NULL, 'Mrs.', 'พัชร', 'กุลสถาพร', '1966-05-12', 'F', '0818934375', 'porhallowwiz@gmail.com', '59 ม.2 ต.เกาะลันตาใหญ่ อ.เกาะลันตา จ.กระบี่', '', '', 'Forearm pain', 'Improve ROM, Strengthen muscles', '', 'Wrist/Hand', 'Daily', '2-4 weeks', '', '', '', '', 1, 1, '2025-11-17 02:36:44', '2025-11-20 11:24:08'),
(85, 'PT250077', 'PT20251119145249687', '', 'FOREGNENO8', 'Mr.', 'SCHLANGE', 'JURGEN', '1962-08-14', 'M', '', 'js1779@gmail.com', '', '', '', 'Shoulder impingment', 'Pain reduction, Improve ROM', '', 'Shoulder', '2 times/week', '2-4 weeks', '', '', '', 'Hip replacement', 1, 1, '2025-11-19 07:52:49', NULL),
(127, 'PT250078', 'PT20251119172858-d9689e19', '1810300082577', NULL, 'Ms.', 'สุภัสสรา', 'เชื่องยาง', '1996-08-31', 'F', '0833897750', '', '', '', '', 'ปวดบริเวณสะโพกทั้งสองข้าง', 'Pain reduction, Improve ROM', '', 'Hip', '2 times/week', '2-4 weeks', '', '', '', 'เคยฉีดยามาแล้ว 3 ครั้ง จาก โรงพยาบาลเกาะลันตา โรงพยาบาลจริยธรรมรวมแพทย์', 1, 1, '2025-11-19 10:28:58', NULL),
(128, 'PT250079', 'PT20251120160445-6378b7ea', NULL, 'PA8116523', 'Ms.', 'LEIGH', 'KATHERINE', '1980-07-15', '', NULL, 'kathleigh5@gmail.com', '', '', '', 'Ankle sprain', 'Improve ROM, Strengthen muscles, Improve function', '', 'Ankle/Foot', '2 times/week', '2-4 weeks', '-', NULL, NULL, '-', 1, 1, '2025-11-20 09:04:45', '2025-11-21 04:57:50'),
(129, 'PT250080', 'PT20251120175940-b52d4aa7', NULL, 'AA3692451', 'Mr.', 'CHRISTER', 'SANOGREN', '1964-06-25', 'M', '', 'sandgren.christer@gmail.com', '', '', '', 'Low back pain', 'Pain reduction', '', 'Lower Back', '2 times/week', '1-2 weeks', '', '', '', '', 1, 1, '2025-11-20 10:59:40', NULL),
(130, 'PT250081', 'PT20251123182613-ff3fa447', '1909802316423', NULL, 'Miss', 'Suttida', 'Chooluan', '1998-12-04', '', '0630804644', 'suttida.cho@gmail.com', '', '', '', 'pain', 'Pain reduction, Improve ROM', '', 'Wrist/Hand', 'Daily', '1-2 weeks', '', NULL, NULL, 'na', 1, 1, '2025-11-23 11:26:13', '2025-12-17 06:15:15'),
(131, 'PT250082', 'PT20251124105419-28efd8a4', NULL, 'YB6489295', 'MR', 'Mattia', 'Brambilla', '1991-02-19', 'M', '', 'matt7ske@gmail.com', '', '', '', 'Rt. Supraspinatus tendinitis,Bicep tendinitis', 'Pain reduction, Improve ROM', '', 'Shoulder', '2 times/week', '1-2 weeks', '', '', '', '', 1, 4, '2025-11-24 03:54:19', NULL),
(132, 'PT250083', 'PT20251124112824-e92ba9ef', NULL, '20RR61046', 'Miss', 'Clara Mirabelle', 'Pin', '1998-05-02', '', NULL, 'clara.pin.02@gmail.com', '', '', '', 'external malleolus injury\n', 'Pain reduction, Improve ROM', '', 'Ankle/Foot', '2 times/week', '1-2 months', '', NULL, NULL, '', 1, 4, '2025-11-24 04:28:24', '2025-12-15 08:18:24'),
(133, 'PT250084', 'PT20251124172414-9504b5d0', NULL, 'FOREGNEN11', 'Mr.', 'Andrew ', 'Matlow', '1969-04-16', 'M', '', 'andrew@matlow.co.uk', '', '', '', 'Knee Over extension', 'Pain reduction, Improve ROM', '', 'Knee', '2 times/week', '1-2 weeks', '', '', '', 'Knee opearation', 1, 1, '2025-11-24 10:24:14', NULL),
(134, 'PT250085', 'PT20251125092526-60a4c72b', NULL, 'FOREGNEN12', 'Mr.', 'ประทุม', 'แก้วมณี', '2025-01-01', 'M', '0612520654', 'info@lantavafix.com', '', '', '', 'หมอนรองกระดูกทับเส้นประสาท', 'Pain reduction, Improve ROM', '', 'Hip', '2 times/week', '1-2 weeks', '', '', '', '', 1, 1, '2025-11-25 02:25:26', NULL),
(135, 'PT250086', 'PT20251125105636-b8dd3feb', NULL, 'A36464691', 'Miss', 'Shannon', 'Hendrikson', '1998-07-29', 'F', '', 'shannon.renee.hen@gmail.com', '', '', '', 'Ankle pain, Deltoid ligament,Calcaneofibular ligament', 'Pain reduction, Improve ROM', '', 'Ankle/Foot', '2 times/week', '1-2 weeks', '', '', '', '', 1, 1, '2025-11-25 03:56:36', NULL),
(136, 'PT250087', 'PT20251125121014-bb5fe2e0', NULL, '575956804', 'Miss', 'GINA', 'Churchill', '1971-05-01', 'F', '', 'ginagx10@gmail.com', '', '', '', 'Shoulder pain', 'Pain reduction, Improve ROM', '', 'Neck', '2 times/week', '1-2 weeks', '', '', '', 'ME/CFS, Hypertension,CKD Stage3', 1, 1, '2025-11-25 05:10:14', NULL),
(137, 'PT250088', 'PT20251125162932-8d5c5959', NULL, 'YCO361876', 'Mrs.', 'FRANCESCA', 'CONVERTINI', '1959-12-03', 'F', '', 'convertinifrancesca@gmail.com', '', '', '', 'Lateral Patellar Retinaculum Left', 'Pain reduction, Improve ROM', '', '', '', '', '', '', '', 'Fibromyaglia', 1, 1, '2025-11-25 09:29:32', NULL),
(138, 'PT250089', 'PT20251126090734-f3fd7ce4', NULL, '130853035', 'Mr.', 'CRIAG', 'GIBSON', '1983-07-16', 'M', '', 'gibsonsteel@outlook.com', '', '', '', 'Perififomis syndrom', 'Pain reduction, Improve ROM', '', 'Hip', '2 times/week', '1-2 weeks', '', '', '', '', 1, 1, '2025-11-26 02:07:34', NULL),
(139, 'PT250090', 'PT20251126193229-bb7888ba', NULL, 'FOREGNEN13', 'Mrs.', 'Olivia ', 'Denman', '2025-12-01', 'F', '', '', '', '', '', 'ITB ', 'Pain reduction', '', 'Hip', '2 times/week', '1-2 weeks', '', '', '', '', 1, 1, '2025-11-26 12:32:29', NULL),
(140, 'PT250091', 'PT20251127164228-f7a5f999', NULL, 'FOREGNEN14', 'Mrs.', 'Marta ', 'Wasiakowska', '1961-01-01', 'F', '0957695557', 'watram1@gmail.com', '', '', '', 'Lower back pain', 'Pain reduction', '', 'Lower Back', 'Weekly', '1-2 weeks', '', '', '', '', 1, 1, '2025-11-27 09:42:28', NULL),
(141, 'PT250092', 'PT20251128145619-a95645b0', NULL, '560728602', 'Mr.', 'SIMON', 'YEATMAN', '1974-08-04', '', NULL, 'simon@theyeatmans.co.uk', '', '', '', 'PVM', 'Pain reduction, Improve ROM', '', 'Upper Back', '2 times/week', '1-2 weeks', '', NULL, NULL, 'Autism/ADHD', 1, 1, '2025-11-28 07:56:19', '2025-12-05 09:47:11'),
(142, 'PT250093', 'PT20251129151607-11a12341', NULL, 'FOREGINER10', '', 'บุญจิตร', 'ลองบีช', '1938-11-29', 'M', '', '', '', '', '', 'pirifprmis syndrome and LBP', 'Pain reduction, Improve ROM, Strengthen muscles', '', 'Lower Back', 'Weekly', '1-2 weeks', '', 'hypertension\nทายาละลายลิ่มเลือด', '', '', 1, 1, '2025-11-29 08:16:07', NULL),
(143, 'PT250094', 'PT20251201110625-55985446', NULL, '13S106923', 'Mrs.', 'MARINA', 'MANSILLA', '1933-03-03', 'F', '', 'MARINAMANSILLA@gmail.com', '', '', '', 'shoulder - Shoulder Sports Injury - Intensive', 'Pain reduction', '', 'Shoulder', 'Daily', '1-2 weeks', '', '', '', '', 1, 1, '2025-12-01 04:06:25', NULL),
(144, 'PT250095', 'PT20251201150344-597a54e1', '3800200308537', NULL, 'Mrs.', 'กนกกร', 'จิตติลุขาร์', '1967-10-16', 'M', '093572414', '', '', '', '', 'shoulder pain', 'Pain reduction, Improve ROM', '', 'Shoulder', 'Daily', '1-2 weeks', '', '', '', '', 1, 1, '2025-12-01 08:03:44', NULL),
(145, 'PT250096', 'PT20251201193826-6c293d28', NULL, 'C8RZZGM22', 'Ms.', 'Stephanie', 'Hecht', '1982-11-26', 'M', '', '', '', '', '', 'BACK PAIN', 'Pain reduction', '', '', '', '', '', '', '', '', 1, 1, '2025-12-01 12:38:26', NULL),
(146, 'PT250097', 'PT20251202142652-0251a507', NULL, 'FOREGNEN15', 'Mrs.', 'MONA', 'HAYMAKER', '1953-10-22', 'F', '', 'monayoga@hotmail.com', '', '', '', 'Lower back pain', 'Pain reduction', '', 'Lower Back', '2 times/week', '1-2 weeks', '', '', '', '', 1, 1, '2025-12-02 07:26:52', NULL),
(147, 'PT250098', 'PT20251202203145-6f70f9fc', NULL, 'FOREGNEN16', 'Mrs.', 'JOANNE', 'HEALY', '1970-10-30', '', NULL, 'joanne-healy@hotmail.com', '', '', '', 'ankle pain', 'Pain reduction', '', 'Ankle/Foot', '2 times/week', '2-4 weeks', '', NULL, NULL, '', 1, 4, '2025-12-02 13:31:45', '2025-12-02 13:32:25'),
(148, 'PT250099', 'PT20251203165741-c7e51294', '1810400167167', NULL, 'นาย', 'ณัฐนัย', 'ไชยบุตร', '1998-03-23', 'M', '', '', '96/1 หมู่ที่ 5    ตำบลพรุดินนา อำเภอคลองท่อม จังหวัดกระบี่', '', '', 'Pain', '', '', '', '', '', '', '', '', '', 1, 1, '2025-12-03 09:57:41', NULL),
(149, 'PT250100', 'PT20251204184720-9d9af3d1', '1102002165499', NULL, 'นางสาว', 'ธัญลักษณ์', 'ภูมิบริรักษ์', '1994-07-18', 'F', '', '', '156 หมู่ที่ 5    ตำบลเกาะลันตาใหญ่ อำเภอเกาะลันตา จังหวัดกระบี่', '', '', 'Shoulder pain', 'Pain reduction, Improve ROM', '', 'Shoulder', '2 times/week', '1-2 weeks', '', '', '', '', 1, 1, '2025-12-04 11:47:20', NULL),
(150, 'PT250101', 'PT20251205102753-29e098b6', NULL, 'FOREGNEN17', 'นางสาว', 'Merve ', 'Ayan', '1993-05-19', 'F', '+945392247919', 'ayanme19@gmail.com', '', '', '', 'Rt.chondromalacia petella', 'Pain reduction, Strengthen muscles', '', 'Knee', '2 times/week', '2-4 weeks', '', '', '', '', 1, 1, '2025-12-05 03:27:53', NULL),
(151, 'PT250102', 'PT20251205130926-2ab6ee8b', NULL, '128647234', 'Mr.', 'Jame', 'Valentine', '1974-09-21', 'M', '+447711633802', 'big.jim.valentine@gmail.com', '', '', '', 'LBP', 'Pain reduction', '', 'Lower Back', 'Daily', '1-2 weeks', '', '', '', '', 1, 1, '2025-12-05 06:09:26', NULL),
(152, 'PT250103', 'PT20251205131236-68fb31ac', '3810400458362', NULL, 'นาง', 'พิทักษ์', 'สุขกันตะ', '1962-04-22', '', '0858197558', NULL, '29/54 หมู่ที่ 5    ตำบลเกาะหลัก อำเภอเมืองประจวบคีรีขันธ์ จังหวัดประจวบคีรีขันธ์', '', '', 'Rt. Knee and Hip pain', 'Pain reduction, Improve ROM', '', 'Lower Back', '2 times/week', '2-4 weeks', '', NULL, NULL, '', 1, 1, '2025-12-05 06:12:36', '2025-12-18 07:02:50'),
(153, 'PT250104', 'PT20251208165315-c0f06683', NULL, 'FOREGINER11', 'Miss', 'LINDA', 'O\'BRYAN', '1959-05-13', 'F', '', 'info@linda-obryan.com', 'Moo.2 Friends House ', '', '', 'ITB ', 'Pain reduction, Improve ROM', '', 'Knee', '2 times/week', '2-3 months', '', '', '', '', 1, 1, '2025-12-08 09:53:15', NULL),
(154, 'PT250105', 'PT20251210085522-6e71c06e', NULL, 'FOREGNEN18', 'Mr.', 'Sung Jun', 'Kim', '1995-10-27', 'M', '', 'jko2795@gmail.com', '', '', '', 'Ulnar fx.', 'Pain reduction, Strengthen muscles', '', 'Wrist/Hand', 'Daily', '1-2 weeks', '', '', '', '', 1, 1, '2025-12-10 01:55:22', NULL),
(155, 'PT250106', 'PT20251211090249-351bff41', NULL, 'NNRPOR067', 'Mr.', 'DERRICK', 'DIKKERS', '1991-06-12', 'M', '', 'dikkers91@gmail.com', '', '', '', 'carpal pain', 'Pain reduction, Improve ROM', '', 'Wrist/Hand', 'Daily', '1-2 weeks', '', '', '', '', 1, 1, '2025-12-11 02:02:49', NULL),
(156, 'PT250107', 'PT20251211114319-015f14cb', NULL, 'FOREGNEN19', 'Mr.', 'Maximilian ', 'Mintchev', '1996-02-25', 'M', '', 'max.minthchev@gmail.com', 'Germany', '', '', 'Lower back pain', 'Pain reduction', '', 'Lower Back', '2 times/week', '1-2 weeks', '', '', '', 'Ankylosing Spondylitis', 1, 1, '2025-12-11 04:43:19', NULL),
(157, 'PT250108', 'PT20251212140025-d1cf1e92', NULL, '214318559', 'Miss', 'EMMA', 'HERBST', '1995-05-21', 'F', '+4524347031', 'emmahundahlherbst@gmail.com', '', '', '', 'HIP INTESIVE PAIN', 'Pain reduction, Improve ROM', '', 'Hip', 'Daily', '1-2 weeks', '', '', '', '', 1, 4, '2025-12-12 07:00:25', NULL),
(158, 'PT250109', 'PT20251212171524-d5d55fec', NULL, 'FOREGNEN20', 'Mr.', 'HOEGAARD ', 'HUNNK', '1974-01-01', 'M', '+0034699788838', 'lupe@lupellorens.com', '', '', '', 'Lower Back Pain', 'Improve ROM', '', 'Lower Back', 'Daily', '2-4 weeks', '', '', '', '', 1, 1, '2025-12-12 10:15:24', NULL),
(159, 'PT250110', 'PT20251214091945-b37513cc', NULL, 'C84FK4T9', 'Mr.', 'MARTIN HEINRICH RICKMER', 'KLEES', '1960-12-09', 'M', '+491723435337', 'mhrklees@aoi.com', 'DEUTSCH', '', '', 'Middle Back Pain , Fatigue from votting 13 times, ', 'Pain reduction, Improve ROM', '', 'Upper Back', '2 times/week', '1-2 weeks', '', '', '', '', 1, 1, '2025-12-14 02:19:45', NULL),
(160, 'PT250111', 'PT20251217142848-4cdc5894', NULL, 'FOREGNEN21', 'Mr.', 'Antonio', 'Lopez', '1976-09-25', 'M', '+34690293016', 'tonyogdr@gmail.com', '', '', '', 'LBP', '', '', '', '', '', '', '', '', '', 1, 4, '2025-12-17 07:28:48', NULL),
(161, 'PT250112', 'PT20251218121945-a62b2841', '3920600308835', NULL, 'นางสาว', 'ปราณี ', 'สุนาเสวีนนท์', '1946-11-11', '', NULL, NULL, '', '', '', 'Epilepsy', 'Pain reduction, Improve ROM, Strengthen muscles, Improve function', '', 'Multiple Areas', '2 times/week', 'Long-term', '', '1st AV block', NULL, 'Epilepsy,HT', 1, 1, '2025-12-18 05:19:45', '2025-12-18 07:07:03');

--
-- Triggers `patients`
--
DELIMITER $$
CREATE TRIGGER `before_patient_delete` BEFORE DELETE ON `patients` FOR EACH ROW BEGIN
    -- Log the deletion (if audit_logs table exists)
    DECLARE audit_table_exists INT;

    SELECT COUNT(*) INTO audit_table_exists
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'audit_logs';

    IF audit_table_exists > 0 THEN
        INSERT INTO audit_logs (user_id, action, entity_type, entity_id, old_values, created_at)
        VALUES (
            @current_user_id,
            'DELETE',
            'patient',
            OLD.id,
            JSON_OBJECT(
                'hn', OLD.hn,
                'pt_number', OLD.pt_number,
                'name', CONCAT(OLD.first_name, ' ', OLD.last_name),
                'clinic_id', OLD.clinic_id
            ),
            NOW()
        );
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `patients_hn_backup`
--

CREATE TABLE `patients_hn_backup` (
  `id` int(11) NOT NULL DEFAULT 0,
  `hn` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `pt_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pn_attachments`
--

CREATE TABLE `pn_attachments` (
  `id` int(11) NOT NULL,
  `pn_id` int(11) NOT NULL COMMENT 'Foreign key to pn_cases',
  `file_name` varchar(255) NOT NULL COMMENT 'Original file name',
  `file_path` varchar(500) NOT NULL COMMENT 'Storage path',
  `file_type` varchar(100) DEFAULT NULL COMMENT 'MIME type',
  `file_size` int(11) DEFAULT NULL COMMENT 'File size in bytes',
  `description` text DEFAULT NULL COMMENT 'File description',
  `uploaded_by` int(11) NOT NULL COMMENT 'User who uploaded',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Attachments for PN cases';

-- --------------------------------------------------------

--
-- Table structure for table `pn_cases`
--

CREATE TABLE `pn_cases` (
  `id` int(11) NOT NULL,
  `pn_code` varchar(50) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `diagnosis` text NOT NULL,
  `purpose` text NOT NULL,
  `status` enum('PENDING','ACCEPTED','IN_PROGRESS','COMPLETED','CANCELLED') NOT NULL DEFAULT 'PENDING',
  `source_clinic_id` int(11) NOT NULL,
  `target_clinic_id` int(11) NOT NULL,
  `referring_doctor` varchar(200) DEFAULT NULL,
  `assigned_pt_id` int(11) DEFAULT NULL,
  `course_id` int(11) DEFAULT NULL COMMENT 'Links to course for course cutting',
  `notes` text DEFAULT NULL,
  `current_medications` text DEFAULT NULL,
  `allergies` text DEFAULT NULL,
  `pn_precautions` text DEFAULT NULL,
  `pn_contraindications` text DEFAULT NULL,
  `treatment_goals` text DEFAULT NULL,
  `expected_outcomes` text DEFAULT NULL,
  `medical_notes` text DEFAULT NULL,
  `vital_signs` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`vital_signs`)),
  `pain_scale` int(11) DEFAULT NULL,
  `functional_status` text DEFAULT NULL,
  `physio_diagnosis` text DEFAULT NULL,
  `chief_complaint` text DEFAULT NULL,
  `present_history` text DEFAULT NULL,
  `initial_pain_scale` int(11) DEFAULT NULL,
  `assessed_by` int(11) DEFAULT NULL,
  `assessed_at` timestamp NULL DEFAULT NULL,
  `reversal_reason` text DEFAULT NULL,
  `accepted_at` timestamp NULL DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `cancelled_at` timestamp NULL DEFAULT NULL,
  `cancellation_reason` text DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp(),
  `pt_diagnosis` text DEFAULT NULL COMMENT 'Physiotherapy diagnosis for non-CL001 cases',
  `pt_chief_complaint` text DEFAULT NULL COMMENT 'Chief complaint for non-CL001 cases',
  `pt_present_history` text DEFAULT NULL COMMENT 'Present history for non-CL001 cases',
  `pt_pain_score` int(11) DEFAULT NULL COMMENT 'Pain score 0-10 for non-CL001 cases',
  `is_reversed` tinyint(1) DEFAULT 0,
  `last_reversal_reason` text DEFAULT NULL,
  `last_reversed_at` datetime DEFAULT NULL,
  `temp_year` varchar(4) DEFAULT NULL,
  `temp_month` varchar(2) DEFAULT NULL,
  `temp_seq` int(11) DEFAULT NULL,
  `body_annotation_id` int(11) DEFAULT NULL COMMENT 'Reference to body annotation (for body part rechecks)',
  `recheck_body_part` tinyint(1) DEFAULT 0 COMMENT 'Flag indicating if body part recheck is required'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `pn_cases`
--

INSERT INTO `pn_cases` (`id`, `pn_code`, `patient_id`, `diagnosis`, `purpose`, `status`, `source_clinic_id`, `target_clinic_id`, `referring_doctor`, `assigned_pt_id`, `course_id`, `notes`, `current_medications`, `allergies`, `pn_precautions`, `pn_contraindications`, `treatment_goals`, `expected_outcomes`, `medical_notes`, `vital_signs`, `pain_scale`, `functional_status`, `physio_diagnosis`, `chief_complaint`, `present_history`, `initial_pain_scale`, `assessed_by`, `assessed_at`, `reversal_reason`, `accepted_at`, `completed_at`, `cancelled_at`, `cancellation_reason`, `created_by`, `created_at`, `updated_at`, `pt_diagnosis`, `pt_chief_complaint`, `pt_present_history`, `pt_pain_score`, `is_reversed`, `last_reversal_reason`, `last_reversed_at`, `temp_year`, `temp_month`, `temp_seq`, `body_annotation_id`, `recheck_body_part`) VALUES
(59, 'PN25110001', 61, 'Lt.lower back pain', 'Reduce pain and increase ROM', 'COMPLETED', 1, 1, NULL, NULL, NULL, '-', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-07 08:45:05', '2025-11-07 09:00:40', NULL, NULL, 1, '2025-11-07 08:44:12', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 1, NULL, 0),
(60, 'PN25110002', 47, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-11', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-08 05:29:54', 'cancle', 1, '2025-11-07 09:02:45', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 2, NULL, 0),
(61, 'PN25110003', 62, 'มีอาการชาปวดร้าวไปถึงปลาย ขาทั้ง 2 ข้าง ในท่าหดกล้ามเนื้อ', 'ลดอาการร้าวขาทั้ง 2 ข้าว', 'COMPLETED', 1, 1, NULL, NULL, NULL, NULL, '', '', '', '', 'Reduce pain and numbness', '', '', NULL, 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-08 05:28:12', '2025-11-08 10:58:19', NULL, NULL, 1, '2025-11-08 05:18:54', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 3, NULL, 0),
(62, 'PN25110004', 47, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-11', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-08 11:40:21', 'Cancle', 1, '2025-11-08 05:30:31', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 4, NULL, 0),
(63, 'PN25110005', 18, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-08', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-08 08:39:58', NULL, '2025-11-08 08:44:47', 'Change person ', 1, '2025-11-08 05:59:45', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 5, NULL, 0),
(64, 'PN25110006', 57, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-08', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-08 06:08:02', 'wrong', 1, '2025-11-08 06:06:20', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 6, NULL, 0),
(65, 'PN25110007', 57, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-08', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-08 06:42:28', 'Wrong person', 1, '2025-11-08 06:08:42', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 7, NULL, 0),
(66, 'PN25110008', 59, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-08', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-08 07:43:50', 'Wrong person', 1, '2025-11-08 06:42:53', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 8, NULL, 0),
(67, 'PN25110009', 63, 'Rt.SI joint dysfuction', 'reduce pain', 'COMPLETED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-08 08:45:17', '2025-11-08 10:56:44', NULL, NULL, 1, '2025-11-08 08:43:41', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 9, NULL, 0),
(68, 'PN25110010', 47, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-11', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-11 06:09:35', '2025-11-11 13:03:30', NULL, NULL, 1, '2025-11-08 15:33:25', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 10, NULL, 0),
(69, 'PN25110011', 47, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-12', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-12 06:38:03', '2025-11-12 08:32:07', NULL, NULL, 1, '2025-11-10 02:08:56', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 11, NULL, 0),
(70, 'PN25110012', 64, 'Hip stiffness', 'Improve eange of motion and reduce pain', 'CANCELLED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-10 02:39:13', 'ca', 1, '2025-11-10 02:35:32', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 12, NULL, 0),
(71, 'PN25110013', 64, 'Hip stiffness', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-10', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-10 04:17:20', '2025-11-10 08:29:09', NULL, NULL, 1, '2025-11-10 02:40:17', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 13, NULL, 0),
(72, 'PN25110014', 65, 'neck stiffness', 'improve range of motion', 'CANCELLED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-10 04:29:15', 'ca', 1, '2025-11-10 04:28:34', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 14, NULL, 0),
(73, 'PN25110015', 65, 'neck stiffness', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-10', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-10 08:29:26', '2025-11-10 08:35:30', NULL, NULL, 1, '2025-11-10 04:29:47', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 15, NULL, 0),
(74, 'PN25110016', 11, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-10', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-10 08:53:00', '2025-11-10 09:39:38', NULL, NULL, 1, '2025-11-10 06:56:08', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 16, NULL, 0),
(75, 'PN25110017', 44, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-11', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-11 12:58:52', '2025-11-11 13:38:34', NULL, NULL, 1, '2025-11-10 09:06:48', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 17, NULL, 0),
(76, 'PN25110018', 66, 'Heel', 'Reduce pain', 'COMPLETED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-10 11:03:43', '2025-11-11 02:41:47', NULL, NULL, 1, '2025-11-10 11:02:54', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 18, NULL, 0),
(77, 'PN25110019', 64, 'Hip stiffness', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-11', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-11 08:29:40', '2025-11-11 13:07:55', NULL, NULL, 1, '2025-11-11 06:25:34', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 19, NULL, 0),
(78, 'PN25110020', 4, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-13', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-11 08:18:57', 'ก', 1, '2025-11-11 08:17:30', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 20, NULL, 0),
(79, 'PN25110021', 4, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-13', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-11 08:19:58', 'ก', 1, '2025-11-11 08:19:33', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 21, NULL, 0),
(80, 'PN25110022', 66, 'Heel', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-12', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-12 07:47:22', 'ca', 1, '2025-11-11 10:27:49', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 22, NULL, 0),
(81, 'PN25110023', 4, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-14', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-11 12:00:25', 'ทดสอบ', 1, '2025-11-11 11:55:56', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 23, NULL, 0),
(82, 'PN25110024', 67, 'ทดสอบ', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-14', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-11 12:02:01', 'ทดสอย', 1, '2025-11-11 12:00:52', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 24, NULL, 0),
(83, 'PN25110025', 67, 'ทดสอบ', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-15', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-11 12:09:16', 'ds', 1, '2025-11-11 12:02:41', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 25, NULL, 0),
(84, 'PN25110026', 67, 'ทดสอบ', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-13', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-11 12:16:00', 'ทดสอบ ', 1, '2025-11-11 12:09:59', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 26, NULL, 0),
(85, 'PN25110027', 67, 'ทดสอบ', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-14', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-11 12:17:19', 'Cancelled from appointment', 1, '2025-11-11 12:16:36', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 27, NULL, 0),
(86, 'PN25110028', 67, 'ทดสอบ', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-13', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-11 12:26:18', 'กแ', 1, '2025-11-11 12:18:20', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 28, NULL, 0),
(87, 'PN25110029', 67, 'ทดสอบ', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-13', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-11 12:35:16', 'ca', 1, '2025-11-11 12:26:37', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 29, NULL, 0),
(88, 'PN25110030', 67, 'ทดสอบ', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-15', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-11 13:11:21', 'CA', 1, '2025-11-11 12:35:41', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 30, NULL, 0),
(89, 'PN25110031', 67, 'ทดสอบ', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-13', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-11 13:38:17', 'ca', 1, '2025-11-11 13:31:53', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 31, NULL, 0),
(90, 'PN25110032', 67, 'ทดสอบ', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-15', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-11 13:56:20', 'ca', 1, '2025-11-11 13:39:56', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 32, NULL, 0),
(91, 'PN25110033', 67, 'ทดสอบ', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-16', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-11 14:04:51', 'ca', 1, '2025-11-11 13:56:59', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 33, NULL, 0),
(92, 'PN25110034', 67, 'ทดสอบ', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-14', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-11 16:05:53', 'ca', 1, '2025-11-11 14:05:18', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 34, NULL, 0),
(93, 'PN25110035', 67, 'ทดสอบ', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-15', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-11 16:05:49', 'c', 1, '2025-11-11 15:01:35', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 35, NULL, 0),
(94, 'PN25110036', 67, 'ทดสอบ', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-19', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-12 03:39:44', 'ca', 1, '2025-11-11 15:52:18', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 36, NULL, 0),
(95, 'PN25110037', 67, 'ทดสอบ', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-19', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-12 03:39:39', 'ca', 1, '2025-11-11 15:57:08', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 37, NULL, 0),
(96, 'PN25110038', 67, 'ทดสอบ', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-14', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-11 16:07:55', 'แฟ', 1, '2025-11-11 16:06:31', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 38, NULL, 0),
(97, 'PN25110039', 67, 'ทดสอบ', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-14', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-11 16:28:10', 'Cancelled from appointment', 1, '2025-11-11 16:08:15', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 39, NULL, 0),
(98, 'PN25110040', 67, 'ทดสอบ', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-13', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-11 16:28:14', 'Cancelled from appointment', 1, '2025-11-11 16:19:49', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 40, NULL, 0),
(99, 'PN25110041', 67, 'ทดสอบ', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-12', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-11 16:34:29', 'ca', 1, '2025-11-11 16:28:33', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 41, NULL, 0),
(100, 'PN25110042', 67, 'ทดสอบ', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-13', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-11 16:42:55', 'Cancelled from appointment', 1, '2025-11-11 16:34:48', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 42, NULL, 0),
(101, 'PN25110043', 67, 'ทดสอบ', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-13', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-11 16:50:52', 'ca', 1, '2025-11-11 16:43:27', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 43, NULL, 0),
(102, 'PN25110044', 67, 'ทดสอบ', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-18', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-12 03:39:36', 'ca', 1, '2025-11-11 16:51:10', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 44, NULL, 0),
(103, 'PN25110045', 67, 'ทดสอบ', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-13', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-12 01:46:40', 'CA', 1, '2025-11-12 01:45:23', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 45, NULL, 0),
(104, 'PN25110046', 67, 'ทดสอบ', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-12', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-12 03:44:32', 'ca', 1, '2025-11-12 03:40:12', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 46, NULL, 0),
(105, 'PN25110047', 68, 'Hip pain', 'Pain reduce', 'COMPLETED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-12 03:52:47', '2025-11-12 08:47:33', NULL, NULL, 1, '2025-11-12 03:52:09', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 47, NULL, 0),
(106, 'PN25110048', 66, 'Heel', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-12', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-12 12:32:20', '2025-11-12 12:37:47', NULL, NULL, 1, '2025-11-12 07:34:51', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 48, NULL, 0),
(107, 'PN25110049', 67, 'ทดสอบ', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-12', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-12 07:42:24', 'ca', 1, '2025-11-12 07:36:17', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 49, NULL, 0),
(108, 'PN25110050', 47, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-14', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-12 08:23:07', 'ca', 1, '2025-11-12 08:08:44', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 50, NULL, 0),
(109, 'PN25110051', 69, 'Knee accident', 'Reduce pain', 'COMPLETED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-12 08:19:44', '2025-11-12 08:45:30', NULL, NULL, 1, '2025-11-12 08:18:54', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 51, NULL, 0),
(110, 'PN25110052', 47, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-14', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-17 07:36:30', NULL, '2025-11-17 07:41:29', 'CA', 1, '2025-11-12 08:23:30', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 52, NULL, 0),
(111, 'PN25110053', 47, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-12', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-12 08:47:11', NULL, '2025-11-12 08:47:21', 'ca', 1, '2025-11-12 08:46:21', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 53, NULL, 0),
(112, 'PN25110054', 69, 'Knee accident', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-15', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-15 08:46:02', '2025-11-17 02:54:27', NULL, NULL, 1, '2025-11-12 10:52:27', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 54, NULL, 0),
(113, 'PN25110055', 65, 'neck stiffness', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-13', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-13 06:03:10', '2025-11-13 08:24:42', NULL, NULL, 1, '2025-11-13 03:14:28', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 55, NULL, 0),
(114, 'PN25110056', 70, 'Muay thai elbow pain', 'Improve range of motion , relief pain', 'COMPLETED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-13 03:28:33', '2025-11-13 05:45:32', NULL, NULL, 1, '2025-11-13 03:27:54', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 56, NULL, 0),
(115, 'PN25110057', 71, 'ทดสวอบ', 'ก', 'CANCELLED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-13 04:30:56', 'ca', 1, '2025-11-13 04:29:53', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 57, NULL, 0),
(116, 'PN25110058', 71, 'ทดสวอบ', 'ทดสอบ', 'CANCELLED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-13 04:34:22', 'ca', 1, '2025-11-13 04:32:59', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 58, NULL, 0),
(117, 'PN25110059', 71, 'ทดสวอบ', 'Popupcheck ', 'CANCELLED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-13 04:53:20', 'ca', 1, '2025-11-13 04:46:29', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 59, NULL, 0),
(118, 'PN25110060', 71, 'ทดสวอบ', 'ทดสอบ', 'CANCELLED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-13 04:56:17', 'ca', 1, '2025-11-13 04:53:41', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 60, NULL, 0),
(119, 'PN25110061', 71, 'ทดสวอบ', 'ทดสอบ', 'CANCELLED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-13 04:57:05', NULL, '2025-11-13 05:05:11', 'ca', 1, '2025-11-13 04:56:44', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 61, NULL, 0),
(120, 'PN25110062', 71, 'ทดสวอบ', 'ทดสอบ', 'CANCELLED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-13 05:12:22', 'แฟ', 1, '2025-11-13 05:10:57', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 62, NULL, 0),
(121, 'PN25110063', 71, 'ทดสวอบ', 'ทด', 'CANCELLED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-13 05:28:58', 'ca', 1, '2025-11-13 05:24:02', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 63, NULL, 0),
(122, 'PN25110064', 67, 'ทดสอบ', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-13', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-13 05:28:25', NULL, '2025-11-13 05:28:39', 'แฟ', 1, '2025-11-13 05:28:01', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 64, NULL, 0),
(123, 'PN25110065', 71, 'ทดสวอบ', 'ทดสอบ', 'CANCELLED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-13 05:37:55', NULL, '2025-11-13 05:38:12', 'ca', 1, '2025-11-13 05:37:01', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 65, NULL, 0),
(124, 'PN25110066', 71, 'ทดสวอบ', 'ทสดอบ', 'CANCELLED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-13 05:58:48', 'ca', 1, '2025-11-13 05:46:06', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 66, NULL, 0),
(125, 'PN25110067', 71, 'ทดสวอบ', 'c', 'CANCELLED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-13 05:59:52', NULL, '2025-11-13 06:00:04', 'ca', 1, '2025-11-13 05:59:21', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 67, NULL, 0),
(126, 'PN25110068', 72, 'Muay thai class ', 'Improve range of motion', 'COMPLETED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-14 02:21:06', '2025-11-14 04:02:20', NULL, NULL, 1, '2025-11-14 02:19:17', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 68, NULL, 0),
(127, 'PN25110069', 73, 'Muscle Hight Tension', 'Pain reduction', 'COMPLETED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-14 07:10:12', '2025-11-14 09:57:22', NULL, NULL, 1, '2025-11-14 07:09:49', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 69, NULL, 0),
(128, 'PN25110070', 77, 'Knee pain', 'pain reduce', 'COMPLETED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-14 09:55:12', '2025-11-15 02:30:14', NULL, NULL, 1, '2025-11-14 09:53:24', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 70, NULL, 0),
(129, 'PN25110071', 28, 'Pain relief', 'Back relief', 'COMPLETED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-14 11:01:18', '2025-11-15 02:36:40', NULL, NULL, 1, '2025-11-14 11:01:05', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 71, NULL, 0),
(130, 'PN25110072', 78, 'Broken Wrist', 'Pain reduce', 'COMPLETED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-15 05:16:54', '2025-11-15 07:01:57', NULL, NULL, 1, '2025-11-15 05:16:34', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 72, NULL, 0),
(131, 'PN25110073', 79, 'Frozen stuck', 'Increase Range of Motion', 'COMPLETED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-15 10:48:46', '2025-11-17 02:57:02', NULL, NULL, 1, '2025-11-15 09:52:13', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 73, NULL, 0),
(132, 'PN25110074', 80, 'Forearm pain', 'Improve range', 'CANCELLED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-17 03:10:06', 'ca', 1, '2025-11-17 02:36:55', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 74, NULL, 0),
(133, 'PN25110075', 80, 'Forearm pain', 'Improve range of motion', 'CANCELLED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-17 03:42:29', NULL, '2025-11-17 03:46:39', 'ca', 1, '2025-11-17 03:10:21', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 75, NULL, 0),
(134, 'PN25110076', 80, 'Forearm pain', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-17', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-17 04:02:47', '2025-11-17 08:33:14', NULL, NULL, 1, '2025-11-17 03:47:03', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 76, NULL, 0),
(135, 'PN25110077', 72, 'Muay thai class ', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-18', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-18 04:04:53', '2025-11-18 08:19:23', NULL, NULL, 1, '2025-11-17 04:05:37', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 77, NULL, 0),
(136, 'PN25110078', 38, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-18', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-18 07:43:08', '2025-11-18 08:26:51', NULL, NULL, 1, '2025-11-17 05:13:49', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 78, NULL, 0),
(137, 'PN25110079', 47, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-18', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-17 07:39:57', 'CA', 1, '2025-11-17 07:39:34', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 79, NULL, 0),
(138, 'PN25110080', 47, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-18', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-18 11:14:30', '2025-11-18 11:19:39', NULL, NULL, 1, '2025-11-17 07:40:39', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 80, NULL, 0),
(139, 'PN25110081', 47, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-17', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-17 07:53:29', '2025-11-17 08:43:14', NULL, NULL, 1, '2025-11-17 07:42:03', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 81, NULL, 0),
(140, 'PN25110082', 78, 'Broken Wrist', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-19', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-19 04:53:24', '2025-11-19 07:37:29', NULL, NULL, 1, '2025-11-18 03:02:37', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 82, NULL, 0),
(141, 'PN25110083', 81, 'Pain chest', 'na\n', 'CANCELLED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-18 04:41:35', 'ca', 1, '2025-11-18 04:40:49', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 83, NULL, 0),
(142, 'PN25110084', 47, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-19 04:35:27', 'ca', 1, '2025-11-18 10:51:00', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 84, NULL, 0),
(143, 'PN25110085', 47, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-19 04:49:19', 'ca', 1, '2025-11-19 04:41:29', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 85, NULL, 0),
(144, 'PN25110086', 47, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-19 05:42:54', NULL, '2025-11-19 05:44:30', 'ca', 1, '2025-11-19 04:49:52', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 86, NULL, 0),
(145, 'PN25110087', 47, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-20 11:04:19', 'ca', 1, '2025-11-19 05:45:32', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 87, NULL, 0),
(146, 'PN25110088', 85, 'Shoulder impingment', 'Improve range of motion and pain relief', 'CANCELLED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-19 07:54:19', 'dq', 1, '2025-11-19 07:53:17', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 88, NULL, 0),
(147, 'PN25110089', 85, 'Shoulder impingment', 'improve range of motion', 'COMPLETED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-19 07:54:54', '2025-11-19 09:53:49', NULL, NULL, 1, '2025-11-19 07:54:39', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 89, NULL, 0),
(148, 'PN25110090', 127, 'ปวดบริเวณสะโพกทั้งสองข้าง', 'ลดปวด และ บวม', 'COMPLETED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-19 10:49:15', '2025-11-19 11:46:21', NULL, NULL, 1, '2025-11-19 10:29:13', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 90, NULL, 0),
(149, 'PN25110091', 84, 'Frozen shoulder from accident', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-20', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-19 10:54:50', 'ca', 1, '2025-11-19 10:54:37', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 91, NULL, 0),
(150, 'PN25110092', 84, 'Frozen shoulder from accident', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-20', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-20 09:02:34', 'ca', 1, '2025-11-20 08:51:49', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 92, NULL, 0),
(151, 'PN25110093', 128, 'Ankle sprain', 'Improve range of motion', 'COMPLETED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-20 09:05:58', '2025-11-20 11:16:52', NULL, NULL, 1, '2025-11-20 09:04:58', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 93, NULL, 0),
(152, 'PN25110094', 84, 'Frozen shoulder from accident', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-20', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-20 09:27:34', 'ca', 1, '2025-11-20 09:08:07', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 94, NULL, 0),
(153, 'PN25110095', 84, 'Frozen shoulder from accident', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-20', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-20 09:29:29', 'ca', 1, '2025-11-20 09:28:21', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 95, NULL, 0),
(154, 'PN25110096', 84, 'Frozen shoulder from accident', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-27', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-20 15:20:44', 'ca', 1, '2025-11-20 09:30:12', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 96, NULL, 0),
(155, 'PN25110097', 84, 'Frozen shoulder from accident', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-21', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-20 10:02:00', 'ca', 1, '2025-11-20 10:00:53', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 97, NULL, 0),
(156, 'PN25110098', 84, 'Frozen shoulder from accident', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-20', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-20 10:31:17', 'ca', 1, '2025-11-20 10:02:41', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 98, NULL, 0),
(157, 'PN25110099', 84, 'Frozen shoulder from accident', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-20', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-20 10:43:58', 'ca', 1, '2025-11-20 10:43:13', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 99, NULL, 0),
(158, 'PN25110100', 84, 'Frozen shoulder from accident', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-21', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-20 10:45:52', 'ca', 1, '2025-11-20 10:44:10', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 100, NULL, 0),
(159, 'PN25110101', 84, 'Frozen shoulder from accident', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-20', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-20 10:48:02', 'ca', 1, '2025-11-20 10:47:16', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 101, NULL, 0),
(160, 'PN25110102', 84, 'Frozen shoulder from accident', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-20', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-20 10:57:23', 'ca', 1, '2025-11-20 10:55:08', '2025-11-21 04:35:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 102, NULL, 0),
(161, 'PN25110103', 129, 'Low back pain', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-21', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-21 05:58:16', '2025-11-21 10:08:33', NULL, NULL, 1, '2025-11-20 11:00:30', '2025-11-21 10:08:33', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 103, NULL, 0),
(162, 'PN25110104', 47, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-21 06:55:10', 'ca', 1, '2025-11-20 11:04:46', '2025-11-21 06:55:10', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 104, NULL, 0),
(163, 'PN25110105', 28, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-21', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-21 01:57:20', '2025-11-21 10:10:03', NULL, NULL, 1, '2025-11-20 11:06:48', '2025-11-21 10:10:03', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 105, NULL, 0),
(164, 'PN25110106', 85, 'Shoulder impingment', 'Improve range of Motion', 'COMPLETED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-21 03:46:36', '2025-11-21 10:11:07', NULL, NULL, 1, '2025-11-21 03:44:40', '2025-11-21 10:11:07', NULL, NULL, NULL, NULL, 0, NULL, NULL, '2025', '11', 106, NULL, 0),
(165, 'PN25110107', 84, 'Frozen shoulder from accident', 'No', 'CANCELLED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-21 04:37:55', 'ca', 1, '2025-11-21 04:36:52', '2025-11-21 04:37:55', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(166, 'PN25110108', 84, 'Frozen shoulder from accident', 'no', 'CANCELLED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-21 04:44:08', 'ca', 1, '2025-11-21 04:43:20', '2025-11-21 04:44:08', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(167, 'PN25110109', 84, 'Frozen shoulder from accident', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-21', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-21 06:24:56', 'ca', 1, '2025-11-21 06:23:40', '2025-11-21 06:24:56', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(168, 'PN25110110', 84, 'Frozen shoulder from accident', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-21', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-21 06:57:28', 'ca', 1, '2025-11-21 06:54:45', '2025-11-21 06:57:28', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(169, 'PN25110111', 47, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-22 06:15:11', '2025-11-22 11:52:13', NULL, NULL, 1, '2025-11-21 07:00:37', '2025-11-22 11:52:13', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(170, 'PN25110112', 53, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-21 12:42:57', NULL, '2025-11-21 12:44:48', 'ca', 1, '2025-11-21 11:47:13', '2025-11-21 12:44:48', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(171, 'PN25110113', 84, 'Frozen shoulder from accident', 'check', 'CANCELLED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-21 12:06:05', 'ca', 1, '2025-11-21 12:05:50', '2025-11-21 12:06:05', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(172, 'PN25110114', 84, 'Frozen shoulder from accident', 'check', 'CANCELLED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-21 12:29:17', 'ca', 1, '2025-11-21 12:06:52', '2025-11-21 12:29:17', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(173, 'PN25110115', 84, 'Frozen shoulder from accident', 'vf', 'CANCELLED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-21 12:29:22', 'ca', 1, '2025-11-21 12:07:23', '2025-11-21 12:29:22', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(174, 'PN25110116', 84, 'Frozen shoulder from accident', 'ca', 'CANCELLED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-21 12:42:58', NULL, '2025-11-21 12:44:27', 'ca', 1, '2025-11-21 12:29:32', '2025-11-21 12:44:27', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(175, 'PN25110117', 84, 'Frozen shoulder from accident', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-21 12:44:11', NULL, '2025-11-21 13:05:42', 'ca', 1, '2025-11-21 12:29:56', '2025-11-21 13:05:42', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0);
INSERT INTO `pn_cases` (`id`, `pn_code`, `patient_id`, `diagnosis`, `purpose`, `status`, `source_clinic_id`, `target_clinic_id`, `referring_doctor`, `assigned_pt_id`, `course_id`, `notes`, `current_medications`, `allergies`, `pn_precautions`, `pn_contraindications`, `treatment_goals`, `expected_outcomes`, `medical_notes`, `vital_signs`, `pain_scale`, `functional_status`, `physio_diagnosis`, `chief_complaint`, `present_history`, `initial_pain_scale`, `assessed_by`, `assessed_at`, `reversal_reason`, `accepted_at`, `completed_at`, `cancelled_at`, `cancellation_reason`, `created_by`, `created_at`, `updated_at`, `pt_diagnosis`, `pt_chief_complaint`, `pt_present_history`, `pt_pain_score`, `is_reversed`, `last_reversal_reason`, `last_reversed_at`, `temp_year`, `temp_month`, `temp_seq`, `body_annotation_id`, `recheck_body_part`) VALUES
(176, 'PN25110118', 84, 'Frozen shoulder from accident', 'ds', 'CANCELLED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-21 12:44:30', 'ca', 1, '2025-11-21 12:31:20', '2025-11-21 12:44:30', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(177, 'PN25110119', 84, 'Frozen shoulder from accident', 'fd', 'CANCELLED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-21 12:44:34', 'ca', 1, '2025-11-21 12:32:26', '2025-11-21 12:44:34', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(178, 'PN25110120', 84, 'Frozen shoulder from accident', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-21', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-21 13:05:57', 'ca', 1, '2025-11-21 12:45:04', '2025-11-21 13:05:57', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(179, 'PN25110121', 84, 'Frozen shoulder from accident', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-21', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-21 13:12:27', NULL, '2025-11-21 13:21:22', 'ca', 1, '2025-11-21 13:06:49', '2025-11-21 13:21:22', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(180, 'PN25110122', 84, 'Frozen shoulder from accident', 'c', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'c', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-21 13:11:43', NULL, '2025-11-21 13:21:30', 'ca', 1, '2025-11-21 13:09:38', '2025-11-21 13:21:30', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(181, 'PN25110123', 84, 'Frozen shoulder froms accident', 's', 'CANCELLED', 1, 1, NULL, NULL, NULL, 's', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-21 13:12:57', NULL, '2025-11-21 13:21:35', 'ca', 1, '2025-11-21 13:12:50', '2025-11-21 13:21:35', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(182, 'PN25110124', 84, 'Frozen shoulder from accident', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-21', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-21 13:22:55', NULL, '2025-11-21 13:23:53', 'ca', 1, '2025-11-21 13:21:58', '2025-11-21 13:23:53', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(183, 'PN25110125', 84, 'Frozen shoulder from accident', 's', 'CANCELLED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-21 13:23:29', NULL, '2025-11-21 13:23:59', 'ca', 1, '2025-11-21 13:23:11', '2025-11-21 13:23:59', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(184, 'PN25110126', 84, 'Frozen shoulder from accident', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-21 13:25:12', NULL, '2025-11-21 13:47:49', 'ca', 1, '2025-11-21 13:24:45', '2025-11-21 13:47:49', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, 6, 0),
(185, 'PN25110127', 84, 'Frozen shoulder from accident', 'ds', 'CANCELLED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-21 13:47:26', 'ca', 1, '2025-11-21 13:26:03', '2025-11-21 13:47:26', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(186, 'PN25110128', 84, 'Frozen shoulder from accident', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-21', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-21 13:49:20', NULL, '2025-11-21 13:49:53', 'ca', 1, '2025-11-21 13:48:07', '2025-11-21 13:49:53', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, 7, 0),
(187, 'PN25110129', 84, 'Frozen shoulder frsom accident', 's', 'CANCELLED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-21 13:54:54', NULL, '2025-11-21 13:54:57', 'ca', 1, '2025-11-21 13:50:04', '2025-11-21 13:54:57', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(188, 'PN25110130', 53, 'Pain relief', 'Knee pain', 'COMPLETED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-21 13:54:09', '2025-11-22 02:44:14', NULL, NULL, 1, '2025-11-21 13:53:32', '2025-11-22 02:44:14', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(189, 'PN25110131', 84, 'Frozen shoulder from accident', 'ds', 'CANCELLED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-21 14:01:54', NULL, '2025-11-21 14:13:11', 'ca', 1, '2025-11-21 13:59:57', '2025-11-21 14:13:11', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(190, 'PN25110132', 84, 'Frozen shoulder from accident', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-21 14:03:14', NULL, '2025-11-21 14:13:16', 'ca', 1, '2025-11-21 14:02:37', '2025-11-21 14:13:16', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, 8, 0),
(191, 'PN25110133', 84, 'Frozen shoulder from accident', 's', 'CANCELLED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-21 14:17:52', NULL, '2025-11-21 14:19:05', 'ca', 1, '2025-11-21 14:13:31', '2025-11-21 14:19:05', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(192, 'PN25110134', 84, 'Frozen shoulder from accident', 'sa', 'CANCELLED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-21 15:16:21', NULL, '2025-11-21 15:16:38', 'ca', 1, '2025-11-21 14:19:14', '2025-11-21 15:16:38', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(193, 'PN25110135', 84, 'Frozen shoulder from accident', 'sad', 'CANCELLED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-21 15:17:17', NULL, '2025-11-21 15:40:51', 'ca', 1, '2025-11-21 15:17:04', '2025-11-21 15:40:51', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(194, 'PN25110136', 84, 'Frozen shoulder from accident', 'asd', 'CANCELLED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-21 15:40:09', NULL, '2025-11-21 15:40:55', 'ca', 1, '2025-11-21 15:38:05', '2025-11-21 15:40:55', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 1),
(195, 'PN25110137', 84, 'Frozen shoulder from accident', 'ca', 'CANCELLED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-21 15:56:38', NULL, '2025-11-21 15:56:49', 'ca', 1, '2025-11-21 15:41:06', '2025-11-21 15:56:49', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, 12, 1),
(196, 'PN25110138', 84, 'Frozen shoulder from accident', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-21 15:42:30', NULL, '2025-11-21 16:30:29', 'ca', 1, '2025-11-21 15:41:57', '2025-11-21 16:30:29', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, 11, 0),
(197, 'PN25110139', 84, 'Frozen shoulder from accident', 'ca', 'CANCELLED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-21 15:57:58', NULL, '2025-11-21 16:30:37', 'ca', 1, '2025-11-21 15:57:01', '2025-11-21 16:30:37', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, 13, 1),
(198, 'PN25110140', 84, 'Frozen shoulder from accident', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-21 16:31:47', 'ca', 1, '2025-11-21 16:31:29', '2025-11-21 16:31:47', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(199, 'PN25110141', 84, 'Frozen shoulder from accident', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-21 16:32:24', NULL, '2025-11-21 16:32:55', 'ca', 1, '2025-11-21 16:32:16', '2025-11-21 16:32:55', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(200, 'PN25110142', 84, 'Frozen shoulder from accident', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-21 16:33:13', NULL, '2025-11-21 16:33:17', 'ca', 1, '2025-11-21 16:33:07', '2025-11-21 16:33:17', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(201, 'PN25110143', 84, 'Frozen shoulder from accident', 'dsa', 'CANCELLED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-21 17:17:34', 'ca', 1, '2025-11-21 16:34:12', '2025-11-21 17:17:34', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 1),
(202, 'PN25110144', 84, 'Frozen shoulder from accident', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-21 16:41:35', NULL, '2025-11-21 16:41:58', 'ca', 1, '2025-11-21 16:41:25', '2025-11-21 16:41:58', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(203, 'PN25110145', 84, 'Frozen shoulder from accident', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-21 16:43:05', NULL, '2025-11-22 01:32:52', 'ca', 1, '2025-11-21 16:42:08', '2025-11-22 01:32:52', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(204, 'PN25110146', 84, 'Frozen shoulder from accident', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-22 02:35:06', NULL, '2025-11-22 02:36:39', 'ca', 1, '2025-11-22 02:28:35', '2025-11-22 02:36:39', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(205, 'PN25110147', 84, 'Frozen shoulder from accident', 'ads', 'CANCELLED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-22 02:35:40', NULL, '2025-11-22 02:36:29', 'ca', 1, '2025-11-22 02:31:33', '2025-11-22 02:36:29', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, 16, 1),
(206, 'PN25110148', 84, 'Frozen shoulder from accident', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-22 02:46:49', NULL, '2025-11-22 02:48:08', 'ca', 1, '2025-11-22 02:41:14', '2025-11-22 02:48:08', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(207, 'PN25110149', 84, 'Frozen shoulder from accident', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-22 02:59:51', NULL, '2025-11-22 03:06:04', 'ca', 1, '2025-11-22 02:59:19', '2025-11-22 03:06:04', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(208, 'PN25110150', 84, 'Frozen shoulder from accident', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-22 03:06:41', NULL, '2025-11-22 03:11:43', 'ca', 1, '2025-11-22 03:06:21', '2025-11-22 03:11:43', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, 19, 0),
(209, 'PN25110151', 84, 'Frozen shoulder from accident', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-22 03:13:08', 'ca', 1, '2025-11-22 03:12:43', '2025-11-22 03:13:08', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(210, 'PN25110152', 84, 'Frozen shoulder from accident', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-22 04:26:00', 'ca', 1, '2025-11-22 03:16:38', '2025-11-22 04:26:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(211, 'PN25110153', 68, 'Hip pain', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-24', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-24 02:08:42', '2025-11-24 06:11:33', NULL, NULL, 1, '2025-11-22 03:21:28', '2025-11-24 06:11:33', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(212, 'PN25110154', 47, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-26', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-26 06:57:23', '2025-11-26 16:14:45', NULL, NULL, 1, '2025-11-22 08:23:20', '2025-11-26 16:14:45', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(213, 'PN25110155', 84, 'Frozen shoulder from accident', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-24', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-23 11:00:56', 'ca', 1, '2025-11-23 11:00:34', '2025-11-23 11:00:56', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(214, 'PN25110156', 130, 'pain', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-24', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-23 11:32:24', NULL, '2025-11-23 11:32:48', 'ca', 1, '2025-11-23 11:31:31', '2025-11-23 11:32:48', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(215, 'PN25110157', 84, 'Frozen shoulder from accident', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-24', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-23 11:32:38', NULL, '2025-11-23 11:32:59', 'ca', 1, '2025-11-23 11:31:52', '2025-11-23 11:32:59', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(216, 'PN25110158', 130, 'pain', 'ดหก', 'CANCELLED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-23 15:40:44', NULL, '2025-11-24 06:26:10', 'ca', 1, '2025-11-23 12:35:04', '2025-11-24 06:26:10', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, 20, 1),
(217, 'PN25110159', 130, 'pain', 'sdds', 'CANCELLED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-24 06:26:16', 'ca', 1, '2025-11-24 02:34:50', '2025-11-24 06:26:16', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 1),
(218, 'PN25110160', 131, 'Rt. Supraspinatus tendinitis,Bicep tendinitis', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-24', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-24 08:21:21', '2025-11-24 08:24:01', NULL, NULL, 4, '2025-11-24 03:54:40', '2025-11-24 08:24:01', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(219, 'PN25110161', 131, 'Rt. Supraspinatus tendinitis,Bicep tendinitis', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-25', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-25 11:44:30', '2025-11-25 13:35:42', NULL, NULL, 4, '2025-11-24 03:55:41', '2025-11-25 13:35:42', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(220, 'PN25110162', 131, 'Rt. Supraspinatus tendinitis,Bicep tendinitis', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-27', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-27 02:17:53', '2025-11-27 03:16:25', NULL, NULL, 4, '2025-11-24 03:55:57', '2025-11-27 03:16:25', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(221, 'PN25110163', 132, 'external malleolus injury\n', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-24', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-24 04:30:14', 'ca', 4, '2025-11-24 04:29:11', '2025-11-24 04:30:14', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(222, 'PN25110164', 132, 'external malleolus injury\n', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-27', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-24 04:30:09', 'ca', 4, '2025-11-24 04:29:41', '2025-11-24 04:30:09', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(223, 'PN25110165', 132, 'external malleolus injury\n', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-24', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-24 04:31:20', '2025-11-24 08:20:59', NULL, NULL, 4, '2025-11-24 04:31:09', '2025-11-24 08:20:59', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(224, 'PN25110166', 132, 'external malleolus injury\n', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-27', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-27 05:57:01', '2025-11-27 06:37:20', NULL, NULL, 4, '2025-11-24 04:31:46', '2025-11-27 06:37:20', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(225, 'PN25110167', 132, 'external malleolus injury\n', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-29 05:52:01', '2025-11-29 08:26:55', NULL, NULL, 4, '2025-11-24 04:32:32', '2025-11-29 08:26:55', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(226, 'PN25110168', 132, 'external malleolus injury\n', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-04', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-02 03:52:03', '2025-12-02 05:06:05', NULL, NULL, 4, '2025-11-24 04:32:53', '2025-12-02 05:06:05', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(227, 'PN25110169', 132, 'external malleolus injury\n', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-08', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-04 04:18:02', '2025-12-04 06:12:32', NULL, NULL, 4, '2025-11-24 04:33:27', '2025-12-04 06:12:32', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(228, 'PN25110170', 132, 'external malleolus injury\n', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-11', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-06 04:37:01', '2025-12-06 06:18:24', NULL, NULL, 4, '2025-11-24 04:33:40', '2025-12-06 06:18:24', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(229, 'PN25110171', 132, 'external malleolus injury\n', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-15', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-08 03:55:45', '2025-12-08 05:36:48', NULL, NULL, 4, '2025-11-24 04:34:06', '2025-12-08 05:36:48', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(230, 'PN25110172', 132, 'external malleolus injury\n', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-18', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-10 04:19:55', '2025-12-10 05:41:54', NULL, NULL, 4, '2025-11-24 04:34:21', '2025-12-10 05:41:54', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(231, 'PN25110173', 132, 'external malleolus injury\n', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-12 04:25:32', '2025-12-12 05:32:12', NULL, NULL, 4, '2025-11-24 04:34:46', '2025-12-12 05:32:12', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(232, 'PN25110174', 132, 'external malleolus injury\n', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-25', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-15 06:33:21', '2025-12-15 07:53:02', NULL, NULL, 4, '2025-11-24 04:35:04', '2025-12-15 07:53:02', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(233, 'PN25110175', 133, 'Knee Over extension', 'Improve range of motion', 'COMPLETED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-24 15:23:52', '2025-11-25 02:51:31', NULL, NULL, 1, '2025-11-24 10:24:29', '2025-11-25 02:51:31', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(234, 'PN25110176', 134, 'หมอนรองกระดูกทับเส้นประสาท', 'ลดอาการชาและปวดร้าว', 'CANCELLED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-25 02:25:57', NULL, '2025-11-25 02:26:33', 'แฟ', 1, '2025-11-25 02:25:42', '2025-11-25 02:26:33', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(235, 'PN25110177', 134, 'หมอนรองกระดูกทับเส้นประสาท', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-25', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-25 02:27:08', '2025-11-25 06:35:07', NULL, NULL, 1, '2025-11-25 02:27:01', '2025-11-25 06:35:07', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(236, 'PN25110178', 135, 'Ankle pain, Deltoid ligament,Calcaneofibular ligament', 'Pain releife', 'COMPLETED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-25 04:06:28', '2025-11-25 06:37:04', NULL, NULL, 1, '2025-11-25 03:56:49', '2025-11-25 06:37:04', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(237, 'PN25110179', 136, 'Shoulder pain', 'Improve range of motion', 'COMPLETED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-25 06:40:11', '2025-11-25 06:42:27', NULL, NULL, 1, '2025-11-25 05:10:25', '2025-11-25 06:42:27', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(238, 'PN25110180', 133, 'Knee Over extension', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-26', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-26 04:09:13', '2025-11-26 15:52:24', NULL, NULL, 1, '2025-11-25 07:31:12', '2025-11-26 15:52:24', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(239, 'PN25110181', 137, 'Lateral Patellar Retinaculum Left', 'Improve range of motion while walk with decrease pain', 'COMPLETED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-25 09:31:00', '2025-11-25 11:27:00', NULL, NULL, 1, '2025-11-25 09:30:01', '2025-11-25 11:27:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(240, 'PN25110182', 43, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-09', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-09 04:38:39', '2025-12-09 04:42:56', NULL, NULL, 1, '2025-11-25 14:11:12', '2025-12-09 04:42:56', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(241, 'PN25110183', 138, 'Perififomis syndrom', 'Pain relief', 'COMPLETED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-26 02:31:06', '2025-11-26 15:46:22', NULL, NULL, 1, '2025-11-26 02:07:51', '2025-11-26 15:46:22', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(242, 'PN25110184', 78, 'Broken Wrist', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-27', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-27 09:28:59', 'CA', 4, '2025-11-26 07:38:44', '2025-11-27 09:28:59', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(243, 'PN25110185', 72, 'Muay thai class ', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-26', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-26 10:19:27', '2025-11-26 15:58:03', NULL, NULL, 4, '2025-11-26 08:14:30', '2025-11-26 15:58:03', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(244, 'PN25110186', 47, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-28', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-28 07:50:56', '2025-11-28 08:09:15', NULL, NULL, 1, '2025-11-26 10:46:39', '2025-11-28 08:09:15', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(245, 'PN25110187', 47, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-30', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-30 08:39:12', '2025-11-30 14:34:20', NULL, NULL, 1, '2025-11-26 10:48:39', '2025-11-30 14:34:20', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(246, 'PN25110188', 47, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-02', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-02 07:27:43', '2025-12-02 08:58:35', NULL, NULL, 1, '2025-11-26 10:49:11', '2025-12-02 08:58:35', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(247, 'PN25110189', 47, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-04', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-02 08:37:38', 'แฟ', 1, '2025-11-26 10:50:16', '2025-12-02 08:37:38', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(248, 'PN25110190', 47, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-06', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-06 06:14:42', '2025-12-06 07:39:50', NULL, NULL, 1, '2025-11-26 10:50:47', '2025-12-06 07:39:50', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(249, 'PN25110191', 47, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-08', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-08 06:14:25', '2025-12-08 07:54:41', NULL, NULL, 1, '2025-11-26 10:51:09', '2025-12-08 07:54:41', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(250, 'PN25110192', 47, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-10', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-10 06:05:26', '2025-12-10 10:56:04', NULL, NULL, 1, '2025-11-26 10:51:40', '2025-12-10 10:56:04', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(251, 'PN25110193', 47, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-12', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-12 06:17:48', '2025-12-12 08:20:49', NULL, NULL, 1, '2025-11-26 10:52:03', '2025-12-12 08:20:49', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(252, 'PN25110194', 47, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-14', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-14 06:00:42', '2025-12-14 08:52:57', NULL, NULL, 1, '2025-11-26 10:52:24', '2025-12-14 08:52:57', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(253, 'PN25110195', 72, 'Muay thai class ', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-28', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-28 10:44:42', '2025-11-28 11:00:27', NULL, NULL, 1, '2025-11-26 12:29:15', '2025-11-28 11:00:27', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(254, 'PN25110196', 139, 'ITB ', 'Improve range of motion', 'COMPLETED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-26 14:05:05', '2025-11-26 16:01:00', NULL, NULL, 1, '2025-11-26 12:32:47', '2025-11-26 16:01:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(255, 'PN25110197', 140, 'Lower back pain', 'Reduce pain', 'CANCELLED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-27 09:44:03', 'CA', 1, '2025-11-27 09:42:53', '2025-11-27 09:44:03', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(256, 'PN25110198', 140, 'Lower back pain', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-27', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-27 09:49:04', '2025-11-27 11:20:52', NULL, NULL, 1, '2025-11-27 09:48:58', '2025-11-27 11:20:52', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(257, 'PN25110199', 78, 'Broken Wrist', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-28', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-28 04:32:48', '2025-11-28 08:00:15', NULL, NULL, 1, '2025-11-28 02:06:45', '2025-11-28 08:00:15', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(258, 'PN25110200', 79, 'Frozen stuck', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-28', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-28 11:00:31', '2025-11-28 11:44:54', NULL, NULL, 1, '2025-11-28 03:16:24', '2025-11-28 11:44:54', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(259, 'PN25110201', 84, 'Frozen shoulder from accident', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-29', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-28 11:29:03', 'ca', 1, '2025-11-28 11:18:31', '2025-11-28 11:29:03', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(260, 'PN25110202', 142, 'pirifprmis syndrome and LBP', 'Reduce pain', 'COMPLETED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-29 08:17:50', '2025-11-29 08:21:19', NULL, NULL, 1, '2025-11-29 08:16:29', '2025-11-29 08:21:19', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(261, 'PN25110203', 72, 'Muay thai class ', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-11-29', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-29 11:40:06', '2025-11-29 11:41:35', NULL, NULL, 1, '2025-11-29 09:58:33', '2025-11-29 11:41:35', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(262, 'PN25120204', 141, 'PVM', 'Pain reduction ', 'COMPLETED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-01 03:05:19', '2025-12-01 03:28:57', NULL, NULL, 1, '2025-12-01 03:04:54', '2025-12-01 03:28:57', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(263, 'PN25120205', 141, 'PVM', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-08', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-01 04:34:38', 'ca', 1, '2025-12-01 03:48:04', '2025-12-01 04:34:38', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(264, 'PN25120206', 11, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-01 10:27:46', '2025-12-02 02:27:22', NULL, NULL, 1, '2025-12-01 03:56:18', '2025-12-02 02:27:22', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(265, 'PN25120207', 143, 'shoulder - Shoulder Sports Injury - Intensive', 'Pain reduction', 'COMPLETED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-01 04:06:53', '2025-12-01 07:07:05', NULL, NULL, 1, '2025-12-01 04:06:37', '2025-12-01 07:07:05', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(266, 'PN25120208', 141, 'PVM', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-08', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-05 04:46:26', 'Cancelled from appointment', 1, '2025-12-01 04:34:49', '2025-12-05 04:46:26', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(267, 'PN25120209', 144, 'shoulder pain', 'Reduce pain', 'COMPLETED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-01 08:04:49', '2025-12-01 09:27:42', NULL, NULL, 1, '2025-12-01 08:04:04', '2025-12-01 09:27:42', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(268, 'PN25120210', 66, 'Heel', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-02', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-02 02:00:49', '2025-12-02 02:28:34', NULL, NULL, 1, '2025-12-01 09:25:28', '2025-12-02 02:28:34', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(269, 'PN25120211', 11, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-02', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-02 11:02:18', 'CA', 1, '2025-12-01 12:20:25', '2025-12-02 11:02:18', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(270, 'PN25120212', 145, 'BACK PAIN', 'BACK PAIN', 'COMPLETED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-02 02:09:17', '2025-12-02 02:25:06', NULL, NULL, 1, '2025-12-01 12:38:35', '2025-12-02 02:25:06', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(271, 'PN25120213', 146, 'Lower back pain', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-03', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-03 06:05:37', '2025-12-03 06:54:19', NULL, NULL, 1, '2025-12-02 07:27:17', '2025-12-03 06:54:19', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(272, 'PN25120214', 47, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-04', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-04 06:12:35', '2025-12-04 09:14:35', NULL, NULL, 1, '2025-12-02 08:37:59', '2025-12-04 09:14:35', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(273, 'PN25120215', 72, 'Muay thai class ', 'Rehab ater ring', 'COMPLETED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-02 11:58:42', '2025-12-02 14:30:50', NULL, NULL, 4, '2025-12-02 11:57:45', '2025-12-02 14:30:50', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(274, 'PN25120216', 147, 'ankle pain', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-03', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-03 08:13:10', '2025-12-03 09:46:33', NULL, NULL, 4, '2025-12-02 13:32:45', '2025-12-03 09:46:33', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(275, 'PN25120217', 142, 'pirifprmis syndrome and LBP', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-06', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-06 02:11:59', '2025-12-06 06:17:13', NULL, NULL, 1, '2025-12-03 05:40:05', '2025-12-06 06:17:13', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(276, 'PN25120218', 141, 'PVM', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-05', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-05 08:51:21', '2025-12-05 09:25:14', NULL, NULL, 1, '2025-12-03 07:31:27', '2025-12-05 09:25:14', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(277, 'PN25120219', 78, 'Broken Wrist', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-06', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-06 10:00:25', 'CA', 1, '2025-12-04 09:16:42', '2025-12-06 10:00:25', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(278, 'PN25120220', 34, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-05', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-05 02:43:20', 'Cancelled from appointment', 1, '2025-12-05 02:35:26', '2025-12-05 02:43:20', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(279, 'PN25120221', 34, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-05', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-05 10:10:22', '2025-12-05 10:49:53', NULL, NULL, 1, '2025-12-05 02:44:39', '2025-12-05 10:49:53', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(280, 'PN25120222', 150, 'Rt.chondromalacia petella', 'Reduce pain', 'COMPLETED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-05 03:30:14', '2025-12-05 06:45:28', NULL, NULL, 1, '2025-12-05 03:28:12', '2025-12-05 06:45:28', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(281, 'PN25120223', 72, 'Muay thai class ', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-05', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-05 13:57:49', '2025-12-05 15:40:58', NULL, NULL, 1, '2025-12-05 03:38:22', '2025-12-05 15:40:58', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(282, 'PN25120224', 150, 'Rt.chondromalacia petella', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-08', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-08 02:07:09', '2025-12-08 03:55:37', NULL, NULL, 1, '2025-12-05 05:10:08', '2025-12-08 03:55:37', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(283, 'PN25120225', 150, 'Rt.chondromalacia petella', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-10', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-10 03:22:30', '2025-12-10 03:30:53', NULL, NULL, 1, '2025-12-05 05:10:34', '2025-12-10 03:30:53', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(284, 'PN25120226', 150, 'Rt.chondromalacia petella', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-12', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-12 02:02:52', '2025-12-12 03:44:13', NULL, NULL, 1, '2025-12-05 05:11:13', '2025-12-12 03:44:13', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(285, 'PN25120227', 150, 'Rt.chondromalacia petella', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-15', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-15 03:06:12', '2025-12-15 03:55:00', NULL, NULL, 1, '2025-12-05 05:11:37', '2025-12-15 03:55:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(286, 'PN25120228', 150, 'Rt.chondromalacia petella', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-17', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-17 09:39:14', '2025-12-17 10:40:33', NULL, NULL, 1, '2025-12-05 05:11:52', '2025-12-17 10:40:33', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(287, 'PN25120229', 150, 'Rt.chondromalacia petella', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-19', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-19 02:16:33', '2025-12-19 03:00:36', NULL, NULL, 1, '2025-12-05 05:12:10', '2025-12-19 03:00:36', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(288, 'PN25120230', 150, 'Rt.chondromalacia petella', 'Physiotherapy treatment from appointment booking', 'PENDING', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2025-12-05 05:12:34', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0);
INSERT INTO `pn_cases` (`id`, `pn_code`, `patient_id`, `diagnosis`, `purpose`, `status`, `source_clinic_id`, `target_clinic_id`, `referring_doctor`, `assigned_pt_id`, `course_id`, `notes`, `current_medications`, `allergies`, `pn_precautions`, `pn_contraindications`, `treatment_goals`, `expected_outcomes`, `medical_notes`, `vital_signs`, `pain_scale`, `functional_status`, `physio_diagnosis`, `chief_complaint`, `present_history`, `initial_pain_scale`, `assessed_by`, `assessed_at`, `reversal_reason`, `accepted_at`, `completed_at`, `cancelled_at`, `cancellation_reason`, `created_by`, `created_at`, `updated_at`, `pt_diagnosis`, `pt_chief_complaint`, `pt_present_history`, `pt_pain_score`, `is_reversed`, `last_reversal_reason`, `last_reversed_at`, `temp_year`, `temp_month`, `temp_seq`, `body_annotation_id`, `recheck_body_part`) VALUES
(289, 'PN25120231', 150, 'Rt.chondromalacia petella', 'Physiotherapy treatment from appointment booking', 'PENDING', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-24', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2025-12-05 05:12:46', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(290, 'PN25120232', 150, 'Rt.chondromalacia petella', 'Physiotherapy treatment from appointment booking', 'PENDING', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-26', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2025-12-05 05:12:59', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(291, 'PN25120233', 151, 'LBP', 'Reduce pain', 'PENDING', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2025-12-05 06:09:40', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(292, 'PN25120234', 152, 'Rt. Knee and Hip pain', 'Decrease Pain ', 'COMPLETED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-05 06:13:02', '2025-12-05 08:50:59', NULL, NULL, 1, '2025-12-05 06:12:48', '2025-12-05 08:50:59', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(293, 'PN25120235', 147, 'ankle pain', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-06', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-06 10:23:43', '2025-12-06 11:26:00', NULL, NULL, 1, '2025-12-05 06:50:17', '2025-12-06 11:26:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(294, 'PN25120236', 152, 'Rt. Knee and Hip pain', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-12', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-12 08:12:37', '2025-12-12 10:11:07', NULL, NULL, 1, '2025-12-05 07:09:04', '2025-12-12 10:11:07', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(295, 'PN25120237', 147, 'ankle pain', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-05', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-05 08:24:15', 'ca', 1, '2025-12-05 07:10:29', '2025-12-05 08:24:15', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(296, 'PN25120238', 141, 'PVM', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-09', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-09 04:47:38', 'CA', 1, '2025-12-05 09:45:42', '2025-12-09 04:47:38', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(297, 'PN25120239', 151, 'LBP', 'Pain relief', 'COMPLETED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-08 08:27:39', '2025-12-08 11:41:00', NULL, NULL, 1, '2025-12-08 08:27:04', '2025-12-08 11:41:00', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(298, 'PN25120240', 78, 'Broken Wrist', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-10', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-10 10:45:19', '2025-12-10 11:49:41', NULL, NULL, 1, '2025-12-08 08:30:33', '2025-12-10 11:49:41', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(299, 'PN25120241', 153, 'ITB ', 'Pain relief', 'COMPLETED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-08 09:54:02', '2025-12-08 11:45:48', NULL, NULL, 1, '2025-12-08 09:53:28', '2025-12-08 11:45:48', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(300, 'PN25120242', 130, 'pain', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-09', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-10 06:05:08', NULL, '2025-12-12 10:19:35', 'ca', 1, '2025-12-09 05:08:34', '2025-12-12 10:19:35', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(301, 'PN25120243', 9, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-11', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-11 05:50:19', 'ca', 1, '2025-12-10 07:23:11', '2025-12-11 05:50:19', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(302, 'PN25120244', 147, 'ankle pain', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-11', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-11 08:35:50', '2025-12-11 09:49:25', NULL, NULL, 1, '2025-12-10 10:18:44', '2025-12-11 09:49:25', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(303, 'PN25120245', 155, 'carpal pain', 'Pain relief', 'COMPLETED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-11 02:03:27', '2025-12-11 04:09:20', NULL, NULL, 1, '2025-12-11 02:03:09', '2025-12-11 04:09:20', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(304, 'PN25120246', 154, 'Ulnar fx.', 'Pain relief', 'COMPLETED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-11 02:56:34', '2025-12-11 04:10:19', NULL, NULL, 1, '2025-12-11 02:56:01', '2025-12-11 04:10:19', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(305, 'PN25120247', 154, 'Ulnar fx.', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-13', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-13 05:50:37', 'CA', 1, '2025-12-11 04:33:24', '2025-12-13 05:50:37', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(306, 'PN25120248', 154, 'Ulnar fx.', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-15', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-14 05:01:48', 'แฟ', 1, '2025-12-11 04:39:38', '2025-12-14 05:01:48', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(307, 'PN25120249', 156, 'Lower back pain', 'Pain relief', 'COMPLETED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-11 04:43:56', '2025-12-11 08:10:21', NULL, NULL, 1, '2025-12-11 04:43:32', '2025-12-11 08:10:21', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(308, 'PN25120250', 9, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-12', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-11 11:08:48', 'แฟ', 1, '2025-12-11 05:50:43', '2025-12-11 11:08:48', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(309, 'PN25120251', 130, 'pain', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-12', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-11 12:37:42', 'ca', 1, '2025-12-11 12:37:32', '2025-12-11 12:37:42', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(310, 'PN25120252', 130, 'pain', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-12', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-11 12:43:16', 'ca', 1, '2025-12-11 12:38:36', '2025-12-11 12:43:16', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(311, 'PN25120253', 130, 'pain', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-12', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-11 15:30:55', 'ca', 1, '2025-12-11 15:30:36', '2025-12-11 15:30:55', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(312, 'PN25120254', 130, 'pain', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-12', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-11 15:32:16', 'ca', 1, '2025-12-11 15:31:13', '2025-12-11 15:32:16', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(313, 'PN25120255', 130, 'pain', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-12', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-12 02:51:25', 'ca', 1, '2025-12-12 02:24:20', '2025-12-12 02:51:25', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(314, 'PN25120256', 130, 'pain', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-12', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-12 03:35:43', 'ca', 1, '2025-12-12 03:34:13', '2025-12-12 03:35:43', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(315, 'PN25120257', 130, 'pain', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-12', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-12 04:05:34', 'ca', 1, '2025-12-12 03:36:05', '2025-12-12 04:05:34', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(316, 'PN25120258', 157, 'HIP INTESIVE PAIN', 'Hip rehabilitation from pain', 'COMPLETED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-12 08:12:27', '2025-12-12 08:14:30', NULL, NULL, 4, '2025-12-12 07:01:09', '2025-12-12 08:14:30', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(317, 'PN25120259', 158, 'Lower Back Pain', 'Reduce Pain and Improve ROM', 'COMPLETED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-12 10:16:00', '2025-12-12 11:21:18', NULL, NULL, 1, '2025-12-12 10:15:42', '2025-12-12 11:21:18', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(318, 'PN25120260', 155, 'carpal pain', 'Improve performance', 'COMPLETED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-13 02:15:08', '2025-12-13 03:48:26', NULL, NULL, 1, '2025-12-13 02:14:36', '2025-12-13 03:48:26', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(319, 'PN25120261', 130, 'pain', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-13', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-18 06:20:35', NULL, '2025-12-18 06:20:39', 'Cancelled from appointment', 4, '2025-12-13 05:33:30', '2025-12-18 06:20:39', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(320, 'PN25120262', 154, 'Ulnar fx.', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-14', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-14 04:24:56', '2025-12-14 06:14:25', NULL, NULL, 4, '2025-12-13 05:51:15', '2025-12-14 06:14:25', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(321, 'PN25120263', 159, 'Middle Back Pain , Fatigue from votting 13 times, ', 'Pain Relief', 'COMPLETED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-14 02:20:13', '2025-12-14 04:14:51', NULL, NULL, 1, '2025-12-14 02:19:58', '2025-12-14 04:14:51', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(322, 'PN25120264', 154, 'Ulnar fx.', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-17', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-17 03:31:32', 'CA', 1, '2025-12-14 05:19:48', '2025-12-17 03:31:32', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(323, 'PN25120265', 132, 'external malleolus injury\n', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-17', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-17 06:10:40', '2025-12-17 08:40:41', NULL, NULL, 1, '2025-12-15 08:15:01', '2025-12-17 08:40:41', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(324, 'PN25120266', 19, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'CANCELLED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-20', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-16 05:27:02', 'ca', 1, '2025-12-16 05:25:22', '2025-12-16 05:27:02', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(325, 'PN25120267', 19, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'PENDING', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-20', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2025-12-16 05:27:17', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(326, 'PN25120268', 9, 'Pain relief', 'Physiotherapy treatment from appointment booking', 'COMPLETED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-17', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-17 04:58:05', '2025-12-17 06:12:17', NULL, NULL, 1, '2025-12-16 07:56:29', '2025-12-17 06:12:17', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(327, 'PN25120269', 130, 'pain', 'Physiotherapy treatment from appointment booking', 'ACCEPTED', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-16', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-17 09:39:17', NULL, NULL, NULL, 1, '2025-12-16 08:59:08', '2025-12-17 09:39:17', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(328, 'PN25120270', 132, 'external malleolus injury\n', 'Physiotherapy treatment from appointment booking', 'PENDING', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-19', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 4, '2025-12-17 07:19:59', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(329, 'PN25120271', 72, 'Muay thai class ', 'Rehab gor Rt.shoulder and Rt.groin', 'ACCEPTED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-17 11:14:02', NULL, NULL, NULL, 4, '2025-12-17 11:12:58', '2025-12-17 11:14:02', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(330, 'PN25120272', 161, 'Epilepsy', 'Rehab for long term', 'COMPLETED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-18 05:24:03', '2025-12-18 05:26:48', NULL, NULL, 1, '2025-12-18 05:20:02', '2025-12-18 05:26:48', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(331, 'PN25120273', 161, 'Epilepsy', 'Physiotherapy treatment from appointment booking', 'PENDING', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-23', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2025-12-18 05:27:31', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(332, 'PN25120274', 161, 'Epilepsy', 'Physiotherapy treatment from appointment booking', 'PENDING', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-25', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2025-12-18 05:28:08', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(333, 'PN25120275', 69, 'Knee accident', 'Physiotherapy treatment from appointment booking', 'PENDING', 1, 1, NULL, NULL, NULL, 'Auto-created from appointment on 2025-12-20', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2025-12-18 07:55:07', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(334, 'PN25120276', 160, 'LBP', 'Lower back pain', 'COMPLETED', 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-18 08:34:14', '2025-12-18 09:57:01', NULL, NULL, 1, '2025-12-18 08:33:31', '2025-12-18 09:57:01', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0);

-- --------------------------------------------------------

--
-- Table structure for table `pn_cases_backup`
--

CREATE TABLE `pn_cases_backup` (
  `id` int(11) NOT NULL DEFAULT 0,
  `pn_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pn_reports`
--

CREATE TABLE `pn_reports` (
  `id` int(11) NOT NULL,
  `visit_id` int(11) NOT NULL,
  `report_type` enum('INITIAL','PROGRESS','DISCHARGE','SUMMARY') NOT NULL DEFAULT 'PROGRESS',
  `file_path` varchar(500) DEFAULT NULL,
  `file_name` varchar(255) DEFAULT NULL,
  `mime_type` varchar(100) DEFAULT NULL,
  `file_size` int(11) DEFAULT NULL,
  `qr_code` text DEFAULT NULL,
  `report_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`report_data`)),
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pn_soap_notes`
--

CREATE TABLE `pn_soap_notes` (
  `id` int(11) NOT NULL,
  `pn_id` int(11) NOT NULL COMMENT 'Foreign key to pn_cases',
  `subjective` text DEFAULT NULL COMMENT 'Subjective - Patient complaints, symptoms',
  `objective` text DEFAULT NULL COMMENT 'Objective - Observations, measurements',
  `assessment` text DEFAULT NULL COMMENT 'Assessment - Clinical impression, diagnosis',
  `plan` text DEFAULT NULL COMMENT 'Plan - Treatment plan, goals',
  `timestamp` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'When SOAP note was created',
  `notes` text DEFAULT NULL COMMENT 'Additional notes',
  `created_by` int(11) NOT NULL COMMENT 'User who created SOAP note',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='SOAP notes for PN cases';

-- --------------------------------------------------------

--
-- Table structure for table `pn_status_history`
--

CREATE TABLE `pn_status_history` (
  `id` int(11) NOT NULL,
  `pn_id` int(11) NOT NULL,
  `old_status` enum('PENDING','ACCEPTED','IN_PROGRESS','COMPLETED','CANCELLED') NOT NULL,
  `new_status` enum('PENDING','ACCEPTED','IN_PROGRESS','COMPLETED','CANCELLED') NOT NULL,
  `changed_by` int(11) NOT NULL,
  `change_reason` text DEFAULT NULL,
  `is_reversal` tinyint(1) DEFAULT 0 COMMENT 'TRUE if this was a status reversal',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='History of PN case status changes';

-- --------------------------------------------------------

--
-- Table structure for table `pn_visits`
--

CREATE TABLE `pn_visits` (
  `id` int(11) NOT NULL,
  `pn_id` int(11) NOT NULL,
  `visit_no` int(11) NOT NULL,
  `visit_date` date NOT NULL,
  `visit_time` time DEFAULT NULL,
  `status` enum('SCHEDULED','COMPLETED','CANCELLED','NO_SHOW') NOT NULL DEFAULT 'SCHEDULED',
  `chief_complaint` text DEFAULT NULL,
  `subjective` text DEFAULT NULL,
  `objective` text DEFAULT NULL,
  `assessment` text DEFAULT NULL,
  `plan` text DEFAULT NULL,
  `treatment_provided` text DEFAULT NULL,
  `therapist_id` int(11) DEFAULT NULL,
  `duration_minutes` int(11) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pthn_sequence`
--

CREATE TABLE `pthn_sequence` (
  `id` int(11) NOT NULL,
  `year` int(4) NOT NULL COMMENT 'Year in YY format (e.g., 25 for 2025)',
  `last_sequence` int(4) NOT NULL DEFAULT 0 COMMENT 'Last used sequence number (0001-9999)',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tracks PTHN sequence numbers per year for auto-generation';

-- --------------------------------------------------------

--
-- Table structure for table `pt_certificates`
--

CREATE TABLE `pt_certificates` (
  `id` int(11) NOT NULL,
  `pn_id` int(11) NOT NULL,
  `certificate_type` enum('thai','english') NOT NULL DEFAULT 'thai',
  `certificate_data` text NOT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `public_booking_settings`
--

CREATE TABLE `public_booking_settings` (
  `id` int(11) NOT NULL,
  `clinic_id` int(11) NOT NULL,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text DEFAULT NULL,
  `setting_type` enum('TEXT','JSON','BOOLEAN','NUMBER') NOT NULL DEFAULT 'TEXT',
  `updated_by` int(11) NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `public_promotions`
--

CREATE TABLE `public_promotions` (
  `id` int(11) NOT NULL,
  `promo_code` varchar(50) NOT NULL,
  `description` varchar(500) DEFAULT NULL,
  `discount_type` enum('PERCENTAGE','FIXED_AMOUNT') NOT NULL DEFAULT 'PERCENTAGE',
  `discount_value` decimal(10,2) NOT NULL,
  `min_purchase` decimal(10,2) DEFAULT NULL,
  `max_discount` decimal(10,2) DEFAULT NULL,
  `valid_from` date NOT NULL,
  `valid_until` date NOT NULL,
  `usage_limit` int(11) DEFAULT NULL COMMENT 'Total usage limit',
  `usage_count` int(11) DEFAULT 0,
  `active` tinyint(1) DEFAULT 1,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `public_service_packages`
--

CREATE TABLE `public_service_packages` (
  `id` int(11) NOT NULL,
  `service_id` int(11) DEFAULT NULL COMMENT 'Link to services table, NULL for custom packages',
  `package_name` varchar(200) NOT NULL,
  `package_code` varchar(50) NOT NULL,
  `description` text DEFAULT NULL,
  `price` decimal(10,2) NOT NULL,
  `duration_minutes` int(11) NOT NULL DEFAULT 60,
  `benefits` text DEFAULT NULL COMMENT 'JSON array of benefits',
  `pain_zones` varchar(500) DEFAULT NULL COMMENT 'Comma-separated pain zones this helps',
  `is_featured` tinyint(1) DEFAULT 0 COMMENT 'Show as "Most Popular"',
  `is_best_value` tinyint(1) DEFAULT 0 COMMENT 'Show as "Best Value"',
  `image_url` varchar(500) DEFAULT NULL,
  `display_order` int(11) DEFAULT 0,
  `active` tinyint(1) DEFAULT 1,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `public_testimonials`
--

CREATE TABLE `public_testimonials` (
  `id` int(11) NOT NULL,
  `patient_name` varchar(200) NOT NULL,
  `service_package_id` int(11) DEFAULT NULL,
  `rating` int(1) NOT NULL DEFAULT 5 COMMENT '1-5 stars',
  `testimonial_text` text NOT NULL,
  `display_on_public` tinyint(1) DEFAULT 1,
  `display_order` int(11) DEFAULT 0,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `services`
--

CREATE TABLE `services` (
  `id` int(11) NOT NULL,
  `service_code` varchar(50) NOT NULL,
  `service_name` varchar(200) NOT NULL,
  `service_description` text DEFAULT NULL,
  `default_price` decimal(10,2) NOT NULL,
  `service_type` varchar(100) DEFAULT 'PHYSIOTHERAPY',
  `active` tinyint(1) DEFAULT 1 COMMENT 'Global service active status',
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `session_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `expires` int(11) UNSIGNED NOT NULL,
  `data` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `system_settings`
--

CREATE TABLE `system_settings` (
  `id` int(11) NOT NULL,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text DEFAULT NULL,
  `settings` text DEFAULT NULL COMMENT 'For JSON settings storage',
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `updated_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='System-wide settings including document customization';

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` enum('ADMIN','CLINIC','PT','HOME_STAFF') DEFAULT NULL,
  `clinic_id` int(11) DEFAULT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `license_number` varchar(50) DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `active` tinyint(1) DEFAULT 1,
  `last_login` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp(),
  `totp_secret` varchar(255) DEFAULT NULL COMMENT 'Secret key for TOTP generation',
  `totp_enabled` tinyint(1) DEFAULT 0 COMMENT 'Whether 2FA is enabled for this user',
  `totp_backup_codes` text DEFAULT NULL COMMENT 'JSON array of backup codes',
  `totp_enabled_at` timestamp NULL DEFAULT NULL COMMENT 'When 2FA was enabled',
  `last_totp_verified_at` timestamp NULL DEFAULT NULL COMMENT 'Last successful TOTP verification',
  `google_id` varchar(255) DEFAULT NULL COMMENT 'Google account ID',
  `google_email` varchar(255) DEFAULT NULL COMMENT 'Email from Google account',
  `google_name` varchar(255) DEFAULT NULL COMMENT 'Name from Google account',
  `google_picture` text DEFAULT NULL COMMENT 'Profile picture URL from Google',
  `google_connected_at` timestamp NULL DEFAULT NULL COMMENT 'When Google account was connected'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `email`, `password_hash`, `role`, `clinic_id`, `first_name`, `last_name`, `license_number`, `phone`, `active`, `last_login`, `created_at`, `updated_at`, `totp_secret`, `totp_enabled`, `totp_backup_codes`, `totp_enabled_at`, `last_totp_verified_at`, `google_id`, `google_email`, `google_name`, `google_picture`, `google_connected_at`) VALUES
(1, 'info@lantavafix.com', '$2b$10$5PrsaRZgVJGaZJBzu45bDezFWIH/1hy2nOnwn2ny0CSNtNNZbFbq2', 'ADMIN', 1, 'SUTTIDA ', 'CHOOLUAN ', '', '', 1, '2025-12-19 02:51:37', '2025-10-30 13:06:38', '2025-12-19 02:51:37', 'GBWFQ22CG5KCINCEM4QXANDLGIRT6VJVIZTTSLCVIUSHO625PE2A', 1, '[\"09cc4653e47a0661b816c79f5ce6b1cf50687313ccacdf4dbada621c69b859bd\",\"e9aed97ebb1d616c2c35ac0bbe5cf2907276ab2b4e6e48b7e39210eb30e01768\",\"6974921d49853e4951e7430572feef7d9884ca752eec25bc37a3ea65c37ab41a\",\"e127d346593c55f785a9991aeda3ec1159a2e63f7103a1db80afa1a6969488f9\",\"ad14741bdeafe45ee99625572b82f095162136f7fd25a2bd279ce50e1f26112f\",\"d99c13c14978dc1316386f85c56d486334a6452a78afa700cd77e2643556b925\",\"65d206c63b592b3029899339a2a309378ba0a87ac44c11a7a2862bf81659a219\",\"bda5dd0767720883f3d5fa42931586ea3d63fef3bc82a071806e25e9f367cdfd\",\"90a86cf7c3c47853e3ef522995f5a6a3050df0ff36a53f0f3a6ecd515d4fe48a\",\"2dedd756e2367e8373632e08dd28ac15844a8736222551979b808e4e4ff60410\"]', '2025-12-12 09:48:21', '2025-12-13 04:35:13', '117416237809084875950', 'info@lantavafix.com', 'Lantavafix clinic', 'https://lh3.googleusercontent.com/a/ACg8ocJ3d2OaUib9BNBmWtd7LBQt1zInLUEloaVNy8aS_zJAawfdHLI=s96-c', '2025-12-13 05:22:18'),
(2, 'clinic1@pn-app.com', '$2b$10$YourHashedPasswordHere', 'CLINIC', 1, 'Clinic', 'Manager 1', NULL, '099-111-1111', 1, NULL, '2025-10-30 13:06:38', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(3, 'clinic2@pn-app.com', '$2b$10$ZrCsju4DE/2srmEwjnwHPOjylmTjm3osySJRM7Tj0lULc1BKd2Xvq', 'CLINIC', 2, 'Clinic', 'Manager 2', '', '099-222-2222', 1, '2025-11-14 07:41:05', '2025-10-30 13:06:38', '2025-11-14 07:41:05', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(4, 'suttida.cho@gmail.com', '$2b$10$UpHWK2vwojl34p7spGgnDORbgolORusHl1FFihLlhyt.U7TkRFZWC', 'PT', 1, 'Suttida', 'Chooluan', '', '', 1, '2025-12-17 06:54:39', '2025-10-30 13:06:38', '2025-12-17 06:54:39', 'MJNUSWSPIM5EMMTLGIXUYVC5NNLDI42DOMXEA4THERHEEWZXFRIQ', 1, '[\"2d6d60d81d57994e2351dba9173a69e5c4703f0b5d7c0ce34fcc4cf9358b31ed\",\"49a16cf71343ca31ac22afc12222cb068cbb8e9f26aa6b9fd09aba3af9698df5\",\"7065b35db11cd9ed059314064cef8a9adaf0daf663e3dab4a1f147d5a7b9de27\",\"c3ab543922463f70051c18baf63e8777fef770d20a076de6d7f31d729c0cf864\",\"21428b018b4518a0cfb612280ba560e837a837056e3e937bef6942c469b63904\",\"d99454ee3f9ee573282c4c07101398dd94f5776007c6fa7534c1d18ee619029c\",\"924b5a4c7c59e13e3b87927583af0b897b16a046bee219c32a8aba94ca872b5a\",\"27c075925d3ef673e649d75d796e96cb107c07545d2d0283dd7f93f3c1c5839d\",\"389faec58124212b5a24fc18aa068ac2b79d32b085575af828b16800e745c4fc\",\"4dd293ee146dcbaf0a178e3d57bb28b5b70cf76b519906605a8fe997924abbe6\"]', '2025-12-12 09:51:01', '2025-12-13 05:50:27', '116035416207344301429', 'suttida.cho@gmail.com', 'suttida', 'https://lh3.googleusercontent.com/a/ACg8ocJF0Ri_vWEtQKce00zNMer-UYGUWxhws46VVn0OSToIenD455ix=s96-c', '2025-12-13 04:53:12'),
(5, 'pt2@pn-app.com', '$2b$10$Vg5UV2HuJdMCFDliHDwoxOIxY8W5CIYnKT0tGjY5c/D9LNi22XpMO', 'PT', 1, 'Jane', 'Senior PT', 'PT54321', '099-444-4444', 1, '2025-11-08 03:41:08', '2025-10-30 13:06:38', '2025-11-08 03:41:08', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(6, 'natthanai2341@gmail.com', '$2b$10$is0QY0J/Q7MUMqAPzXIUCONJV5aZIVaz0Ba2En6YVrMZYoPElUdOK', 'CLINIC', 3, 'John', 'Doe', '', '', 1, '2025-11-08 03:50:54', '2025-10-31 07:52:02', '2025-11-08 03:50:54', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `user_clinic_grants`
--

CREATE TABLE `user_clinic_grants` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `clinic_id` int(11) NOT NULL,
  `granted_by` int(11) NOT NULL,
  `granted_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_clinic_grants`
--

INSERT INTO `user_clinic_grants` (`id`, `user_id`, `clinic_id`, `granted_by`, `granted_at`) VALUES
(1, 4, 2, 1, '2025-10-30 13:06:38'),
(2, 4, 3, 1, '2025-10-30 13:06:38'),
(3, 5, 2, 1, '2025-10-30 13:06:38'),
(4, 4, 1, 1, '2025-11-08 02:49:42');

-- --------------------------------------------------------

--
-- Table structure for table `visit_checkins`
--

CREATE TABLE `visit_checkins` (
  `id` int(11) NOT NULL,
  `appointment_id` int(11) DEFAULT NULL COMMENT 'รหัสนัดหมาย (ถ้ามี)',
  `staff_id` int(11) NOT NULL COMMENT 'รหัสพนักงานที่ไปเยี่ยม',
  `latitude` decimal(10,8) NOT NULL,
  `longitude` decimal(11,8) NOT NULL,
  `photo_url` varchar(500) NOT NULL COMMENT 'URL รูปจาก Firebase',
  `check_in_time` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `appointments`
--
ALTER TABLE `appointments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_appointment_patient` (`patient_id`),
  ADD KEY `idx_appointment_clinic` (`clinic_id`),
  ADD KEY `idx_appointment_pt` (`pt_id`),
  ADD KEY `idx_appointment_date` (`appointment_date`),
  ADD KEY `idx_appointment_status` (`status`),
  ADD KEY `idx_appointment_pn` (`pn_case_id`),
  ADD KEY `idx_appointment_course` (`course_id`),
  ADD KEY `cancelled_by` (`cancelled_by`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_appointment_datetime` (`appointment_date`,`start_time`),
  ADD KEY `idx_appointment_pn_id` (`pn_id`),
  ADD KEY `idx_appointments_client_ip` (`client_ip_address`),
  ADD KEY `idx_calendar_event_id` (`calendar_event_id`),
  ADD KEY `idx_appointments_body_annotation` (`body_annotation_id`);

--
-- Indexes for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_audit_user` (`user_id`),
  ADD KEY `idx_audit_entity` (`entity_type`,`entity_id`),
  ADD KEY `idx_audit_action` (`action`),
  ADD KEY `idx_audit_created` (`created_at`);

--
-- Indexes for table `bills`
--
ALTER TABLE `bills`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `bill_code` (`bill_code`),
  ADD KEY `idx_bill_patient` (`patient_id`),
  ADD KEY `idx_bill_clinic` (`clinic_id`),
  ADD KEY `idx_bill_date` (`bill_date`),
  ADD KEY `idx_bill_status` (`payment_status`),
  ADD KEY `idx_bill_appointment` (`appointment_id`),
  ADD KEY `idx_bill_course` (`course_id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_bills_pn_case_id` (`pn_case_id`),
  ADD KEY `idx_payment_date` (`payment_date`,`payment_status`);

--
-- Indexes for table `bill_items`
--
ALTER TABLE `bill_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_bill_item_bill` (`bill_id`),
  ADD KEY `idx_bill_item_service` (`service_id`);

--
-- Indexes for table `bodychecks`
--
ALTER TABLE `bodychecks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_bodycheck_pn` (`pn_id`),
  ADD KEY `idx_bodycheck_patient` (`patient_id`),
  ADD KEY `idx_bodycheck_created_by` (`created_by`),
  ADD KEY `idx_bodycheck_status` (`status`),
  ADD KEY `idx_bodycheck_created_at` (`created_at`);

--
-- Indexes for table `bodycheck_regions`
--
ALTER TABLE `bodycheck_regions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_region_bodycheck` (`bodycheck_id`),
  ADD KEY `idx_region_name` (`region_name`);

--
-- Indexes for table `body_annotations`
--
ALTER TABLE `body_annotations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_entity` (`entity_type`,`entity_id`) COMMENT 'Quick lookup by entity',
  ADD KEY `idx_created_by` (`created_by`) COMMENT 'Quick lookup by creator',
  ADD KEY `idx_created_at` (`created_at`) COMMENT 'Quick lookup by date';

--
-- Indexes for table `body_annotation_metadata`
--
ALTER TABLE `body_annotation_metadata`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_annotation_id` (`annotation_id`);

--
-- Indexes for table `broadcast_campaigns`
--
ALTER TABLE `broadcast_campaigns`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_scheduled_time` (`scheduled_time`),
  ADD KEY `idx_created_by` (`created_by`);

--
-- Indexes for table `broadcast_logs`
--
ALTER TABLE `broadcast_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_campaign_status` (`campaign_id`,`status`),
  ADD KEY `idx_recipient` (`recipient`);

--
-- Indexes for table `certificate_settings`
--
ALTER TABLE `certificate_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_clinic` (`clinic_id`);

--
-- Indexes for table `chat_conversations`
--
ALTER TABLE `chat_conversations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_conversation` (`user1_id`,`user2_id`),
  ADD KEY `idx_user1` (`user1_id`),
  ADD KEY `idx_user2` (`user2_id`),
  ADD KEY `idx_last_message` (`last_message_at`),
  ADD KEY `idx_users_last_message` (`user1_id`,`user2_id`,`last_message_at`);

--
-- Indexes for table `chat_messages`
--
ALTER TABLE `chat_messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_conversation` (`conversation_id`),
  ADD KEY `idx_sender` (`sender_id`),
  ADD KEY `idx_recipient` (`recipient_id`),
  ADD KEY `idx_created_at` (`created_at`),
  ADD KEY `idx_unread` (`recipient_id`,`read_at`),
  ADD KEY `idx_conversation_created` (`conversation_id`,`created_at`);

--
-- Indexes for table `clinics`
--
ALTER TABLE `clinics`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`),
  ADD KEY `idx_clinic_active` (`active`),
  ADD KEY `idx_clinic_code` (`code`);

--
-- Indexes for table `clinic_service_pricing`
--
ALTER TABLE `clinic_service_pricing`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_clinic_service` (`clinic_id`,`service_id`),
  ADD KEY `idx_clinic_service` (`clinic_id`),
  ADD KEY `idx_service_clinic` (`service_id`),
  ADD KEY `updated_by` (`updated_by`);

--
-- Indexes for table `courses`
--
ALTER TABLE `courses`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `course_code` (`course_code`),
  ADD KEY `idx_course_patient` (`patient_id`),
  ADD KEY `idx_course_clinic` (`clinic_id`),
  ADD KEY `idx_course_status` (`status`),
  ADD KEY `idx_course_code` (`course_code`),
  ADD KEY `fk_course_creator` (`created_by`);

--
-- Indexes for table `course_shared_users`
--
ALTER TABLE `course_shared_users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_course_patient` (`course_id`,`patient_id`),
  ADD KEY `idx_course_id` (`course_id`),
  ADD KEY `idx_patient_id` (`patient_id`),
  ADD KEY `idx_shared_by` (`shared_by`),
  ADD KEY `idx_course_active` (`course_id`,`is_active`),
  ADD KEY `idx_patient_active` (`patient_id`,`is_active`);

--
-- Indexes for table `course_templates`
--
ALTER TABLE `course_templates`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_template_active` (`active`),
  ADD KEY `fk_template_creator` (`created_by`);

--
-- Indexes for table `course_usage_history`
--
ALTER TABLE `course_usage_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_usage_course` (`course_id`),
  ADD KEY `idx_usage_pn` (`pn_id`),
  ADD KEY `idx_usage_date` (`usage_date`),
  ADD KEY `fk_usage_creator` (`created_by`);

--
-- Indexes for table `expenses`
--
ALTER TABLE `expenses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_category` (`category_id`),
  ADD KEY `idx_expense_date` (`expense_date`),
  ADD KEY `idx_created_by` (`created_by`),
  ADD KEY `idx_expense_date_range` (`expense_date`,`amount`);

--
-- Indexes for table `expense_categories`
--
ALTER TABLE `expense_categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_category_name` (`name`);

--
-- Indexes for table `gift_cards`
--
ALTER TABLE `gift_cards`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `gift_card_code` (`gift_card_code`),
  ADD KEY `member_id` (`member_id`),
  ADD KEY `redeemed_by_user` (`redeemed_by_user`),
  ADD KEY `bill_id_used` (`bill_id_used`),
  ADD KEY `idx_code` (`gift_card_code`),
  ADD KEY `idx_status` (`status`);

--
-- Indexes for table `gift_card_catalog`
--
ALTER TABLE `gift_card_catalog`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `invoices`
--
ALTER TABLE `invoices`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_invoice_number` (`invoice_number`),
  ADD KEY `idx_payment_status` (`payment_status`),
  ADD KEY `idx_invoice_date` (`invoice_date`),
  ADD KEY `idx_clinic` (`clinic_id`),
  ADD KEY `idx_created_by` (`created_by`),
  ADD KEY `idx_invoice_payment_status_date` (`payment_status`,`invoice_date`),
  ADD KEY `idx_invoice_total_amount` (`total_amount`,`payment_status`);

--
-- Indexes for table `invoice_items`
--
ALTER TABLE `invoice_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_invoice` (`invoice_id`),
  ADD KEY `idx_service` (`service_id`);

--
-- Indexes for table `loyalty_members`
--
ALTER TABLE `loyalty_members`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `patient_id` (`patient_id`);

--
-- Indexes for table `loyalty_tier_rules`
--
ALTER TABLE `loyalty_tier_rules`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `tier` (`tier`);

--
-- Indexes for table `loyalty_transactions`
--
ALTER TABLE `loyalty_transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `bill_id` (`bill_id`),
  ADD KEY `performed_by` (`performed_by`),
  ADD KEY `idx_member_date` (`member_id`,`transaction_date`);

--
-- Indexes for table `notification_settings`
--
ALTER TABLE `notification_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_setting_type` (`setting_type`),
  ADD KEY `idx_setting_type` (`setting_type`);

--
-- Indexes for table `patients`
--
ALTER TABLE `patients`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `pt_number` (`pt_number`),
  ADD UNIQUE KEY `unique_hn` (`hn`),
  ADD UNIQUE KEY `unique_pid` (`pid`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_patient_hn` (`hn`),
  ADD KEY `idx_patient_pt_number` (`pt_number`),
  ADD KEY `idx_patient_name` (`first_name`,`last_name`),
  ADD KEY `idx_patient_clinic` (`clinic_id`),
  ADD KEY `idx_patient_passport` (`passport_no`);

--
-- Indexes for table `pn_attachments`
--
ALTER TABLE `pn_attachments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_attachment_pn` (`pn_id`),
  ADD KEY `uploaded_by` (`uploaded_by`);

--
-- Indexes for table `pn_cases`
--
ALTER TABLE `pn_cases`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `pn_code` (`pn_code`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_pn_code` (`pn_code`),
  ADD KEY `idx_pn_patient` (`patient_id`),
  ADD KEY `idx_pn_status` (`status`),
  ADD KEY `idx_pn_source_clinic` (`source_clinic_id`),
  ADD KEY `idx_pn_target_clinic` (`target_clinic_id`),
  ADD KEY `idx_pn_created_at` (`created_at`),
  ADD KEY `idx_pn_assigned_pt` (`assigned_pt_id`),
  ADD KEY `idx_pn_assessed_by` (`assessed_by`),
  ADD KEY `idx_pn_assessed_at` (`assessed_at`),
  ADD KEY `idx_pn_course` (`course_id`),
  ADD KEY `idx_pn_cases_body_annotation` (`body_annotation_id`),
  ADD KEY `idx_pn_cases_recheck` (`recheck_body_part`);

--
-- Indexes for table `pn_reports`
--
ALTER TABLE `pn_reports`
  ADD PRIMARY KEY (`id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_report_visit` (`visit_id`),
  ADD KEY `idx_report_type` (`report_type`),
  ADD KEY `idx_report_created_at` (`created_at`);

--
-- Indexes for table `pn_soap_notes`
--
ALTER TABLE `pn_soap_notes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_soap_pn` (`pn_id`),
  ADD KEY `idx_soap_timestamp` (`timestamp`),
  ADD KEY `created_by` (`created_by`);

--
-- Indexes for table `pn_status_history`
--
ALTER TABLE `pn_status_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_status_history_pn` (`pn_id`),
  ADD KEY `changed_by` (`changed_by`);

--
-- Indexes for table `pn_visits`
--
ALTER TABLE `pn_visits`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_pn_visit_no` (`pn_id`,`visit_no`),
  ADD KEY `therapist_id` (`therapist_id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_visit_pn` (`pn_id`),
  ADD KEY `idx_visit_date` (`visit_date`),
  ADD KEY `idx_visit_status` (`status`);

--
-- Indexes for table `pthn_sequence`
--
ALTER TABLE `pthn_sequence`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_year` (`year`);

--
-- Indexes for table `pt_certificates`
--
ALTER TABLE `pt_certificates`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_pn_id` (`pn_id`),
  ADD KEY `idx_created_by` (`created_by`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- Indexes for table `public_booking_settings`
--
ALTER TABLE `public_booking_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `clinic_setting` (`clinic_id`,`setting_key`),
  ADD KEY `fk_booking_settings_updater` (`updated_by`);

--
-- Indexes for table `public_promotions`
--
ALTER TABLE `public_promotions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `promo_code` (`promo_code`),
  ADD KEY `active` (`active`),
  ADD KEY `fk_promotion_creator` (`created_by`);

--
-- Indexes for table `public_service_packages`
--
ALTER TABLE `public_service_packages`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `package_code` (`package_code`),
  ADD KEY `service_id` (`service_id`),
  ADD KEY `active` (`active`),
  ADD KEY `fk_public_package_creator` (`created_by`);

--
-- Indexes for table `public_testimonials`
--
ALTER TABLE `public_testimonials`
  ADD PRIMARY KEY (`id`),
  ADD KEY `service_package_id` (`service_package_id`),
  ADD KEY `display_on_public` (`display_on_public`),
  ADD KEY `fk_testimonial_creator` (`created_by`);

--
-- Indexes for table `services`
--
ALTER TABLE `services`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `service_code` (`service_code`),
  ADD KEY `idx_service_type` (`service_type`),
  ADD KEY `idx_service_active` (`active`),
  ADD KEY `created_by` (`created_by`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`session_id`);

--
-- Indexes for table `system_settings`
--
ALTER TABLE `system_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_setting_key` (`setting_key`),
  ADD KEY `idx_updated_by` (`updated_by`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `idx_google_id` (`google_id`),
  ADD KEY `idx_user_email` (`email`),
  ADD KEY `idx_user_role` (`role`),
  ADD KEY `idx_user_clinic` (`clinic_id`),
  ADD KEY `idx_totp_enabled` (`totp_enabled`),
  ADD KEY `idx_google_email` (`google_email`);

--
-- Indexes for table `user_clinic_grants`
--
ALTER TABLE `user_clinic_grants`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_user_clinic` (`user_id`,`clinic_id`),
  ADD KEY `granted_by` (`granted_by`),
  ADD KEY `idx_grant_user` (`user_id`),
  ADD KEY `idx_grant_clinic` (`clinic_id`);

--
-- Indexes for table `visit_checkins`
--
ALTER TABLE `visit_checkins`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_staff` (`staff_id`),
  ADD KEY `idx_time` (`check_in_time`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `appointments`
--
ALTER TABLE `appointments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `audit_logs`
--
ALTER TABLE `audit_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `bills`
--
ALTER TABLE `bills`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `bill_items`
--
ALTER TABLE `bill_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `bodychecks`
--
ALTER TABLE `bodychecks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `bodycheck_regions`
--
ALTER TABLE `bodycheck_regions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `body_annotations`
--
ALTER TABLE `body_annotations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `body_annotation_metadata`
--
ALTER TABLE `body_annotation_metadata`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `broadcast_campaigns`
--
ALTER TABLE `broadcast_campaigns`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `broadcast_logs`
--
ALTER TABLE `broadcast_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `certificate_settings`
--
ALTER TABLE `certificate_settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `chat_conversations`
--
ALTER TABLE `chat_conversations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `chat_messages`
--
ALTER TABLE `chat_messages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `clinics`
--
ALTER TABLE `clinics`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `clinic_service_pricing`
--
ALTER TABLE `clinic_service_pricing`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `courses`
--
ALTER TABLE `courses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `course_shared_users`
--
ALTER TABLE `course_shared_users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `course_templates`
--
ALTER TABLE `course_templates`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `course_usage_history`
--
ALTER TABLE `course_usage_history`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `expenses`
--
ALTER TABLE `expenses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `expense_categories`
--
ALTER TABLE `expense_categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `gift_cards`
--
ALTER TABLE `gift_cards`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `gift_card_catalog`
--
ALTER TABLE `gift_card_catalog`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `invoices`
--
ALTER TABLE `invoices`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `invoice_items`
--
ALTER TABLE `invoice_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `loyalty_members`
--
ALTER TABLE `loyalty_members`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `loyalty_tier_rules`
--
ALTER TABLE `loyalty_tier_rules`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `loyalty_transactions`
--
ALTER TABLE `loyalty_transactions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `notification_settings`
--
ALTER TABLE `notification_settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `patients`
--
ALTER TABLE `patients`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=162;

--
-- AUTO_INCREMENT for table `pn_attachments`
--
ALTER TABLE `pn_attachments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pn_cases`
--
ALTER TABLE `pn_cases`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=335;

--
-- AUTO_INCREMENT for table `pn_reports`
--
ALTER TABLE `pn_reports`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pn_soap_notes`
--
ALTER TABLE `pn_soap_notes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pn_status_history`
--
ALTER TABLE `pn_status_history`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pn_visits`
--
ALTER TABLE `pn_visits`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pthn_sequence`
--
ALTER TABLE `pthn_sequence`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pt_certificates`
--
ALTER TABLE `pt_certificates`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `public_booking_settings`
--
ALTER TABLE `public_booking_settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `public_promotions`
--
ALTER TABLE `public_promotions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `public_service_packages`
--
ALTER TABLE `public_service_packages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `public_testimonials`
--
ALTER TABLE `public_testimonials`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `services`
--
ALTER TABLE `services`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `system_settings`
--
ALTER TABLE `system_settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `user_clinic_grants`
--
ALTER TABLE `user_clinic_grants`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `visit_checkins`
--
ALTER TABLE `visit_checkins`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `appointments`
--
ALTER TABLE `appointments`
  ADD CONSTRAINT `appointments_ibfk_1` FOREIGN KEY (`body_annotation_id`) REFERENCES `body_annotations` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_appointment_canceller` FOREIGN KEY (`cancelled_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_appointment_clinic` FOREIGN KEY (`clinic_id`) REFERENCES `clinics` (`id`),
  ADD CONSTRAINT `fk_appointment_course` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_appointment_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_appointment_patient` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_appointment_pn` FOREIGN KEY (`pn_case_id`) REFERENCES `pn_cases` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_appointment_pt` FOREIGN KEY (`pt_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `bills`
--
ALTER TABLE `bills`
  ADD CONSTRAINT `fk_bill_appointment` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_bill_clinic` FOREIGN KEY (`clinic_id`) REFERENCES `clinics` (`id`),
  ADD CONSTRAINT `fk_bill_course` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_bill_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_bill_patient` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_bills_pn_case` FOREIGN KEY (`pn_case_id`) REFERENCES `pn_cases` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `bill_items`
--
ALTER TABLE `bill_items`
  ADD CONSTRAINT `fk_bill_item_bill` FOREIGN KEY (`bill_id`) REFERENCES `bills` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_bill_item_service` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `bodychecks`
--
ALTER TABLE `bodychecks`
  ADD CONSTRAINT `fk_bodycheck_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_bodycheck_patient` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_bodycheck_pn` FOREIGN KEY (`pn_id`) REFERENCES `pn_cases` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `bodycheck_regions`
--
ALTER TABLE `bodycheck_regions`
  ADD CONSTRAINT `fk_region_bodycheck` FOREIGN KEY (`bodycheck_id`) REFERENCES `bodychecks` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `body_annotations`
--
ALTER TABLE `body_annotations`
  ADD CONSTRAINT `body_annotations_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `body_annotation_metadata`
--
ALTER TABLE `body_annotation_metadata`
  ADD CONSTRAINT `body_annotation_metadata_ibfk_1` FOREIGN KEY (`annotation_id`) REFERENCES `body_annotations` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `broadcast_campaigns`
--
ALTER TABLE `broadcast_campaigns`
  ADD CONSTRAINT `broadcast_campaigns_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `broadcast_logs`
--
ALTER TABLE `broadcast_logs`
  ADD CONSTRAINT `broadcast_logs_ibfk_1` FOREIGN KEY (`campaign_id`) REFERENCES `broadcast_campaigns` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `certificate_settings`
--
ALTER TABLE `certificate_settings`
  ADD CONSTRAINT `certificate_settings_ibfk_1` FOREIGN KEY (`clinic_id`) REFERENCES `clinics` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `chat_conversations`
--
ALTER TABLE `chat_conversations`
  ADD CONSTRAINT `chat_conversations_ibfk_1` FOREIGN KEY (`user1_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `chat_conversations_ibfk_2` FOREIGN KEY (`user2_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `chat_messages`
--
ALTER TABLE `chat_messages`
  ADD CONSTRAINT `chat_messages_ibfk_1` FOREIGN KEY (`conversation_id`) REFERENCES `chat_conversations` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `chat_messages_ibfk_2` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `chat_messages_ibfk_3` FOREIGN KEY (`recipient_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `clinic_service_pricing`
--
ALTER TABLE `clinic_service_pricing`
  ADD CONSTRAINT `fk_clinic_pricing_clinic` FOREIGN KEY (`clinic_id`) REFERENCES `clinics` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_clinic_pricing_service` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_clinic_pricing_updater` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `courses`
--
ALTER TABLE `courses`
  ADD CONSTRAINT `fk_course_clinic` FOREIGN KEY (`clinic_id`) REFERENCES `clinics` (`id`),
  ADD CONSTRAINT `fk_course_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_course_patient` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `course_shared_users`
--
ALTER TABLE `course_shared_users`
  ADD CONSTRAINT `fk_course_shared_by` FOREIGN KEY (`shared_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_course_shared_course` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_course_shared_patient` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `course_templates`
--
ALTER TABLE `course_templates`
  ADD CONSTRAINT `fk_template_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `course_usage_history`
--
ALTER TABLE `course_usage_history`
  ADD CONSTRAINT `fk_usage_course` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_usage_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_usage_pn` FOREIGN KEY (`pn_id`) REFERENCES `pn_cases` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `expenses`
--
ALTER TABLE `expenses`
  ADD CONSTRAINT `fk_expense_category` FOREIGN KEY (`category_id`) REFERENCES `expense_categories` (`id`),
  ADD CONSTRAINT `fk_expense_user` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `gift_cards`
--
ALTER TABLE `gift_cards`
  ADD CONSTRAINT `gift_cards_ibfk_1` FOREIGN KEY (`member_id`) REFERENCES `loyalty_members` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `gift_cards_ibfk_2` FOREIGN KEY (`redeemed_by_user`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `gift_cards_ibfk_3` FOREIGN KEY (`bill_id_used`) REFERENCES `bills` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `invoices`
--
ALTER TABLE `invoices`
  ADD CONSTRAINT `fk_invoice_clinic` FOREIGN KEY (`clinic_id`) REFERENCES `clinics` (`id`),
  ADD CONSTRAINT `fk_invoice_user` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `invoice_items`
--
ALTER TABLE `invoice_items`
  ADD CONSTRAINT `fk_invoice_item_invoice` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_invoice_item_service` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`);

--
-- Constraints for table `loyalty_members`
--
ALTER TABLE `loyalty_members`
  ADD CONSTRAINT `loyalty_members_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `loyalty_transactions`
--
ALTER TABLE `loyalty_transactions`
  ADD CONSTRAINT `loyalty_transactions_ibfk_1` FOREIGN KEY (`member_id`) REFERENCES `loyalty_members` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `loyalty_transactions_ibfk_2` FOREIGN KEY (`bill_id`) REFERENCES `bills` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `loyalty_transactions_ibfk_3` FOREIGN KEY (`performed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `patients`
--
ALTER TABLE `patients`
  ADD CONSTRAINT `patients_ibfk_1` FOREIGN KEY (`clinic_id`) REFERENCES `clinics` (`id`),
  ADD CONSTRAINT `patients_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `pn_attachments`
--
ALTER TABLE `pn_attachments`
  ADD CONSTRAINT `fk_attachment_pn` FOREIGN KEY (`pn_id`) REFERENCES `pn_cases` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_attachment_uploaded_by` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `pn_cases`
--
ALTER TABLE `pn_cases`
  ADD CONSTRAINT `fk_pn_course` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `pn_cases_ibfk_1` FOREIGN KEY (`body_annotation_id`) REFERENCES `body_annotations` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `pn_soap_notes`
--
ALTER TABLE `pn_soap_notes`
  ADD CONSTRAINT `fk_soap_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_soap_pn` FOREIGN KEY (`pn_id`) REFERENCES `pn_cases` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `pn_status_history`
--
ALTER TABLE `pn_status_history`
  ADD CONSTRAINT `fk_status_history_changed_by` FOREIGN KEY (`changed_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_status_history_pn` FOREIGN KEY (`pn_id`) REFERENCES `pn_cases` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `pt_certificates`
--
ALTER TABLE `pt_certificates`
  ADD CONSTRAINT `pt_certificates_ibfk_1` FOREIGN KEY (`pn_id`) REFERENCES `pn_cases` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `pt_certificates_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `public_booking_settings`
--
ALTER TABLE `public_booking_settings`
  ADD CONSTRAINT `fk_booking_settings_clinic` FOREIGN KEY (`clinic_id`) REFERENCES `clinics` (`id`),
  ADD CONSTRAINT `fk_booking_settings_updater` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `public_promotions`
--
ALTER TABLE `public_promotions`
  ADD CONSTRAINT `fk_promotion_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `public_service_packages`
--
ALTER TABLE `public_service_packages`
  ADD CONSTRAINT `fk_public_package_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_public_package_service` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `public_testimonials`
--
ALTER TABLE `public_testimonials`
  ADD CONSTRAINT `fk_testimonial_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_testimonial_package` FOREIGN KEY (`service_package_id`) REFERENCES `public_service_packages` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `services`
--
ALTER TABLE `services`
  ADD CONSTRAINT `fk_service_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `system_settings`
--
ALTER TABLE `system_settings`
  ADD CONSTRAINT `fk_system_settings_user` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
