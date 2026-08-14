-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Jul 31, 2026 at 06:42 PM
-- Server version: 11.4.12-MariaDB-cll-lve-log
-- PHP Version: 8.4.23

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `yelbccrf_landsfy_v2`
--

-- --------------------------------------------------------

--
-- Table structure for table `activity_logs`
--

CREATE TABLE `activity_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `action_type` varchar(100) NOT NULL,
  `description` text NOT NULL,
  `target_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `activity_logs`
--

INSERT INTO `activity_logs` (`id`, `user_id`, `action_type`, `description`, `target_id`, `created_at`) VALUES
(1, 1, 'property_rejected', 'Property ID 67 rejected. Reason: ', 67, '2026-05-14 17:58:21'),
(2, 1, 'property_deleted', 'Property ID 67 marked as deleted.', 67, '2026-05-14 17:58:29'),
(3, 1, 'property_approved', 'Property ID 68 approved and visibility activated.', 68, '2026-05-14 22:54:25'),
(4, 1, 'property_status_update', 'Property #69 status updated to deleted', 69, '2026-05-14 23:12:09'),
(5, 1, 'property_deleted', 'Property ID 68 marked as deleted.', 68, '2026-05-15 12:04:48'),
(6, 1, 'property_approved', 'Property ID 70 approved and visibility activated.', 70, '2026-05-15 12:05:05'),
(7, 1, 'property_approved', 'Property ID 71 approved and visibility activated.', 71, '2026-05-15 12:34:56'),
(8, 1, 'property_approved', 'Property ID 72 approved and visibility activated.', 72, '2026-05-15 12:59:09'),
(9, 1, 'property_approved', 'Property ID 73 approved and visibility activated.', 73, '2026-05-17 10:02:12'),
(10, 1, 'property_approved', 'Property ID 74 approved and visibility activated.', 74, '2026-05-17 10:27:58'),
(11, 1, 'user_activated', 'User ID 26 account reactivated.', 26, '2026-05-17 17:56:21'),
(12, 1, 'user_activated', 'User ID 28 account reactivated.', 28, '2026-05-17 17:56:40'),
(13, 1, 'blog_created', 'Blog post titled \'test\' created.', 1, '2026-05-19 17:46:21'),
(14, 1, 'blog_created', 'Blog post titled \'PM Apna Ghar Programme: A Practical Guide for First-Time Home Buyers\' created.', 2, '2026-05-21 08:38:52'),
(15, 1, 'property_approved', 'Property ID 75 approved and visibility activated.', 75, '2026-06-01 20:00:11'),
(16, 1, 'property_approved', 'Property ID 78 approved and visibility activated.', 78, '2026-06-12 00:35:16'),
(17, 1, 'property_status_update', 'Property #79 status updated to active', 79, '2026-07-31 20:21:42'),
(18, 1, 'property_approved', 'Property ID 77 approved and visibility activated.', 77, '2026-07-31 20:34:27');

-- --------------------------------------------------------

--
-- Table structure for table `agencies`
--

CREATE TABLE `agencies` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `owner_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) DEFAULT NULL,
  `logo_url` varchar(512) DEFAULT NULL,
  `banner_url` varchar(512) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `address` text DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `social_links` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`social_links`)),
  `is_verified` tinyint(1) DEFAULT 0,
  `is_premium` tinyint(1) DEFAULT 0,
  `status` enum('active','under_review','under_watch','suspended') DEFAULT 'under_review',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `agencies`
--

INSERT INTO `agencies` (`id`, `owner_id`, `name`, `slug`, `logo_url`, `banner_url`, `description`, `address`, `phone`, `email`, `website`, `social_links`, `is_verified`, `is_premium`, `status`, `created_at`) VALUES
(1, 31, 'Ali Estate', NULL, NULL, NULL, NULL, 'Karachi', '03038611893', NULL, NULL, NULL, 0, 0, 'under_review', '2026-05-17 18:19:29'),
(2, 32, 'Imran Ali Estate', NULL, NULL, NULL, NULL, 'Karachi', '+923038611893', NULL, NULL, NULL, 0, 0, 'under_review', '2026-05-17 18:23:02'),
(3, 33, 'Asad Estate', NULL, NULL, NULL, NULL, 'Karachi', '+923038611893', NULL, NULL, NULL, 0, 0, 'under_review', '2026-05-19 01:07:30');

-- --------------------------------------------------------

--
-- Table structure for table `agency_documents`
--

CREATE TABLE `agency_documents` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `agency_id` bigint(20) UNSIGNED NOT NULL,
  `document_type` varchar(100) NOT NULL,
  `document_url` varchar(512) NOT NULL,
  `status` enum('pending','verified','rejected') DEFAULT 'pending',
  `uploaded_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `agents`
--

CREATE TABLE `agents` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `slug` varchar(255) DEFAULT NULL,
  `agency_id` bigint(20) UNSIGNED NOT NULL,
  `bio` text DEFAULT NULL,
  `specialization` varchar(255) DEFAULT NULL,
  `license_number` varchar(100) DEFAULT NULL,
  `experience_years` int(11) DEFAULT 0,
  `platinum_quota` int(11) DEFAULT 0,
  `platinum_used` int(11) DEFAULT 0,
  `diamond_quota` int(11) DEFAULT 0,
  `diamond_used` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `agent_reviews`
--

CREATE TABLE `agent_reviews` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `agent_id` bigint(20) UNSIGNED NOT NULL,
  `reviewer_id` bigint(20) UNSIGNED NOT NULL,
  `rating` decimal(2,1) NOT NULL,
  `review_text` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `amenity_fields`
--

CREATE TABLE `amenity_fields` (
  `id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL,
  `label` varchar(100) NOT NULL,
  `field_type` enum('switch','dropdown','number_group','text_input','number') DEFAULT 'switch',
  `options` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`options`)),
  `is_required` tinyint(1) DEFAULT 0,
  `icon_class` varchar(50) DEFAULT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `sort_order` int(11) DEFAULT 0,
  `context` enum('all','home','plot','commercial') DEFAULT 'all'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `amenity_fields`
--

INSERT INTO `amenity_fields` (`id`, `group_id`, `label`, `field_type`, `options`, `is_required`, `icon_class`, `status`, `sort_order`, `context`) VALUES
(1, 1, 'Built in year', 'number', NULL, 0, 'fa-solid fa-calendar', 'active', 0, 'home'),
(2, 1, 'Parking Spaces', 'number', NULL, 0, 'fa-solid fa-car', 'active', 0, 'all'),
(3, 2, 'Bedrooms', 'number_group', '[\"1\", \"2\", \"3\", \"4\", \"5\", \"6\", \"7\", \"8\", \"9\", \"10+\"]', 1, 'fa-solid fa-bed', 'active', 0, 'home'),
(4, 2, 'Bathrooms', 'number_group', '[\"1\", \"2\", \"3\", \"4\", \"5\", \"6\", \"7+\"]', 1, 'fa-solid fa-bathtub', 'active', 0, 'home'),
(5, 3, 'Mosque', 'switch', NULL, 0, 'fa-solid fa-mosque', 'active', 0, 'all'),
(6, 6, 'Corner Plot', 'switch', NULL, 0, 'fa-solid fa-selection-plus', 'active', 0, 'plot'),
(7, 6, 'Boundary Wall', 'switch', NULL, 0, 'fa-solid fa-wall', 'active', 0, 'plot');

-- --------------------------------------------------------

--
-- Table structure for table `amenity_groups`
--

CREATE TABLE `amenity_groups` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `icon_class` varchar(50) DEFAULT NULL,
  `sort_order` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `amenity_groups`
--

INSERT INTO `amenity_groups` (`id`, `name`, `icon_class`, `sort_order`) VALUES
(1, 'Main Features', 'ph-star', 1),
(2, 'Rooms', 'ph-door', 2),
(3, 'Community Features', 'ph-users', 3),
(4, 'Healthcare Recreational', 'ph-first-aid', 4),
(5, 'Business and Communication', 'ph-broadcast', 5),
(6, 'Plot Features', 'ph-squares-four', 6);

-- --------------------------------------------------------

--
-- Table structure for table `blogs`
--

CREATE TABLE `blogs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `excerpt` text DEFAULT NULL,
  `content` longtext DEFAULT NULL,
  `image_url` varchar(512) DEFAULT NULL,
  `author_id` bigint(20) UNSIGNED DEFAULT NULL,
  `category` varchar(100) DEFAULT NULL,
  `status` enum('published','draft','deleted') DEFAULT 'published',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `read_time` int(11) DEFAULT 5
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `blogs`
--

INSERT INTO `blogs` (`id`, `title`, `slug`, `excerpt`, `content`, `image_url`, `author_id`, `category`, `status`, `created_at`, `updated_at`, `read_time`) VALUES
(2, 'PM Apna Ghar Programme: A Practical Guide for First-Time Home Buyers', 'pm-apna-ghar-programme-a-practical-guide-for-first-time-home-buyers', 'For millions of Pakistani families who’ve spent years paying rent and quietly wondering if they’ll ever own a home, the Wazir-e-Azam Apna Ghar Programme (commonly referred to as the PM Apna Ghar Programme) is one of the most significant government efforts in recent memory to make that dream feel genuinely reachable.', 'For millions of Pakistani families who’ve spent years paying rent and quietly wondering if they’ll ever own a home, the Wazir-e-Azam Apna Ghar Programme (commonly referred to as the PM Apna Ghar Programme) is one of the most significant government efforts in recent memory to make that dream feel genuinely reachable.\r\n\r\nHere’s everything you need to know, written plainly.\r\n\r\nWhat Is This Programme, Really?\r\n\r\nLaunched by Prime Minister Shehbaz Sharif as part of a federal initiative to address Pakistan’s housing crisis, the scheme aims to provide low- and middle-income households with affordable housing finance. The overall plan targets 500,000 housing units over five years, at an estimated cost of Rs. 3.2 trillion, to bridge the gap between rising property prices and what ordinary families can afford.\r\n\r\nIt’s not a handout. It’s a subsidised loan scheme, delivered through participating banks, with the government picking up the difference on your markup rate in the early years.\r\n\r\nThe Numbers That Matter\r\n\r\nThe scheme offers housing finance for up to 20 years, including a 10-year subsidy period, at a subsidised markup rate of 5% for the first ten years. After that, the rate shifts to a market-linked markup. Participating banks provide up to 90% of the property value, meaning you only need to contribute 10% as initial equity.\r\n\r\nLoan limit: Up to PKR 10 million\r\nYour down payment: 10% of property value\r\nMarkup: 5% fixed for first 10 years, then market rate\r\nRepayment period: Up to 20 years\r\nWho Can Apply?\r\n\r\nThe eligibility criteria are fairly clear, though the income minimums vary slightly by bank.\r\n\r\nApplicants must be between 25 and 60 years of age, and the loan must mature before age 60 for salaried individuals and 65 for self-employed applicants.\r\n\r\nAll men and women holding a valid CNIC are eligible, provided they are first-time homeowners and do not own any housing unit in their name.\r\n\r\nThe minimum income requirement for the primary applicant is PKR 25,000 per month, and PKR 20,000 for any co-applicant. (Note: some banks set a higher threshold, so confirm with your branch.)\r\n\r\nProperty size limits: The scheme covers houses of up to 10 Marla (2,720 sq. ft.) and flats of up to 1,500 sq. ft.\r\n\r\nEmployment requirements vary by bank, but as a general guide, self-employed businesspeople need a minimum of 3 years’ proof of business, salaried employees need at least 2 years of employment, and contractual government employees need a minimum of 3 years.\r\n\r\nWhere It Applies\r\n\r\nThe scheme is available to applicants from all four provinces, the federal capital, Gilgit-Baltistan, and Azad Jammu and Kashmir.\r\n\r\nHow to Apply\r\n\r\nThe application process is bank-driven; you don’t need to go through a government portal. You can apply through any participating commercial bank, Islamic bank, or microfinance institution. Most major banks across the country are on board, so your first step is simply visiting the nearest branch that participates in the scheme.\r\n\r\nWhat to bring:\r\n\r\nValid CNIC\r\nProof of income (salary slip or business documents)\r\nBank statements (last 6 to 12 months)\r\nProperty documents (if you already have a plot)\r\nUtility bills\r\nPassport-sized photographs\r\nThe bank will assess your Debt Burden Ratio (DBR), which must not exceed 33% of your net monthly income, and will check your ECIB credit history. A clean credit record is essential.\r\n\r\nA Few Things to Keep in Mind\r\n\r\nProperty valuation will be conducted through the bank’s approved evaluator. You can’t just present your own estimate.\r\nThe scheme covers residential use only, not investment or rental properties.\r\nLoan disbursement for construction projects typically happens in phases, tied to construction progress.\r\nWatch out for unofficial agents or middlemen who claim to fast-track applications. The process is bank-managed and straightforward enough to handle yourself.\r\nThe Bigger Picture\r\n\r\nThe scheme is supervised by the Ministry of Housing and Works, with monthly progress reports submitted directly to the Prime Minister. Beyond housing, it is expected to stimulate over 40 allied industries, including cement, steel, and construction labour.\r\n\r\nFor families currently renting, this programme represents a realistic path to ownership, provided you meet the income requirements, have a clean credit history, and can manage the monthly instalments. Apply early, go directly through a participating bank, and make sure your documents are in order before you walk in.', 'uploads/blogs/blog_c77bea8b0ff44d9e.jpg', 1, 'General', 'published', '2026-05-21 08:38:52', '2026-05-21 08:38:52', 3);

-- --------------------------------------------------------

--
-- Table structure for table `cities`
--

CREATE TABLE `cities` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `slug` varchar(100) NOT NULL,
  `is_popular` tinyint(1) DEFAULT 0,
  `sort_order` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `cities`
--

INSERT INTO `cities` (`id`, `name`, `slug`, `is_popular`, `sort_order`) VALUES
(1, 'Karachi', 'karachi', 1, 0),
(2, 'Lahore', 'lahore', 1, 0),
(3, 'Islamabad', 'islamabad', 1, 0),
(4, 'Rawalpindi', 'rawalpindi', 0, 0),
(5, 'Faisalabad', 'faisalabad', 0, 0),
(6, 'kashmir', 'kashmir', 1, 0),
(17, 'Peshawar', 'peshawar', 0, 0),
(18, 'Hyderabad', 'hyderabad', 0, 0),
(19, 'Multan', 'multan', 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `leads`
--

CREATE TABLE `leads` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `property_id` bigint(20) UNSIGNED NOT NULL,
  `buyer_id` bigint(20) UNSIGNED DEFAULT NULL,
  `sender_name` varchar(255) DEFAULT NULL,
  `sender_email` varchar(255) DEFAULT NULL,
  `sender_phone` varchar(20) DEFAULT NULL,
  `message` text DEFAULT NULL,
  `status` enum('new','contacted','viewing_scheduled','sold','closed','rejected') DEFAULT 'new',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `locations`
--

CREATE TABLE `locations` (
  `id` int(11) NOT NULL,
  `city_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `locations`
--

INSERT INTO `locations` (`id`, `city_id`, `name`, `slug`) VALUES
(1, 1, 'Dha phase 8', 'dha-phase-8'),
(3, 1, 'DHA phase 2', 'dha-phase-2'),
(4, 1, 'naziamabad', 'naziamabad'),
(5, 1, 'test', 'test'),
(7, 1, 'Clifton', 'clifton'),
(8, 1, 'DHA Phase 8, DHA Defence, Karachi, Sindh', 'dha-phase-8-dha-defence-karachi-sindh'),
(9, 1, 'Bahria Town', 'bahria-town'),
(10, 1, 'North Nazimabad', 'north-nazimabad'),
(11, 3, 'North Nazimabad', 'north-nazimabad'),
(12, 1, 'Naya Nazimabad', 'naya-nazimabad'),
(13, 1, 'Naya Nazimabad Block \'D\'', 'naya-nazimabad-block-d-'),
(14, 1, 'Defence', 'defence'),
(15, 3, 'DHA Phase 8, DHA Defence, Karachi, Sindh', 'dha-phase-8-dha-defence-karachi-sindh'),
(16, 18, 'DHA', 'dha'),
(17, 1, 'Naya Nazimabad, Block C.', 'naya-nazimabad-block-c-'),
(18, 1, 'Naya Nazimabad Block A', 'naya-nazimabad-block-a'),
(19, 2, 'BAHRIA TOWN LAHORE', 'bahria-town-lahore'),
(20, 1, 'PS CITY 1 Scheme 33', 'ps-city-1-scheme-33'),
(21, 2, 'DHA, Lahore.', 'dha-lahore-'),
(22, 2, 'Al Hafeez Phase 5.', 'al-hafeez-phase-5-'),
(23, 2, 'Lahore', 'lahore'),
(24, 1, 'DHA LAHORE', 'dha-lahore'),
(25, 1, 'DHA Phase 6 Lahore', 'dha-phase-6-lahore'),
(26, 2, 'DHA LAHORE', 'dha-lahore'),
(27, 3, 'Dha Phasa 8', 'dha-phasa-8'),
(28, 1, 'DHA Phase 8 – Zone A, Karachi', 'dha-phase-8-zone-a-karachi'),
(29, 1, 'DHA Phase 8 – Zone A.', 'dha-phase-8-zone-a-'),
(30, 1, 'DHA Phase 8 – Zone A,', 'dha-phase-8-zone-a-'),
(31, 1, 'location federal b area block 15', 'location-federal-b-area-block-15'),
(32, 1, 'Khayaban-e-Tanzeem, DHA Phase 5 – Karachi', 'khayaban-e-tanzeem-dha-phase-5-karachi'),
(33, 18, 'rwar', 'rwar'),
(34, 18, 'test', 'test'),
(35, 1, 'Bath Island', 'bath-island'),
(36, 4, 'Bahria Town Rawalpindi Phase 8', 'bahria-town-rawalpindi-phase-8'),
(37, 4, 'Bahria Town Phase 8', 'bahria-town-phase-8'),
(38, 2, 'DHA Phase 6 Lahore', 'dha-phase-6-lahore'),
(39, 4, 'Bahria Town Phase 8, Rawalpindi', 'bahria-town-phase-8-rawalpindi');

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `sender_id` bigint(20) UNSIGNED DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `message` text DEFAULT NULL,
  `type` varchar(50) DEFAULT 'system',
  `reference_id` bigint(20) UNSIGNED DEFAULT NULL,
  `reference_type` varchar(50) DEFAULT NULL,
  `link` varchar(255) DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`id`, `user_id`, `sender_id`, `title`, `message`, `type`, `reference_id`, `reference_type`, `link`, `is_read`, `created_at`) VALUES
(1, 1, 1, 'Listing Rejected', 'Your property listing \'Test\' has been rejected by the admin.', 'property_deleted', NULL, NULL, NULL, 0, '2026-05-14 23:12:09'),
(2, 36, 1, 'Listing Approved!', 'Your property listing \'FOR RENT | NAYA NAZIMABAD 🏠  120 Sq Yards & 160 Sq Yards Houses Available for Reny\' has been successfully approved and is now live.', 'property_active', NULL, NULL, NULL, 0, '2026-07-31 20:21:42');

-- --------------------------------------------------------

--
-- Table structure for table `premium_requests`
--

CREATE TABLE `premium_requests` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `request_type` enum('platinum_credit','diamond_credit') NOT NULL,
  `amount_paid` decimal(10,2) NOT NULL,
  `payment_screenshot` varchar(255) NOT NULL,
  `status` enum('pending','approved','rejected') DEFAULT 'pending',
  `admin_note` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `properties`
--

CREATE TABLE `properties` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `author_id` bigint(20) UNSIGNED NOT NULL,
  `agency_id` bigint(20) UNSIGNED DEFAULT NULL,
  `category_id` int(11) NOT NULL,
  `subtype_id` int(11) NOT NULL,
  `city_id` int(11) NOT NULL,
  `location_name` varchar(255) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `contact_email` varchar(255) DEFAULT NULL,
  `location_id` int(11) DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `description` longtext DEFAULT NULL,
  `price` decimal(15,2) NOT NULL,
  `purpose` enum('sell','rent') DEFAULT 'sell',
  `status` enum('active','sold','under_review','inactive','rejected','deleted') DEFAULT 'under_review',
  `rejection_reason` text DEFAULT NULL,
  `area_size` decimal(10,2) NOT NULL,
  `area_unit` enum('kanal','marla','sqft','sqyrd') NOT NULL,
  `is_installment_available` tinyint(1) DEFAULT 0,
  `is_ready_for_possession` tinyint(1) DEFAULT 0,
  `video_url` varchar(512) DEFAULT NULL,
  `is_featured` tinyint(1) DEFAULT 0,
  `premium_type` enum('none','platinum','diamond') DEFAULT 'none',
  `premium_status` enum('none','pending','active','expired') DEFAULT 'none',
  `premium_expiry` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `properties`
--

INSERT INTO `properties` (`id`, `author_id`, `agency_id`, `category_id`, `subtype_id`, `city_id`, `location_name`, `address`, `contact_email`, `location_id`, `title`, `slug`, `description`, `price`, `purpose`, `status`, `rejection_reason`, `area_size`, `area_unit`, `is_installment_available`, `is_ready_for_possession`, `video_url`, `is_featured`, `premium_type`, `premium_status`, `premium_expiry`, `created_at`, `updated_at`) VALUES
(21, 1, NULL, 1, 2, 1, '', '', NULL, NULL, 'Flat Is Available For Sale', 'flat-is-available-for-sale', '1800sqft\r\n Modern 2-Bedroom Apartment Featuring A Spacious Living Area,\r\n Well-Designed Bedrooms,\r\n A Contemporary Kitchen, And Stylish Bathrooms. Ideal For Comfortable Living In A Prime Location. \r\n High-demand category ideal for couples, small families, or short-term rental ROI\r\n Located in Emaar Oceanfront, offering unmatched seafront lifestyle\r\n Consistent rental demand with strong returns\r\n Secure & premium community living\r\n Community Features (Emaar Oceanfront):\r\n Private Beach Access for residents\r\n Infinity Swimming Pool, Gym, Sauna & Jacuzzi\r\n Childrens Play Areas, Parks & Gardens\r\n 24/7 Security & CCTV Surveillance\r\n Retail, Cafs & Lifestyle Outlets within community\r\n High-speed elevators & modern infrastructure\r\n Well-maintained & family-friendly environment\r\n Highlights:\r\n Pool + Sea facing unit one of the most desirable views\r\n Prime location in Coral Tower 1 Emaar Oceanfront\r\n Ready to move in secure your investment today!\r\n For Immediate Deal & Viewing:', 54000000.00, 'sell', 'active', NULL, 200.00, 'sqyrd', 0, 0, NULL, 0, 'none', 'none', NULL, '2026-01-06 20:46:30', '2026-04-29 18:09:20'),
(22, 1, NULL, 1, 2, 1, 'Clifton', 'Emaar Pearl Towers, Emaar Crescent Bay, DHA Phase 8, DHA Defence, Karachi, Sindh', NULL, 7, 'Prime Location Emaar Pearl Towers House Sized 300 Square Yards For sale', 'prime-location-emaar-pearl-towers-house-sized-300-square-yards-for-sale', 'The demand price is set pretty reasonably at Rs. 82500000. For a luxurious lifestyle, you can check out properties in Karachi. Book your 300 Square Yards House today to mark the beginning of your prosperous future. You can be the owner of your dream home, with this beautiful House available for sale. All the routine facilities are at a close reach from the Houses in Emaar Pearl Towers. Ideally located on Emaar Pearl Towers, this is a rare and golden real estate opportunity. ', 87000000.00, 'sell', 'active', NULL, 300.00, 'sqyrd', 0, 0, NULL, 0, 'none', 'none', NULL, '2026-01-09 16:59:11', '2026-04-29 18:09:20'),
(23, 1, NULL, 1, 2, 1, 'DHA Phase 8, DHA Defence, Karachi, Sindh', 'Emaar Coral Towers, Emaar Crescent Bay, DHA Phase 8, DHA Defence, Karachi, Sindh', NULL, 8, 'Prime Location Emaar Coral Towers House', 'prime-location-emaar-coral-towers-house', 'If you have a budget of Rs. 69000000, here is the listing you must explore. Looking for a well-constructed home for your family? This can be the best option for you. Want the perfect space and a good bargain? Look no further for we give you the tools necessary to make all 250 Square Yards of this property your next place. You can find the best properties in Emaar Coral Towers. The city of Karachi is developing fast and you can find some really good property deals. A House that is located in the prime location like this one is no less than an opportunity. ', 75000000.00, 'sell', 'active', NULL, 250.00, 'sqyrd', 0, 0, NULL, 0, 'none', 'none', NULL, '2026-01-09 17:47:55', '2026-04-29 18:09:20'),
(26, 1, NULL, 1, 1, 1, 'Bahria Town', 'street 13', NULL, 9, 'House for Sale ', 'house-for-sale', 'Amazing house west open Amazing house west open Amazing house west open Amazing house west open ', 25000000.00, 'sell', 'active', NULL, 120.00, 'sqyrd', 0, 0, NULL, 0, 'none', 'none', NULL, '2026-01-13 08:11:24', '2026-04-29 18:09:20'),
(27, 1, NULL, 1, 2, 1, 'North Nazimabad', 'Block B 14 street', NULL, 10, 'House Available for sale west open near masjd', 'house-available-for-sale-west-open-near-masjd', 'House Available for sale west open near masjdHouse Available for sale west open near masjdHouse Available for sale west open near masjdHouse Available for sale west open near masjdHouse Available for sale west open near masjdHouse Available for sale west open near masjdHouse Available for sale west open near masjdHouse Available for sale west open near masjdHouse Available for sale west open near masjdHouse Available for sale west open near masjd', 3500000.00, 'sell', 'active', NULL, 400.00, 'sqyrd', 0, 0, NULL, 0, 'none', 'none', NULL, '2026-01-13 08:38:17', '2026-04-29 18:09:20'),
(28, 1, NULL, 1, 1, 3, 'North Nazimabad', 'Block N', NULL, 11, 'Beautiful house available for sale ', 'beautiful-house-available-for-sale', 'Beautiful house available for sale Beautiful house available for sale Beautiful house available for sale Beautiful house available for sale ', 3000000.00, 'sell', 'active', NULL, 120.00, 'sqyrd', 0, 0, NULL, 0, 'none', 'none', NULL, '2026-01-14 08:38:44', '2026-04-29 18:09:20'),
(30, 19, NULL, 1, 1, 1, 'North Nazimabad', '', NULL, 10, 'house Available for sell', 'house-available-for-sell', 'House Available for sell House Available for sell House Available for sell House Available for sell House Available for sell House Available for sell', 25000000.00, 'sell', 'active', NULL, 240.00, 'sqyrd', 0, 0, NULL, 0, 'none', 'none', NULL, '2026-01-17 07:34:16', '2026-04-29 18:09:20'),
(31, 1, NULL, 1, 1, 1, 'North Nazimabad', '', NULL, 10, 'house for rent in near airport', 'house-for-rent-in-near-airport', '5 km meter from airport westopen no utlity issue 5 km meter from airport westopen no utlity issue5 km meter from airport westopen no utlity issue  5 km meter from airport westopen no utlity issue', 220000.00, 'rent', 'active', NULL, 600.00, 'sqyrd', 0, 0, NULL, 1, 'none', 'none', NULL, '2026-01-17 07:43:23', '2026-04-29 18:09:20'),
(32, 19, NULL, 1, 1, 1, 'Naya Nazimabad', '', NULL, 12, 'House Available for Sale 160sq.yd', 'house-available-for-sale-160sq-yd', 'House available for sell west open ', 40000000.00, 'sell', 'active', NULL, 160.00, 'sqyrd', 0, 0, NULL, 0, 'none', 'none', NULL, '2026-01-17 09:01:48', '2026-04-29 18:09:20'),
(33, 1, NULL, 1, 1, 1, 'Naya Nazimabad', '', NULL, 12, 'House Availble for Sell', 'house-availble-for-sell', 'House Availble for sell west side house for sale on the corner by a friend and a neighbor.', 35000000.00, 'sell', 'active', NULL, 120.00, 'sqyrd', 0, 0, NULL, 1, 'none', 'none', NULL, '2026-01-17 12:00:17', '2026-04-29 18:09:20'),
(34, 20, NULL, 1, 1, 1, 'Naya Nazimabad ', 'Block A ', NULL, 12, 'Banglow For Sale ', 'banglow-for-sale', '120Sq yrd+extra land \r\nWest Open \r\n60ft Road\r\nBlock A ideal location \r\nLavish Construction 💕', 44500000.00, 'sell', 'active', NULL, 120.00, 'sqyrd', 0, 0, NULL, 0, 'none', 'none', NULL, '2026-01-20 14:12:00', '2026-04-29 18:09:20'),
(35, 20, NULL, 3, 12, 1, 'Naya Nazimabad ', 'Block A ', NULL, 12, 'Commercial plot Naya Nazimabad ', 'commercial-plot-naya-nazimabad', '230Sq yrd Commercial plot in Naya Nazimabad Boundary wall Society located Block A near to Gymkhana opportunity for Builders investors ', 92000000.00, 'sell', 'active', NULL, 230.00, 'sqyrd', 0, 0, NULL, 0, 'none', 'none', NULL, '2026-01-20 21:50:34', '2026-04-29 18:09:20'),
(37, 1, NULL, 1, 1, 1, 'North Nazimabad', '', NULL, 10, 'House Availble for Sell', 'house-availble-for-sell-1769015638', 'House available for sell west open american style kitchen spacious house. House available for sell west open american style kitchen spacious house. House available for sell west open american style kitchen spacious house.', 60000000.00, 'sell', 'active', NULL, 400.00, 'sqyrd', 0, 0, NULL, 1, 'none', 'none', NULL, '2026-01-21 16:45:32', '2026-04-29 18:09:20'),
(38, 1, NULL, 1, 1, 1, 'North Nazimabad', '', NULL, 10, 'House Available for sell in North Nazimabad', 'house-available-for-sell-in-north-nazimabad', 'House Available for sell in North Nazimabad. House Available for sell in North Nazimabad. House Available for sell in North Nazimabad', 80000000.00, 'sell', 'active', NULL, 400.00, 'sqyrd', 0, 0, NULL, 1, 'none', 'none', NULL, '2026-01-21 17:23:45', '2026-04-29 18:09:20'),
(39, 1, NULL, 1, 1, 1, 'Naya Nazimabad', '', NULL, 12, 'Flat Available For sale ', 'flat-available-for-sale', 'Flat Available for sale in main road area. Flat Available for sale in main road area. Flat Available for sale in main road area. Flat Available for sale in main road area.', 55000000.00, 'sell', 'active', NULL, 400.00, 'sqyrd', 0, 0, NULL, 1, 'none', 'none', NULL, '2026-01-21 17:32:24', '2026-04-29 18:09:20'),
(40, 1, NULL, 1, 1, 1, 'Naya Nazimabad Block \'D\'', '', NULL, 13, 'Plot Available for sell in west zone area', 'plot-available-for-sell-in-west-zone-area', 'Plot Available for sell in west zone area,Plot Available for sell in west zone area. Plot Available for sell in west zone area Plot Available for sell in west zone area.', 46500000.00, 'sell', 'active', NULL, 240.00, 'sqyrd', 0, 0, NULL, 1, 'none', 'none', NULL, '2026-01-21 17:40:35', '2026-04-29 18:09:20'),
(41, 1, NULL, 1, 1, 1, 'North Nazimabad', '', NULL, 10, 'Amazing house available for sale ', 'amazing-house-available-for-sale', 'Amazing house available for sale Amazing house available for sale Amazing house available for sale Amazing house available for sale Amazing house available for sale Amazing house available for sale ', 55000000.00, 'sell', 'active', NULL, 240.00, 'sqyrd', 0, 0, NULL, 1, 'none', 'none', NULL, '2026-01-21 17:48:26', '2026-04-29 18:09:20'),
(42, 1, NULL, 1, 1, 1, 'Defence', '', NULL, 14, 'Amazing flat available for sale ', 'amazing-flat-available-for-sale', 'Amazing flat available for sale. Amazing flat available for sale. Amazing flat available for sale', 75000000.00, 'sell', 'active', NULL, 1600.00, 'sqft', 0, 0, NULL, 1, 'none', 'none', NULL, '2026-01-21 18:11:22', '2026-04-29 18:09:20'),
(43, 1, NULL, 1, 2, 1, 'Clifton', '', NULL, 7, 'House available for rent west open full utilty no water gas issue', 'house-available-for-rent-west-open-full-utilty-no-water-gas-issue', 'House available for rent west open full utilty no water gas issueHouse available for rent west open full utilty no water gas issueHouse available for rent west open full utilty no water gas issueHouse available for rent west open full utilty no water gas issue', 450000.00, 'rent', 'active', NULL, 1400.00, 'sqft', 0, 0, NULL, 1, 'none', 'none', NULL, '2026-01-21 18:18:10', '2026-04-29 18:09:20'),
(44, 1, NULL, 3, 13, 3, 'DHA Phase 8, DHA Defence, Karachi, Sindh', '', NULL, 15, 'House available for rent west open full utilty no water gas issue', 'house-available-for-rent-west-open-full-utilty-no-water-gas-issue-1769019673', 'House available for rent west open full utilty no water gas issueHouse available for rent west open full utilty no water gas issue', 35000000.00, 'sell', 'active', NULL, 300.00, 'sqyrd', 0, 0, NULL, 1, 'none', 'none', NULL, '2026-01-21 18:21:13', '2026-04-29 18:09:20'),
(45, 1, NULL, 1, 1, 18, 'DHA', '', NULL, 16, 'House available for sale west open full utilty no water gas issue', 'house-available-for-sale-west-open-full-utilty-no-water-gas-issue', 'House available for rent west open full utilty no water gas issueHouse available for rent west open full utilty no water gas issue', 45000000.00, 'sell', 'active', NULL, 120.00, 'sqyrd', 0, 0, NULL, 1, 'none', 'none', NULL, '2026-01-21 18:27:03', '2026-04-29 18:09:20'),
(46, 23, NULL, 1, 1, 1, 'Naya nazimabad ', '', NULL, 12, 'House Available for Sell', 'house-available-for-sell-1769095524', '120sq one unit benglow brand new block C Naya nazimabad masque facing brand new benglow', 3700000.00, 'sell', 'active', NULL, 120.00, 'sqyrd', 0, 0, NULL, 0, 'none', 'none', NULL, '2026-01-22 14:43:12', '2026-04-29 18:09:20'),
(47, 1, NULL, 1, 1, 1, 'Naya Nazimabad', NULL, NULL, 12, 'House Available for sell', 'house-available-for-sell-1771043056', 'A brand new, beautifully constructed luxury bungalow is available for sale in the prime location of Naya Nazimabad, This property has been built with high-class materials and modern design, making it an ideal choice for comfortable family living and smart investment.\r\nProperty Details & Features:\r\nPlot Size: 120 Square Yards\r\nWest Open Bungalow\r\nT-Facing\r\nNear Masjid\r\nNear Commercial Area\r\nElegant Class A Finishing Premium Luxury Tile Work\r\nWell-planned layout with modern elevation\r\nPeaceful & secure neighborhood\r\nIdeal for residential living as well as future value\r\nThis bungalow offers a perfect blend of luxury, location, and quality construction. Serious buyers are encouraged to contact for further details and site visit.', 55000000.00, 'sell', 'active', NULL, 160.00, 'sqyrd', 0, 0, NULL, 1, 'none', 'none', NULL, '2026-01-28 16:52:24', '2026-04-29 18:09:20'),
(48, 1, NULL, 1, 1, 1, 'Naya Nazimabad, Block C.', NULL, NULL, 17, 'Exquisite Bungalow for Sale in Naya Nazimabad!', 'exquisite-bungalow-for-sale-in-naya-nazimabad', 'Discover comfort and elegance in our move-in ready bungalow at the heart of Naya Nazimabad. With a prime location and stunning view, experience the best of modern living effortlessly. ✨ Features: 🏠 Move-In Ready: No waiting, it\'s ready to be your home. 📍 Prime Location: Close to everything you need.  Vibrant energy right around the corner. 🛋️ Spacious Interior: Comfortable living spaces for your family. 🏡 Modern Design: Stylish and functional. 🌟 ', 55000000.00, 'sell', 'active', NULL, 120.00, 'sqyrd', 0, 0, NULL, 1, 'none', 'none', NULL, '2026-02-06 16:28:49', '2026-04-29 18:09:20'),
(49, 25, NULL, 1, 1, 1, 'Naya Nazimabad Block A', NULL, NULL, 18, 'Brand New Banglow For Sale In Naya Nazimabad Block A', 'brand-new-banglow-for-sale-in-naya-nazimabad-block-a', 'Brand New Banglow For Sale In Naya Nazimabad Block A\r\n40 Feet Road \r\nCross West Open \r\nNear To Main Gate \r\nNear To Park \r\nNear To Masjid ', 40000000.00, 'sell', 'active', NULL, 120.00, 'sqyrd', 0, 0, NULL, 0, 'none', 'none', NULL, '2026-02-17 14:04:42', '2026-04-29 18:09:20'),
(50, 20, NULL, 1, 1, 1, 'Naya Nazimabad ', NULL, NULL, 12, 'Banglow For Rent ', 'banglow-for-rent', 'Banglow For Rent \r\n120sa yrd\r\nOne unit independent ', 120000.00, 'rent', 'active', NULL, 120.00, 'sqyrd', 0, 0, NULL, 0, 'none', 'none', NULL, '2026-02-21 21:03:03', '2026-04-29 18:09:20'),
(51, 1, NULL, 1, 1, 2, 'BAHRIA TOWN LAHORE', NULL, NULL, 19, 'HOUSE FOR SALE BAHRIA TOWN LAHORE', 'house-for-sale-bahria-town-lahore', '10 MARLA BRAND NEW HOUSE \r\nFOR SALE BAHRIA TOWN LAHORE\r\n👉 Hot Location \r\n👉 Near Park\r\n👉 Near Main Road\r\n👉 Accommodation\r\n▪️5 Bedroom\'s 🛏️ \r\n▪️2 Kitchen 🍱\r\n▪️2 TV Launch 📺\r\n▪️7 Bathroom 🛁', 120000000.00, 'sell', 'active', NULL, 1.00, 'kanal', 0, 0, NULL, 1, 'none', 'none', NULL, '2026-02-22 16:39:34', '2026-04-29 18:09:20'),
(52, 1, NULL, 1, 1, 1, 'PS CITY 1 Scheme 33', NULL, NULL, 20, 'Brand new 120 yds house for sale in PS CITY 1 Scheme 33.', 'brand-new-120-yds-house-for-sale-in-ps-city-1-scheme-33', 'Ground + 1, west open .Near to Park and masjid .\r\nGated society . 24 hrs Security.\r\nNo loadshedding .\r\nSweet water .\r\nIdeal location with peacefully & educated families around.', 35000000.00, 'sell', 'active', NULL, 120.00, 'sqyrd', 0, 0, NULL, 1, 'none', 'none', NULL, '2026-02-22 18:24:23', '2026-04-29 18:09:20'),
(53, 1, NULL, 1, 1, 2, 'DHA, Lahore.', NULL, NULL, 21, 'Luxury Bungalow for Sale in DHA Lahor', 'luxury-bungalow-for-sale-in-dha-lahor', 'Welcome to this stunning, brand-new luxury bungalow located in the heart of DHA Lahore. Designed with elegance and comfort in mind, this exceptional property offers a perfect blend of modern architecture, premium features, and a secure environment for your family.\r\n\r\nSpread over 1000 square yards, this bungalow includes 2 grand master bedrooms and 4 additional bedrooms ideal for family members and guests. The double-door basement provides ample storage space and added security. A private swimming pool and in-house lift enhance the luxurious lifestyle this home offers.\r\n\r\nThis is a rare opportunity to own a dream home in one of Karachi’s most prestigious neighborhoods.\r\n', 130000000.00, 'sell', 'active', NULL, 1000.00, 'sqyrd', 0, 0, NULL, 1, 'none', 'none', NULL, '2026-02-22 18:34:48', '2026-04-29 18:09:20'),
(54, 1, NULL, 1, 1, 2, 'Al Hafeez Phase 5.', NULL, NULL, 22, 'House for Sale – 5 Marla (Half Triple Story)', 'house-for-sale-5-marla-half-triple-story', 'A beautifully designed and well-maintained house located in a prime residential area of Al Hafeez Phase 5.\r\n Ideal for families looking for comfort, space, and modern living.\r\n🏠 Property Features:\r\n4 Spacious Bedrooms\r\n5 Modern Washrooms\r\n2 Master Kitchens\r\n2 Lounges (Including 1 Master Lounge)\r\nWalk-in Closet\r\nPorch Space for Full SUV\r\nOpen Area at Back (Washing Area)\r\nOpen Area at Front\r\nRoof with Proper BBQ & Sitting Area\r\n✔ Solid construction\r\n✔ Practical layout\r\n✔ Peaceful residential environment', 75000000.00, 'sell', 'active', NULL, 400.00, 'sqyrd', 0, 0, NULL, 1, 'none', 'none', NULL, '2026-03-01 18:35:20', '2026-04-29 18:09:20'),
(55, 1, NULL, 1, 1, 2, 'Lahore', NULL, NULL, 23, '2 Kanal Royal Castle for Sale ', '2-kanal-royal-castle-for-sale', 'Property Details:\r\nDesign: Spanish+Classical style architecture with timeless elegance and modern functionality.Bedrooms: 7, Swimming Pool, Home Theater, Advanced Kitchen, Triple-Height Drawing Rooms & Lobby, Fully Furnished, Solid Construction, Mesmerizing Views,\r\nFor Inquiries or to Schedule a Visit \r\nAHDL3900 Contact us.\r\nDon’t miss the opportunity to own your dream home!\r\n𝐏𝐑𝐎𝐕𝐈𝐃𝐈𝐍𝐆 𝐒𝐄𝐑𝐕𝐈𝐂𝐄𝐒 𝐀𝐋𝐋 𝐎𝐕𝐄𝐑 𝐏𝐀𝐊𝐈𝐒𝐓𝐀𝐍!\r\nReal Estate | Architecture | Construction | Interior Design | Construction & Project Management Consultants\r\n#Architecture #interior #modernhome #dhalahore #newlisting #dha #pakistan #karachi #lahore ', 260000000.00, 'sell', 'active', NULL, 2.00, 'kanal', 0, 0, NULL, 1, 'none', 'none', NULL, '2026-03-11 21:35:58', '2026-04-29 18:09:20'),
(56, 1, NULL, 1, 1, 1, 'DHA Phase 8, DHA Defence, Karachi, Sindh', NULL, NULL, 8, '666 Sq. Yards Luxury Villa – DHA Phase 8 (Zone A)', '666-sq-yards-luxury-villa-dha-phase-8-zone-a', 'Discover an exceptional 10,000+ sq. ft. designer villa located on a prime street in DHA Phase 8, thoughtfully designed for sophisticated and comfortable living.\r\nKey Features\r\n• Spacious basement with a private home theatre and games lounge\r\n• 5 luxurious bedrooms, including a master suite with private terrace\r\n• Modern Italian kitchens with premium finishes\r\n• Elegant poolside courtyard ideal for relaxation and gatherings\r\n• High-quality mahogany woodwork throughout the home\r\n• Premium Grohe & Roca fittings\r\n• Fully furnished with imported Turkish furniture\r\nA perfect blend of luxury, space, and contemporary architecture, offering an exclusive lifestyle in one of the most sought-after locations.\r\n📞 For Details & Private Viewing\r\nKHAWAJA ENTERPRISE\r\nBuilder | Contractor | Property Advisor\r\n📞 +92 0317 8222701\r\n📞 +92 0331 2342065\r\n📧 info@khawajaenterprise.net\r\n🌐 khawajaenterprise.net\r\n#KhawajaEnterprise #DHAPhase5 #DHAKarachi #UltraLuxury #KarachiRealEstate #EliteLiving #LuxuryEstate #1000Yards #HighNetWorth #PrimeProperty #dhacitytime #karachi', 220000000.00, 'sell', 'active', NULL, 666.00, 'sqyrd', 0, 0, NULL, 1, 'none', 'none', NULL, '2026-03-11 23:03:39', '2026-04-29 18:09:20'),
(57, 1, NULL, 1, 1, 1, 'DHA LAHORE', NULL, NULL, 24, 'BRAND NEW  HOUSE FOR SALE IN DHA LAHORE', 'brand-new-house-for-sale-in-dha-lahore', 'Mudassar Khokhar - 0301 4806133\r\n💼 Available For Visit 💼\r\n🏬 Prime Location\r\n🛣️ Near Ring Road \r\n🕌 Near Masjid\r\n🛍️ Walking Distance to Shopping Mart & Market\r\n🏥 Close to Medical Store & Labs\r\n🍽️ Nearby Restaurants\r\n🏢 Surrounded by Offices & Companies\r\n🏫 Campus Nearby', 140000000.00, 'sell', 'active', NULL, 2.00, 'marla', 0, 0, NULL, 1, 'none', 'none', NULL, '2026-03-26 21:19:17', '2026-04-29 18:09:20'),
(58, 1, NULL, 1, 1, 1, 'DHA Phase 6 Lahore', NULL, NULL, 25, '2 Kanal Full Furnished House For Sale.', '2-kanal-full-furnished-house-for-sale', 'Luxury | Elegance | Prime Location\r\nListed by: Ikramullah (CEO – HousesStars Real Estate &Construction\r\nCALL 📞 0307-6089887\r\n🏢 Office Address:\r\n57-N Plaza, 4th Floor,\r\nDefence Raya Fairways Commercial\r\nSerious buyers contact now! 📞✨\r\n', 125000000.00, 'sell', 'active', NULL, 2.00, 'kanal', 0, 0, NULL, 1, 'none', 'none', NULL, '2026-03-26 21:37:55', '2026-04-29 18:09:20'),
(59, 1, NULL, 1, 1, 2, 'DHA LAHORE', NULL, NULL, 26, 'BRAND NEW HOUSE FOR SALE IN DHA LAHORE', 'brand-new-house-for-sale-in-dha-lahore-1775006381', '💼 Available For Visit 💼\r\n🏬 Prime Location\r\n🛣️ Near Ring Road \r\n🕌 Near Masjid\r\n🛍️ Walking Distance to Shopping Mart & Market\r\n🏥 Close to Medical Store & Labs\r\n🍽️ Nearby Restaurants\r\n🏢 Surrounded by Offices & Companies\r\n🏫 Campus Nearby', 220000000.00, 'sell', 'active', NULL, 2.00, 'kanal', 0, 0, NULL, 1, 'none', 'none', NULL, '2026-04-01 01:19:41', '2026-04-29 18:09:20'),
(60, 1, NULL, 1, 1, 2, 'DHA LAHORE', NULL, NULL, 26, 'LAVISH NEW HOUSE FOR SALE IN DHA LAHORE', 'lavish-new-house-for-sale-in-dha-lahore', '💼 Available For Visit 💼\r\n🏬 Prime Location\r\n🛣️ Near Ring Road \r\n🕌 Near Masjid\r\n🛍️ Walking Distance to Shopping Mart & Market\r\n🏥 Close to Medical Store & Labs\r\n🍽️ Nearby Restaurants\r\n🏢 Surrounded by Offices & Companies\r\n🏫 Campus Nearby', 240000000.00, 'sell', 'active', NULL, 2.00, 'kanal', 0, 0, NULL, 1, 'none', 'none', NULL, '2026-04-01 01:30:29', '2026-04-29 18:09:20'),
(61, 1, NULL, 1, 1, 3, 'Dha Phasa 8 ', NULL, NULL, 27, 'Experience luxury living in this premium property', 'experience-luxury-living-in-this-premium-property', 'Live steps away from Giga Mall (WTC), banks, and schools in this stunning 1 Kanal residence. Located in a prime, secure sector, it offers the perfect blend of convenience and elegance.\r\n𝗞𝗲𝘆 𝗙𝗲𝗮𝘁𝘂𝗿𝗲𝘀:\r\n● ​5 Spacious Bedrooms with modern attached bathrooms.\r\n● ​Elegant Drawing & Dining Room for formal hosting.\r\n● ​Large TV Lounge & high-end Modern Kitchen.\r\n● ​Functional Extras: Store room & Servant room with bath.\r\n● ​Parking: Secure space for 2 cars.\r\n​This property combines a top-tier location with sophisticated design—an ideal choice for a premium family lifestyle or a high-value investment.\r\n𝗖𝗼𝗻𝘁𝗮𝗰𝘁 𝗳𝗼𝗿 𝗺𝗼𝗿𝗲 𝗱𝗲𝘁𝗮𝗶𝗹𝘀 📞 03306413823', 260000000.00, 'sell', 'active', NULL, 1.00, 'kanal', 0, 0, NULL, 1, 'none', 'none', NULL, '2026-04-03 02:11:12', '2026-04-29 18:09:20'),
(62, 1, NULL, 1, 1, 1, ' DHA Phase 8 – Zone A, Karachi', NULL, NULL, NULL, 'Ultra-Luxury 1,000 Sq. Yards Mansion for Sale', 'ultra-luxury-1-000-sq-yards-mansion-for-sale', '📍 DHA Phase 8 – Zone A, Karachi\r\n🏡 Architect-Designed by Hafiz Sher Ali\r\nStep into a world of elegance and prestige with this magnificent ultra-luxury mansion, designed by renowned architect Hafiz Sher Ali. This architectural masterpiece blends sophisticated design with modern convenience, offering an exceptional lifestyle in one of the most prestigious areas of DHA Phase 8.\r\n✨ Property Highlights:\r\n• 1,000 Sq. Yards – Prime Zone A Location\r\n• Fully Furnished with Premium Finishes\r\n• Solar Power System Installed – Eco-Friendly & Cost Efficient\r\n• High-Speed Elevator / Lift Serving All Floors\r\n🛏 Bedrooms & Living Spaces:\r\n• 6 Spacious Luxury Bedrooms with Designer Fittings\r\n• Attached Modern Bathrooms\r\n• Elegant Living, Dining & Entertainment Areas\r\n• Premium Interior Finishes Throughout\r\n🏝 Resort-Style Outdoor Amenities:\r\n• Private Swimming Pool with Jacuzzi\r\n• Beautiful Landscaped Garden Areas\r\n• Private Terraces & Outdoor Lounging Spaces\r\n🎬 Exclusive Full Basement:\r\nSeparate Entrance — Ideal for both leisure and professional use:\r\n✔️ Office / Workspace\r\n✔️ Executive Sitting Lounge\r\n✔️ Fully Equipped Gym\r\n✔️ Gaming & Entertainment Room\r\nA perfect combination of luxury, comfort, and functionality, making it ideal for families who desire premium living with modern amenities.\r\nDemand: 70 Cr\r\n📞 For ,Details & Site Visit:\r\nKHAWAJA ENTERPRISE\r\nBuilder | Contractor | Property Advisor\r\n📞 +92 0317 8222701\r\n📞 +92 0331 2342065\r\n📧 info@khawajaenterprise.net\r\n🌐 khawajaenterprise.net', 750000000.00, 'sell', 'active', NULL, 1000.00, 'sqyrd', 0, 0, NULL, 1, 'none', 'none', NULL, '2026-04-13 17:20:49', '2026-04-29 18:09:20'),
(63, 1, NULL, 1, 1, 1, 'DHA Phase 8 – Zone A.', NULL, NULL, 29, 'Beautifully constructed house available for sale in a prime location.', 'beautifully-constructed-house-available-for-sale-in-a-prime-location', 'DHA Phase 8 – Zone A, Karachi\r\n🏡 Prime Location | Ultra-Luxury Living\r\nAn exceptional brand-new 6-bedroom luxury residence designed for those who seek elegance, space, and modern comfort. Located in the prestigious Zone A of DHA Phase 8, this home offers a perfect blend of luxury and functionality.\r\n✨ Property Overview:\r\n• Plot Size: 1,000 Sq. Yards\r\n• 6 Spacious Bedrooms with Attached Luxury Bathrooms\r\n• Premium Imported Fixtures & Fittings\r\n• Elegant Layout with Modern Design\r\n🏡 Ground Floor Features:\r\n• Private Swimming Pool with Changing Room\r\n• Spacious Designer Kitchen with Premium Appliances\r\n• High-End Mahogany Wood Finishes\r\n🛏 Bedrooms:\r\n• 6 Large Bedrooms with Modern Attached Baths\r\n• Master Suite with Luxury Ensuite & Bathtub\r\n🎬 Basement & Amenities:\r\n• Huge Family Living Area\r\n• Fully Equipped Private Gym\r\n• State-of-the-Art Home Theatre\r\n🌿 Additional Highlights:\r\n• Modern Lift Installed\r\n• Beautiful Landscaped Green Garden\r\n• Ample Parking Space\r\n• Located in a Prime & Secure Neighborhood\r\n🏠 A perfect combination of luxury, comfort, and convenience — ideal for elite family living in DHA Phase 8.', 750000000.00, 'sell', 'active', NULL, 1000.00, 'sqyrd', 0, 0, NULL, 1, 'none', 'none', NULL, '2026-04-13 17:28:01', '2026-04-29 18:09:20'),
(64, 1, NULL, 1, 1, 1, ' DHA Phase 8 – Zone A,', NULL, NULL, NULL, 'Brand New 1,000 Yards Luxury Bungalow for Sale', 'brand-new-1-000-yards-luxury-bungalow-for-sale', ' DHA Phase 8 – Zone A, Karachi\r\n🏡 Prime Location | Ultra-Luxury Living\r\nAn exceptional brand-new 6-bedroom luxury residence designed for those who seek elegance, space, and modern comfort. Located in the prestigious Zone A of DHA Phase 8, this home offers a perfect blend of luxury and functionality.\r\n✨ Property Overview:\r\n• Plot Size: 1,000 Sq. Yards\r\n• 6 Spacious Bedrooms with Attached Luxury Bathrooms\r\n• Premium Imported Fixtures & Fittings\r\n• Elegant Layout with Modern Design\r\n🏡 Ground Floor Features:\r\n• Private Swimming Pool with Changing Room\r\n• Spacious Designer Kitchen with Premium Appliances\r\n• High-End Mahogany Wood Finishes\r\n🛏 Bedrooms:\r\n• 6 Large Bedrooms with Modern Attached Baths\r\n• Master Suite with Luxury Ensuite & Bathtub\r\n🎬 Basement & Amenities:\r\n• Huge Family Living Area\r\n• Fully Equipped Private Gym\r\n• State-of-the-Art Home Theatre\r\n🌿 Additional Highlights:\r\n• Modern Lift Installed\r\n• Beautiful Landscaped Green Garden\r\n• Ample Parking Space\r\n• Located in a Prime & Secure Neighborhood\r\n🏠 A perfect combination of luxury, comfort, and convenience — ideal for elite family living in DHA Phase 8.\r\n💰 Demand: On call\r\nKHAWAJA ENTERPRISE\r\nBuilder | Contractor | Property Advisor\r\n📞 +92 0317 8222701\r\n📞 +92 0331 2342065\r\n📧 info@khawajaenterprise.net\r\n🌐 khawajaenterprise.net\r\n#KhawajaEnterprise #DHAPhase5 #DHAKarachi #UltraLuxury #KarachiRealEstate #EliteLiving #LuxuryEstate #1000Yards #HighNetWorth #PrimeProperty #dhacitytime #karachi', 800000000.00, 'sell', 'active', NULL, 1000.00, 'sqyrd', 0, 0, NULL, 1, 'none', 'none', NULL, '2026-04-13 17:43:24', '2026-04-29 18:09:20'),
(65, 13, NULL, 1, 1, 1, 'location federal b area block 15', NULL, NULL, 31, 'FOR SALE', 'for-sale', '*Three bedroom with attached bath drawing lounge \r\n*2nd floor with roof \r\n* park facing \r\n*single belt west open \r\n*brand new\r\n* separate meters \r\n* 24 hours electricity water\r\n* location federal b area block 15 \r\n* near ubl complex lucky one mall karachi\r\n* demand 185 lac ', 45000000.00, 'sell', 'active', NULL, 200.00, 'sqyrd', 0, 0, NULL, 0, 'none', 'none', NULL, '2026-04-20 19:38:34', '2026-04-29 18:09:20'),
(66, 13, NULL, 1, 1, 1, 'Khayaban-e-Tanzeem, DHA Phase 5 – Karachi', NULL, NULL, 32, '500 Yards Brand-New Semi-Furnished Luxury Home for Sale', '500-yards-brand-new-semi-furnished-luxury-home-for-sale', 'Experience refined living in this stunning brand-new semi-furnished bungalow, located in one of DHA Phase 5’s most prestigious and well-connected areas.\r\n✨ Key Features:\r\n• Plot Size: 500 Sq. Yards\r\n• 6 Spacious Bedrooms – Designed for comfort, privacy & elegance\r\n• Semi-Furnished with Premium Finishes\r\n• Brand New Construction – Never Lived In\r\n🏠 Additional Highlights:\r\n• Basement Area – Ideal for Gym, Lounge, Play Area or Storage\r\n• Private Home Theatre 🎬 – Enjoy cinema at home\r\n• Contemporary Design & Modern Fittings\r\n• Spacious layout with excellent functionality\r\n📍 Located in a prime and secure neighborhood, offering easy access to main roads, commercial areas, and all essential amenities.\r\n🏠 A perfect choice for families seeking luxury, comfort, and a premium lifestyle in DHA Phase 5.\r\n📞 For Details & Visit:\r\nKhawaja Enterprise\r\n📱 0317-8222701\r\n📱 0331-2342065\r\n📧 info@khawajaenterprise.net\r\n🌐 khawajaenterprise.net\r\n#khawajaenterprise #DHAPhase5 #dhakarachi #ultraluxury #KarachiRealEstate #EliteLiving #luxuryestate #1000yards #HighNetWorth #PrimeProperty #dhacitytime #karachi #viralpost #viralreel', 220000000.00, 'sell', 'active', NULL, 500.00, 'sqyrd', 0, 0, NULL, 0, 'none', 'none', NULL, '2026-04-20 20:16:25', '2026-04-29 18:09:20'),
(67, 1, NULL, 1, 1, 18, 'rwar', NULL, 'admin@gmail.com', 33, 'test', 'test-1778781470', 'test', 232434.00, 'sell', 'deleted', NULL, 94.00, 'marla', 0, 1, NULL, 0, 'none', 'none', NULL, '2026-05-14 17:57:50', '2026-05-14 17:58:29'),
(68, 1, NULL, 1, 16, 18, 'test', NULL, 'admin@gmail.com', 34, 'test', 'test-1778799255', 'test', 1000.00, 'rent', 'deleted', NULL, 12.00, 'marla', 0, 1, NULL, 0, 'none', 'none', NULL, '2026-05-14 22:54:15', '2026-05-15 12:04:48'),
(69, 1, NULL, 1, 1, 1, 'North Nazimabad', NULL, 'admin@gmail.com', 10, 'Test', 'test-1778800282', 'Test', 3000000.00, 'sell', 'deleted', NULL, 200.00, 'sqyrd', 0, 1, NULL, 0, 'none', 'none', NULL, '2026-05-14 23:11:22', '2026-05-14 23:12:09'),
(70, 1, NULL, 1, 1, 1, 'DHA Phase 8', NULL, 'hamza@gmail.com', 1, 'Brand New 500-Yard Luxury Residence | DHA Phase 8 – Zone B, Karachi', 'brand-new-500-yard-luxury-residence-dha-phase-8-zone-b-karachi-1778846674', 'Introducing a truly exceptional home for those who demand nothing but the finest.\r\nThis stunning west-open masterpiece spans 500 square yards and offers a lifestyle of effortless elegance — from its grand modern elevation to its resort-inspired private swimming pool.\r\n✦ 6 Bedrooms across Basement, Ground & First Floor\r\n✦ Private Swimming Pool\r\n✦ Fully Developed Basement — Lounge / Gym / Entertainment\r\n✦ West-Open Orientation | Abundant Natural Light\r\n✦ Spacious Drawing, Dining & Family Lounges\r\n✦ Contemporary Kitchen with Premium Fixtures\r\n✦ High-End Finishes Throughout\r\n✦ Ample Covered Parking\r\nDHA Phase 8 – Zone B is one of Karachi\'s most prestigious and sought-after addresses — offering security, infrastructure, and unmatched long-term value.\r\nThis is not just a home. It is a legacy.', 160000000.00, 'sell', 'active', NULL, 500.00, 'sqyrd', 0, 1, NULL, 0, 'none', 'none', NULL, '2026-05-15 12:04:34', '2026-05-15 12:05:05'),
(71, 1, NULL, 1, 1, 1, 'Dha phase 8', NULL, 'TALHA@gmail.com', 1, 'FOR SALE – 500 YARDS BRAND NEW LUXURY BUNGALOW', 'for-sale-500-yards-brand-new-luxury-bungalow-1778847287', 'Prime Location | DHA Phase 8, Karachi\r\nExperience premium living in this beautifully designed, brand new bungalow located in the heart of Phase 8 DHA.\r\n🏡 Property Features:\r\nSpacious 1+2+3 Bedroom Layout (Total 6 Bedrooms)\r\nDouble Height Grand Entrance Foyer\r\nKitchen on Each Floor\r\nCan be used as a Multi-Family Home\r\n✨ Premium Finishes & Design:\r\nImported Aluminium Windows with Double Glazing (Energy Efficient)\r\nElegant Italian Tiles & Imported SPC Flooring\r\nModern Italian Kitchen\r\nHigh-End Grohe Sanitary Fittings\r\nSemi-Furnished\r\n🧠 Smart Living:\r\nSmart Home Automation System\r\nSmart Curtains (Option Available)\r\n🧘 Luxury Amenities:\r\nDedicated Spa Area with:\r\nCold Plunge\r\nHot Tub\r\nSteam Room\r\nMulti-Purpose Room (Ideal for Home Theatre / Gym)\r\nAdditional Features:\r\n2 Maid Rooms (Roof + Basement)\r\nThoughtfully Designed Layout for Comfort & Privacy.\r\nFor more details call or Whatsapp us:\r\nCon.03092187323\r\nTalha Memon', 210000000.00, 'sell', 'active', NULL, 500.00, 'sqyrd', 0, 1, NULL, 0, 'none', 'none', NULL, '2026-05-15 12:14:47', '2026-05-15 12:34:56'),
(72, 1, NULL, 1, 2, 1, 'Bath Island', NULL, 'AADESH@gmail.com', 35, 'LUXURY APARTMENT AVAILABLE FOR SELL *Royal Luxuria*', 'luxury-apartment-available-for-sell-royal-luxuria--1778849929', 'LUXURY APARTMENT AVAILABLE FOR SELL\r\n*Royal Luxuria*\r\n🛏️ 3 Bed DD | Attached Baths\r\n✨ Spacious, bright & well-planned layout\r\n🛗 Modern Lifts | ⚡ Standby Generator\r\n🚘 Reserved Parking | 🔒 24/7 Security & CCTV\r\n💧 Line Water (24/7)\r\n🏋️ Gym | 🧸 Kids Play Area\r\n🎮 Indoor Gaming | 🕌 Masjid\r\n🛋️ Elegant Waiting Area\r\n📍Location: Bath Island, Karachi\r\nDemand📞\r\nFor Further Details & Visit \r\n📱0334-2245228\r\nAadesh Parwani - SV Properties', 60000000.00, 'sell', 'active', NULL, 1350.00, 'sqft', 0, 1, NULL, 0, 'none', 'none', NULL, '2026-05-15 12:58:49', '2026-05-15 12:59:09'),
(73, 1, NULL, 1, 1, 4, 'Bahria Town Rawalpindi Phase 8', NULL, 'Ads@gmail.com', 36, '10 Marla Ultra Designer House For Sale', '10-marla-ultra-designer-house-for-sale-1779012095', 'Double Unit House\r\n✅ 5 Spacious Bedrooms with Attached Baths\r\n✅ Modern Interior & Luxury Finishing\r\n📍 Bahria Town Rawalpindi Phase 8\r\n💰 Asking Price: 390 Lac\r\n📞 For More Details & Visit:\r\n03332235123\r\n03306413823', 40000000.00, 'sell', 'active', NULL, 10.00, 'marla', 0, 1, NULL, 0, 'none', 'none', NULL, '2026-05-17 10:01:35', '2026-05-17 10:02:12'),
(74, 1, NULL, 1, 1, 2, 'DHA Lahore', NULL, 'Elegant@gmail.com', 26, '22 Marla Modern Design House For Sale DHA_Lahore', '22-marla-modern-design-house-for-sale-dha-lahore-1779013637', '22-Marla #Modern_Design_House For Sale #DHA_Lahore\r\nContact : 0321 4813092\r\n22-Marla  House for sale in #DHA_Lahore\r\nPost I’d : 6108\r\nFor more details\r\nCall: 0321 4813092\r\n#elegantproperties\r\n#DHA_Lahore #DHAHouse #DHALiving #DHABuyers #LuxuryHome #DHALahore\r\n#DHALuxuryHome\r\n#HouseForSaleDHA #DHAProperty\r\n#dreamhomedha', 140000000.00, 'sell', 'active', NULL, 22.00, 'marla', 0, 1, NULL, 0, 'none', 'none', NULL, '2026-05-17 10:27:17', '2026-05-17 10:27:58'),
(75, 13, NULL, 1, 1, 1, 'North Nazimabad', NULL, 'Harisali@gmail.com', 10, 'House Available for sell', 'house-available-for-sell-1780343551', 'House Availabl for sell. House Availabl for sell.', 35000000.00, 'sell', 'active', NULL, 400.00, 'sqyrd', 0, 1, NULL, 0, 'none', 'none', NULL, '2026-06-01 19:52:31', '2026-06-01 20:00:11'),
(76, 1, NULL, 1, 1, 1, 'Dha phase 8', NULL, 'admin@gmail.com', 1, 'LUMA — An Architectural Masterpiece in DHA Phase 8, Karachi', 'luma-an-architectural-masterpiece-in-dha-phase-8-karachi-1781220513', '✨ Where contemporary design meets timeless luxury.\r\nIntroducing LUMA, a magnificent 1000 Sq. Yards luxury residence nestled in one of the most prestigious and serene neighborhoods of DHA Phase 8. Designed for discerning homeowners who appreciate elegance, space, and refined living.\r\n✨ Property Highlights\r\n📐 Plot Size: 1000 Sq. Yards\r\n🛏️ 6 Luxurious Bedrooms (2+4 Planning)\r\n2 Bedrooms on Ground Floor\r\n4 Bedrooms on First Floor\r\nDesigner Attached Bathrooms\r\nSpacious Walk-In Closets\r\n🛋️ Grand Drawing & Dining Areas\r\nPerfectly crafted for formal entertaining and sophisticated gatherings.\r\n📺 Expansive Family Lounges\r\nLarge TV lounges on both levels featuring modern layouts and abundant natural light.\r\n🏛️ Versatile Full Basement\r\nIdeal for:\r\n🎬 Private Home Theatre\r\n🏋️ Personal Gym\r\n🍸 Executive Lounge\r\n🎮 Entertainment Zone\r\n🍽️ Modern Designer Kitchen\r\n🚗 Ample Car Parking\r\n🌿 Peaceful & Elite Neighborhood\r\n🏡 Contemporary Architecture with Premium Finishes Throughout\r\n💎 A residence that seamlessly combines luxury, comfort, and functionality—offering an exceptional lifestyle in one of Karachi\'s most sought-after addresses.\r\n📍 DHA Phase 8, Karachi\r\n💰 Demand: On Call\r\n📞 For Details & Private Viewing:\r\nKHAWAJA ENTERPRISE\r\nBuilder | Contractor | Property Advisor\r\n📱 0317-8222701\r\n📱 0331-2342065\r\n📧 info@khawajaenterprise.net\r\n🌐 khawajaenterprise.net', 220000000.00, 'sell', 'active', NULL, 1000.00, 'sqyrd', 0, 1, NULL, 0, 'none', 'none', NULL, '2026-06-11 23:28:33', '2026-06-11 23:28:33'),
(77, 13, NULL, 1, 16, 1, '', NULL, 'Harisali@gmail.com', NULL, 'FOR SALE — 666 SQ. YD. ULTRA-LUXURY DESIGNER VILLA 📍 DHA Phase 8, Karachi', 'for-sale-666-sq-yd-ultra-luxury-designer-villa-dha-phase-8-karachi-1781221648', ' FOR SALE — 666 SQ. YD. ULTRA-LUXURY DESIGNER VILLA\r\n📍 DHA Phase 8, Karachi\r\nExperience elite living in this 11,500 Sq. Ft. fully furnished architectural masterpiece by Ground Zero Contractors, crafted with exceptional attention to detail, luxury finishes, and state-of-the-art smart living features.\r\n✨ Property Highlights:\r\n🛏️ 4+1 Spacious Luxury Bedrooms\r\n🛁 5.5 Designer Bathrooms\r\n🏛️ Elegant Portuguese Marble Flooring\r\n🚪 Premium Walnut Veneer Doors\r\n🍽️ Designer Kitchen with Imported Smeg Appliances\r\n📚 Dedicated Study Room with Travertine Flooring\r\n🎵 Fully Automated Smart Home by Control4 (UK)\r\n🔊 Integrated Premium Sound System\r\n👨‍🍳 Greasy Kitchen for Practical Luxury Living\r\n🛗 Dumb Waiter System Installed\r\n👨‍🔧 Dedicated Staff Accommodation for 8+ Staff Members\r\n💎 A rare combination of sophistication, automation, comfort, and timeless luxury — designed for those who appreciate world-class living.\r\n📍 Prime Location – DHA Phase 8, Karachi\r\n📞 For Further Details & Private Viewing:\r\nKHAWAJA ENTERPRISE\r\nBuilder | Contractor | Property Advisor\r\n📱 +92 317 8222701\r\n📱 +92 331 2342065\r\n📧 info@khawajaenterprise.net', 280000000.00, 'sell', 'active', NULL, 666.00, 'sqyrd', 0, 1, NULL, 0, 'none', 'none', NULL, '2026-06-11 23:47:28', '2026-07-31 20:34:27'),
(78, 13, NULL, 1, 1, 1, 'Dha Phase 8', NULL, 'info@khawajaenterprise.net', 1, 'FOR SALE — 666 SQ. YD. ULTRA-LUXURY DESIGNER VILLA', 'for-sale-666-sq-yd-ultra-luxury-designer-villa-1781222097', 'FOR SALE — 666 SQ. YD. ULTRA-LUXURY DESIGNER VILLA\r\n📍 DHA Phase 8, Karachi\r\nExperience elite living in this 11,500 Sq. Ft. fully furnished architectural masterpiece by Ground Zero Contractors, crafted with exceptional attention to detail, luxury finishes, and state-of-the-art smart living features.\r\n✨ Property Highlights:\r\n🛏️ 4+1 Spacious Luxury Bedrooms\r\n🛁 5.5 Designer Bathrooms\r\n🏛️ Elegant Portuguese Marble Flooring\r\n🚪 Premium Walnut Veneer Doors\r\n🍽️ Designer Kitchen with Imported Smeg Appliances\r\n📚 Dedicated Study Room with Travertine Flooring\r\n🎵 Fully Automated Smart Home by Control4 (UK)\r\n🔊 Integrated Premium Sound System\r\n👨‍🍳 Greasy Kitchen for Practical Luxury Living\r\n🛗 Dumb Waiter System Installed\r\n👨‍🔧 Dedicated Staff Accommodation for 8+ Staff Members\r\n💎 A rare combination of sophistication, automation, comfort, and timeless luxury — designed for those who appreciate world-class living.\r\n📍 Prime Location – DHA Phase 8, Karachi\r\n📞 For Further Details & Private Viewing:\r\nKHAWAJA ENTERPRISE\r\nBuilder | Contractor | Property Advisor\r\n📱 +92 317 8222701\r\n📱 +92 331 2342065\r\n📧 info@khawajaenterprise.net', 280000000.00, 'sell', 'active', NULL, 666.00, 'sqyrd', 0, 1, NULL, 0, 'none', 'none', NULL, '2026-06-11 23:54:57', '2026-06-12 00:35:16'),
(79, 36, NULL, 1, 16, 1, 'Naya Nazimabad', NULL, 'amna56hameed@gmail.com', 12, 'FOR RENT | NAYA NAZIMABAD 🏠  120 Sq Yards & 160 Sq Yards Houses Available for Reny', 'for-rent-naya-nazimabad-120-sq-yards-160-sq-yards-houses-available-for-reny-79', 'FOR RENT | NAYA NAZIMABAD 🏠\r\n\r\n120 Sq Yards & 160 Sq Yards Houses Available for Rent\r\n\r\n**Key Features:**\r\n✓ Secure Gated Community \r\n✓ 24/7 Security & CCTV\r\n✓ Wide Roads | Park Facing Options \r\n✓ Near Masjid, School & Market\r\n✓ Modern Construction | Ready to Move\r\n\r\n**Ideal For:** Families \r\n\r\n**Contact for Visit & Rent Details:**\r\n📞 03193895042\r\n\r\nSerious parties only. Direct owner.', 75000.00, 'sell', 'active', NULL, 120.00, 'sqyrd', 0, 1, NULL, 0, 'none', 'none', NULL, '2026-07-05 12:05:04', '2026-07-31 20:22:18'),
(80, 1, NULL, 1, 1, 4, 'Bahria Town Phase 8', NULL, '', 37, 'A1 Properties Bahria Town Phase 8 Rawalpindi', 'a1-properties-bahria-town-phase-8-rawalpindi-1785529191', '5 Marla Fully Designer House for Sale | \r\nA1 Properties Bahria Town Phase 8 Rawalpindi  \r\n📞 For More Information & Visit:03306413823\r\n✨ Property Features:\r\n* 3 Spacious Master Bedrooms with Attached Bathrooms\r\n* Stylish Modern Kitchen\r\n* Beautiful Drawing Room\r\n* Spacious TV Lounge\r\n* Double Height TV Lounge\r\n* Elegant Chandeliers Installed\r\n* 1 Car Parking\r\n* Solid Construction with Premium Finishing\r\n* Excellent Designer Interior\r\n* Walking Distance to Park & Commercial Area', 27000000.00, 'sell', 'active', NULL, 5.00, 'marla', 0, 1, NULL, 0, 'none', 'none', NULL, '2026-07-31 20:19:51', '2026-07-31 20:19:51'),
(81, 1, NULL, 1, 1, 2, 'DHA Phase 6 Lahore', NULL, '', 38, 'At Prime Location of DHA Phase 6 Lahore', 'at-prime-location-of-dha-phase-6-lahore-1785529644', '1 Kanal Most Luxurious Fully Furnished Designer House At Prime Location of DHA Phase 6 Lahore | Near to Dolmen Mall | 17.90 Crore', 180000000.00, 'sell', 'active', NULL, 1.00, 'kanal', 0, 1, NULL, 0, 'none', 'none', NULL, '2026-07-31 20:27:24', '2026-07-31 20:27:24'),
(82, 1, NULL, 1, 1, 4, 'Bahria Town Phase 8, Rawalpindi', NULL, '', 39, 'Billal Block, near Future World School, Bahria Town Phase 8, Rawalpindi', 'billal-block-near-future-world-school-bahria-town-phase-8-rawalpindi-1785530026', '8 Marla House for Sale – Bahria Town Phase 8, Rawalpindi\r\nLocation: Billal Block, near Future World School, Bahria Town Phase 8, Rawalpindi\r\nProperty Details:\r\n- 8 Marla Used House\r\n- 4 Marla Extra Back Lawn\r\n- 5 Spacious Bedrooms\r\n- Double Unit\r\n- 10 KVA Solar System Installed\r\n- House Completed in 2019\r\nDemand: PKR 3.25 Crore\r\nFor More Information or Visit:\r\n📞 0330-6413823', 32500000.00, 'sell', 'active', NULL, 8.00, 'marla', 0, 1, NULL, 0, 'none', 'none', NULL, '2026-07-31 20:33:46', '2026-07-31 20:33:46');

-- --------------------------------------------------------

--
-- Table structure for table `property_amenity_relation`
--

CREATE TABLE `property_amenity_relation` (
  `property_id` int(11) NOT NULL,
  `amenity_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `property_amenity_values`
--

CREATE TABLE `property_amenity_values` (
  `property_id` bigint(20) UNSIGNED NOT NULL,
  `amenity_field_id` int(11) NOT NULL,
  `value` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `property_amenity_values`
--

INSERT INTO `property_amenity_values` (`property_id`, `amenity_field_id`, `value`) VALUES
(21, 2, '1'),
(21, 3, '2'),
(21, 4, '2'),
(21, 6, '0'),
(21, 7, '0'),
(22, 2, '1'),
(22, 3, '2'),
(22, 4, '2'),
(22, 6, '0'),
(22, 7, '0'),
(23, 2, '1'),
(23, 3, '3'),
(23, 4, '2'),
(23, 6, '0'),
(23, 7, '0'),
(26, 2, '1'),
(26, 3, '2'),
(26, 4, '2'),
(26, 6, '0'),
(26, 7, '0'),
(27, 2, '2'),
(27, 3, '4'),
(27, 4, '4'),
(27, 6, '0'),
(27, 7, '0'),
(28, 2, '1'),
(28, 3, '2'),
(28, 4, '2'),
(28, 6, '0'),
(28, 7, '0'),
(30, 2, '2'),
(30, 3, '2'),
(30, 4, '2'),
(30, 6, '0'),
(30, 7, '0'),
(31, 2, '2'),
(31, 3, '2'),
(31, 4, '2'),
(31, 6, '0'),
(31, 7, '0'),
(32, 2, '1'),
(32, 3, '3'),
(32, 4, '3'),
(32, 6, '0'),
(32, 7, '0'),
(33, 2, '2'),
(33, 3, '2'),
(33, 4, '2'),
(33, 6, '0'),
(33, 7, '0'),
(34, 2, '2'),
(34, 3, '5'),
(34, 4, '5'),
(34, 6, '0'),
(34, 7, '0'),
(35, 6, '0'),
(35, 7, '0'),
(37, 2, '2'),
(37, 3, '6'),
(37, 4, '5'),
(37, 6, '0'),
(37, 7, '0'),
(38, 2, '4'),
(38, 3, '5'),
(38, 4, '4'),
(38, 6, '0'),
(38, 7, '0'),
(39, 2, '2'),
(39, 3, '4'),
(39, 4, '4'),
(39, 6, '0'),
(39, 7, '0'),
(40, 2, '2'),
(40, 3, '4'),
(40, 4, '4'),
(40, 6, '0'),
(40, 7, '0'),
(41, 3, '4'),
(41, 4, '2'),
(41, 6, '0'),
(41, 7, '0'),
(42, 2, '2'),
(42, 3, '3'),
(42, 4, '3'),
(42, 6, '0'),
(42, 7, '0'),
(43, 2, '2'),
(43, 3, '4'),
(43, 4, '3'),
(43, 6, '0'),
(43, 7, '0'),
(44, 6, '0'),
(44, 7, '0'),
(45, 2, '2'),
(45, 3, '4'),
(45, 4, '3'),
(45, 6, '0'),
(45, 7, '0'),
(46, 3, '5'),
(46, 4, '5'),
(46, 6, '0'),
(46, 7, '0'),
(47, 2, '2'),
(47, 3, '4'),
(47, 4, '2'),
(47, 6, '0'),
(47, 7, '0'),
(48, 2, '2'),
(48, 3, '3'),
(48, 4, '3'),
(48, 6, '0'),
(48, 7, '0'),
(49, 3, '5'),
(49, 4, '5'),
(49, 6, '0'),
(49, 7, '0'),
(50, 3, '4'),
(50, 4, '4'),
(50, 6, '0'),
(50, 7, '0'),
(51, 2, '4'),
(51, 3, '6'),
(51, 4, '4'),
(51, 6, '0'),
(51, 7, '0'),
(52, 2, '2'),
(52, 3, '4'),
(52, 4, '4'),
(52, 6, '0'),
(52, 7, '0'),
(53, 2, '4'),
(53, 3, '6'),
(53, 4, '6'),
(53, 6, '0'),
(53, 7, '0'),
(54, 2, '2'),
(54, 3, '4'),
(54, 4, '4'),
(54, 6, '0'),
(54, 7, '0'),
(55, 2, '4'),
(55, 3, '7'),
(55, 4, '9'),
(55, 6, '0'),
(55, 7, '0'),
(56, 2, '4'),
(56, 3, '5'),
(56, 4, '6'),
(56, 6, '0'),
(56, 7, '0'),
(57, 2, '4'),
(57, 3, '6'),
(57, 4, '6'),
(57, 6, '0'),
(57, 7, '0'),
(58, 2, '4'),
(58, 3, '6'),
(58, 4, '5'),
(58, 6, '0'),
(58, 7, '0'),
(59, 2, '2'),
(59, 3, '6'),
(59, 4, '5'),
(59, 6, '0'),
(59, 7, '0'),
(60, 2, '2'),
(60, 3, '6'),
(60, 4, '5'),
(60, 6, '0'),
(60, 7, '0'),
(61, 2, '2'),
(61, 3, '5'),
(61, 4, '6'),
(61, 6, '0'),
(61, 7, '0'),
(62, 2, '2'),
(62, 3, '6'),
(62, 4, '6'),
(62, 6, '0'),
(62, 7, '0'),
(63, 2, '2'),
(63, 3, '6'),
(63, 4, '6'),
(63, 6, '0'),
(63, 7, '0'),
(64, 2, '2'),
(64, 3, '6'),
(64, 4, '6'),
(64, 6, '0'),
(64, 7, '0'),
(65, 2, '1'),
(65, 3, '4'),
(65, 4, '4'),
(65, 6, '0'),
(65, 7, '0'),
(66, 2, '2'),
(66, 3, '6'),
(66, 4, '6'),
(66, 6, '0'),
(66, 7, '0'),
(67, 3, '2'),
(67, 4, '3'),
(68, 1, '2003'),
(68, 3, '2'),
(68, 4, '2'),
(69, 3, '4'),
(69, 4, '2'),
(70, 3, '5'),
(70, 4, '5'),
(71, 3, '6'),
(71, 4, '6'),
(72, 3, '3'),
(72, 4, '3'),
(73, 3, '5'),
(73, 4, '5'),
(74, 3, '6'),
(74, 4, '6'),
(75, 3, '4'),
(75, 4, '4'),
(76, 3, '6'),
(76, 4, '7+'),
(77, 3, '6'),
(77, 4, '6'),
(78, 3, '6'),
(78, 4, '7'),
(79, 3, '3'),
(79, 4, '2'),
(80, 3, '3'),
(80, 4, '4'),
(81, 3, '6'),
(81, 4, '6'),
(82, 3, '4'),
(82, 4, '4');

-- --------------------------------------------------------

--
-- Table structure for table `property_categories`
--

CREATE TABLE `property_categories` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `slug` varchar(100) NOT NULL,
  `icon_class` varchar(50) DEFAULT NULL,
  `sort_order` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `property_categories`
--

INSERT INTO `property_categories` (`id`, `name`, `slug`, `icon_class`, `sort_order`) VALUES
(1, 'Home', 'home', 'ph-house', 1),
(2, 'Plots', 'plots', 'ph-map-trifold', 2),
(3, 'Commercial', 'commercial', 'ph-buildings', 3);

-- --------------------------------------------------------

--
-- Table structure for table `property_contacts`
--

CREATE TABLE `property_contacts` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `property_id` bigint(20) UNSIGNED NOT NULL,
  `phone_number` varchar(20) NOT NULL,
  `label` varchar(50) DEFAULT 'Mobile'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `property_contacts`
--

INSERT INTO `property_contacts` (`id`, `property_id`, `phone_number`, `label`) VALUES
(1, 21, '+923226392692', 'Primary'),
(2, 22, '03001234567', 'Primary'),
(3, 23, '03456789123', 'Primary'),
(4, 26, '03001234567', 'Primary'),
(5, 27, '03451234567', 'Primary'),
(6, 28, '03001233214', 'Primary'),
(7, 30, '03002312268', 'Primary'),
(8, 31, '03002312321', 'Primary'),
(9, 32, '03038611893', 'Primary'),
(10, 33, '03038611893', 'Primary'),
(11, 34, '03362175091', 'Primary'),
(12, 35, '03362175091', 'Primary'),
(13, 37, '030023212245', 'Primary'),
(14, 38, '03002312267', 'Primary'),
(15, 39, '0345457891', 'Primary'),
(16, 40, '03212314576', 'Primary'),
(17, 41, '03457863459', 'Primary'),
(18, 42, '03213456324', 'Primary'),
(19, 43, '032145364321', 'Primary'),
(20, 44, '03458674523', 'Primary'),
(21, 45, '03452314537', 'Primary'),
(22, 46, '03333458003', 'Primary'),
(23, 47, '03212312258', 'Primary'),
(24, 48, '03180252772', 'Primary'),
(25, 49, '03132286920', 'Primary'),
(26, 50, '03362175091', 'Primary'),
(27, 51, '0301 4806133', 'Primary'),
(28, 52, '0301-2191274', 'Primary'),
(29, 53, '0321345679', 'Primary'),
(30, 54, ' 03247936559', 'Primary'),
(31, 55, '+92 300 0520897', 'Primary'),
(32, 56, '+92 0331 2342065', 'Primary'),
(33, 57, '+92-3014289340', 'Primary'),
(34, 58, '0307-6089887', 'Primary'),
(35, 59, '0301 4806133', 'Primary'),
(36, 60, '0301 4806133', 'Primary'),
(37, 61, ' 03306413823', 'Primary'),
(38, 62, '+92 0317 8222701', 'Primary'),
(39, 63, '+92 0317 8222701', 'Primary'),
(40, 64, '+92 0317 8222701', 'Primary'),
(41, 65, '03032187145', 'Primary'),
(42, 66, '03171066689', 'Primary'),
(43, 67, '24354657657', 'Mobile'),
(44, 68, '01234657913', 'Mobile'),
(45, 69, '03038611893', 'Mobile'),
(46, 70, '03072468987', 'Mobile'),
(47, 71, '03092187323', 'Mobile'),
(48, 72, '0334-2245228', 'Mobile'),
(49, 73, '03332235123', 'Mobile'),
(50, 74, '03214813092', 'Mobile'),
(51, 75, '03240883213', 'Primary'),
(52, 76, '0317-8222701', 'Mobile'),
(53, 77, '+92 317 8222701', 'Primary'),
(54, 78, '+92 317 8222701', 'Primary'),
(56, 80, '03306413823', 'Mobile'),
(57, 79, '+923193895042', 'Mobile'),
(58, 81, '0300 1030488', 'Mobile'),
(59, 82, '0330-6413823', 'Mobile');

-- --------------------------------------------------------

--
-- Table structure for table `property_documents`
--

CREATE TABLE `property_documents` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `property_id` bigint(20) UNSIGNED NOT NULL,
  `document_type` varchar(100) NOT NULL,
  `document_url` varchar(512) NOT NULL,
  `status` enum('pending','verified','rejected') DEFAULT 'pending',
  `uploaded_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `property_images`
--

CREATE TABLE `property_images` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `property_id` bigint(20) UNSIGNED NOT NULL,
  `image_url` varchar(512) NOT NULL,
  `is_main` tinyint(1) DEFAULT 0,
  `sort_order` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `property_images`
--

INSERT INTO `property_images` (`id`, `property_id`, `image_url`, `is_main`, `sort_order`) VALUES
(51, 21, 'uploads/properties/prop_695d7622d9b407.95110764.jpg', 1, 0),
(52, 21, 'uploads/properties/prop_695d7622d9fa17.83666484.jpg', 0, 0),
(53, 21, 'uploads/properties/prop_695d7622da0f96.92436540.jpg', 0, 0),
(54, 22, 'uploads/properties/prop_696133df062881.08350720.jpg', 1, 0),
(55, 23, 'uploads/properties/prop_69613f4bd74182.50945423.jpg', 1, 0),
(61, 26, 'uploads/properties/prop_6965fe2c145524.64847881.jpg', 1, 0),
(62, 26, 'uploads/properties/prop_6965fe2c149d94.43367998.jpg', 0, 0),
(63, 26, 'uploads/properties/prop_6965fe2c14d594.19925743.jpg', 0, 0),
(64, 27, 'uploads/properties/prop_6966047916bc83.22539883.jpg', 1, 0),
(65, 27, 'uploads/properties/prop_69660479172614.58785661.jpg', 0, 0),
(66, 27, 'uploads/properties/prop_696604791749b5.75770690.jpg', 0, 0),
(67, 28, 'uploads/properties/prop_69675614c3c477.11719402.jpg', 1, 0),
(68, 28, 'uploads/properties/prop_69675614c42239.38923679.jpg', 0, 0),
(69, 28, 'uploads/properties/prop_69675614c44779.95513833.jpg', 0, 0),
(70, 30, 'uploads/properties/prop_696b3b782d92e8.85918661.jpg', 1, 0),
(71, 31, 'uploads/properties/prop_696b3dbe6b8a19.90764780.jpg', 1, 0),
(72, 32, 'uploads/properties/prop_696b4ffc796643.22101658.jpeg', 1, 0),
(73, 32, 'uploads/properties/prop_696b4ffc798b25.71683051.jpeg', 0, 0),
(74, 32, 'uploads/properties/prop_696b4ffc79d4f5.98933011.jpeg', 0, 0),
(75, 32, 'uploads/properties/prop_696b4ffc79f347.72583021.jpeg', 0, 0),
(76, 32, 'uploads/properties/prop_696b4ffc7a1416.23764635.jpeg', 0, 0),
(77, 32, 'uploads/properties/prop_696b4ffc7a34c4.08355024.jpeg', 0, 0),
(78, 32, 'uploads/properties/prop_696b4ffc7aab89.27899203.jpeg', 0, 0),
(79, 32, 'uploads/properties/prop_696b4ffc7b11a6.62638108.jpeg', 0, 0),
(80, 32, 'uploads/properties/prop_696b4ffc7b7a25.70468615.jpeg', 0, 0),
(81, 32, 'uploads/properties/prop_696b4ffc7bd5b5.29626938.jpeg', 0, 0),
(82, 32, 'uploads/properties/prop_696b4ffc7c2730.72254701.jpeg', 0, 0),
(83, 32, 'uploads/properties/prop_696b4ffc7c75d3.22304903.jpeg', 0, 0),
(84, 32, 'uploads/properties/prop_696b4ffc7ce3a9.16404997.jpeg', 0, 0),
(85, 32, 'uploads/properties/prop_696b4ffc7d5803.58582016.jpeg', 0, 0),
(86, 32, 'uploads/properties/prop_696b4ffc7df424.95096860.jpeg', 0, 0),
(87, 32, 'uploads/properties/prop_696b4ffc7f2859.47927902.jpeg', 0, 0),
(88, 33, 'uploads/properties/prop_696b79d175c324.47841857.jpeg', 1, 0),
(89, 33, 'uploads/properties/prop_696b79d1766124.60432769.jpeg', 0, 0),
(90, 33, 'uploads/properties/prop_696b79d1769f73.49541244.jpeg', 0, 0),
(91, 33, 'uploads/properties/prop_696b79d176c971.38582507.jpeg', 0, 0),
(92, 33, 'uploads/properties/prop_696b79d176fa02.38713186.jpeg', 0, 0),
(93, 33, 'uploads/properties/prop_696b79d1772ae3.01924577.jpeg', 0, 0),
(94, 33, 'uploads/properties/prop_696b79d177ca71.98592550.jpeg', 0, 0),
(95, 33, 'uploads/properties/prop_696b79d1786b58.39458771.jpeg', 0, 0),
(96, 33, 'uploads/properties/prop_696b79d1790297.41782783.jpeg', 0, 0),
(97, 33, 'uploads/properties/prop_696b79d1797965.01565584.jpeg', 0, 0),
(98, 33, 'uploads/properties/prop_696b79d179ec00.02933722.jpeg', 0, 0),
(99, 33, 'uploads/properties/prop_696b79d17a75d4.85524236.jpeg', 0, 0),
(100, 33, 'uploads/properties/prop_696b79d17b13c8.95204755.jpeg', 0, 0),
(101, 33, 'uploads/properties/prop_696b79d17bafb6.47797344.jpeg', 0, 0),
(102, 33, 'uploads/properties/prop_696b79d17c51f5.03417974.jpeg', 0, 0),
(103, 33, 'uploads/properties/prop_696b79d17dc305.04481543.jpeg', 0, 0),
(104, 34, 'uploads/properties/prop_696f8d30533aa4.45452971.jpg', 1, 0),
(105, 34, 'uploads/properties/prop_696f8d30536e51.06468602.jpg', 0, 0),
(106, 34, 'uploads/properties/prop_696f8d3053a054.05827631.jpg', 0, 0),
(107, 34, 'uploads/properties/prop_696f8d3053c182.59484012.jpg', 0, 0),
(108, 34, 'uploads/properties/prop_696f8d3053df62.05995709.jpg', 0, 0),
(109, 35, 'uploads/properties/prop_696ff8aa0725f9.96958027.jpg', 1, 0),
(111, 37, 'uploads/properties/prop_69710956e7cd14.09555402.jpeg', 1, 0),
(112, 37, 'uploads/properties/prop_69710956e7fd58.21660479.jpeg', 0, 0),
(113, 37, 'uploads/properties/prop_69710956e889f3.54345962.jpeg', 0, 0),
(114, 37, 'uploads/properties/prop_69710956e8fa43.38559474.jpeg', 0, 0),
(115, 37, 'uploads/properties/prop_69710956e9f4e3.08856791.jpeg', 0, 0),
(116, 37, 'uploads/properties/prop_69710956ea24a1.90248553.jpeg', 0, 0),
(117, 38, 'uploads/properties/prop_69710ca3b9a4a2.13082886.jpeg', 1, 0),
(118, 38, 'uploads/properties/prop_69710ca3b9d042.89428378.jpeg', 0, 0),
(119, 38, 'uploads/properties/prop_69710ca3ba7db1.80695819.jpeg', 0, 0),
(120, 38, 'uploads/properties/prop_69710ca3bafcb6.90819248.jpeg', 0, 0),
(121, 38, 'uploads/properties/prop_69710ca3bb8ac3.75899384.jpeg', 0, 0),
(122, 38, 'uploads/properties/prop_69710ca3bbf9d0.93938901.jpeg', 0, 0),
(123, 39, 'uploads/properties/prop_69710ea3b79181.11595400.jpeg', 1, 0),
(124, 39, 'uploads/properties/prop_69710ea3b83a55.32650224.jpeg', 0, 0),
(125, 39, 'uploads/properties/prop_69710ea3b8d8c6.41466143.jpeg', 0, 0),
(126, 39, 'uploads/properties/prop_69710ea3b9b234.14545042.jpeg', 0, 0),
(127, 39, 'uploads/properties/prop_69710ea3bac169.30515479.jpeg', 0, 0),
(128, 40, 'uploads/properties/prop_697114e06b50e9.50676391.jpeg', 1, 0),
(129, 41, 'uploads/properties/prop_6971158f7178d7.98298897.jpeg', 1, 0),
(130, 42, 'uploads/properties/prop_697116caa77220.13511609.jpg', 1, 0),
(131, 43, 'uploads/properties/prop_697118621ae482.09293149.jpg', 1, 0),
(132, 44, 'uploads/properties/prop_69711919f2c7f2.82388308.jpg', 1, 0),
(133, 45, 'uploads/properties/prop_69711a77b8a619.90731449.jpg', 1, 0),
(134, 46, 'uploads/properties/prop_697239a2d7af39.00171240.jpg', 1, 0),
(135, 46, 'uploads/properties/prop_697239a2d7e365.53789213.jpg', 0, 0),
(136, 46, 'uploads/properties/prop_697239a2d80b22.65702452.jpg', 0, 0),
(137, 46, 'uploads/properties/prop_697239a2d832e5.44236855.jpg', 0, 0),
(138, 46, 'uploads/properties/prop_697239a2d85f38.68977240.jpg', 0, 0),
(139, 46, 'uploads/properties/prop_697239a2d89b96.84484667.jpg', 0, 0),
(140, 46, 'uploads/properties/prop_697239a2d8bec1.24730617.jpg', 0, 0),
(141, 46, 'uploads/properties/prop_697239a2d8dad6.35640157.jpg', 0, 0),
(142, 46, 'uploads/properties/prop_697239a2d8f618.79594361.jpg', 0, 0),
(143, 46, 'uploads/properties/prop_697239a2d91506.37645108.jpg', 0, 0),
(144, 46, 'uploads/properties/prop_697239a2d93565.46793574.jpg', 0, 0),
(145, 46, 'uploads/properties/prop_697239a2d95157.54994857.jpg', 0, 0),
(146, 47, 'uploads/properties/prop_697b08cad0b7e.webp', 1, 0),
(147, 48, 'uploads/properties/prop_698616c1a93c9.jpg', 1, 0),
(148, 48, 'uploads/properties/prop_698616c1a973c.jpg', 0, 0),
(149, 48, 'uploads/properties/prop_698616c1a9953.jpg', 0, 0),
(150, 48, 'uploads/properties/prop_698616c1a9b56.jpg', 0, 0),
(151, 48, 'uploads/properties/prop_698616c1a9d64.jpg', 0, 0),
(152, 48, 'uploads/properties/prop_698616c1a9f62.jpg', 0, 0),
(153, 48, 'uploads/properties/prop_698616c1aa146.jpg', 0, 0),
(154, 48, 'uploads/properties/prop_698616c1aa335.jpg', 0, 0),
(155, 48, 'uploads/properties/prop_698616c1aa50d.jpg', 0, 0),
(156, 48, 'uploads/properties/prop_698616c1aa714.jpg', 0, 0),
(157, 48, 'uploads/properties/prop_698616c1aa90b.jpg', 0, 0),
(158, 48, 'uploads/properties/prop_698616c1aaaf7.jpg', 0, 0),
(159, 48, 'uploads/properties/prop_698616c1aad1f.jpg', 0, 0),
(160, 48, 'uploads/properties/prop_698616c1ab544.jpg', 0, 0),
(161, 48, 'uploads/properties/prop_698616c1ab73a.jpg', 0, 0),
(162, 48, 'uploads/properties/prop_698616c1ab954.jpg', 0, 0),
(163, 48, 'uploads/properties/prop_698616c1abbed.jpg', 0, 0),
(164, 48, 'uploads/properties/prop_698616c1abfb2.jpg', 0, 0),
(165, 48, 'uploads/properties/prop_698616c1ac2a1.jpg', 0, 0),
(166, 48, 'uploads/properties/prop_698616c1ac761.jpg', 0, 0),
(167, 47, 'uploads/properties/prop_698ff7815c811.png', 0, 0),
(168, 49, 'uploads/properties/prop_6994757a4edea.mp4', 1, 0),
(169, 50, 'uploads/properties/prop_699a1d8778ed5.jpg', 1, 0),
(170, 50, 'uploads/properties/prop_699a1d877a198.jpg', 0, 0),
(171, 51, 'uploads/properties/prop_699b314668d4e.jpg', 1, 0),
(172, 51, 'uploads/properties/prop_699b3146695c2.jpg', 0, 0),
(173, 51, 'uploads/properties/prop_699b314669a25.jpg', 0, 0),
(174, 51, 'uploads/properties/prop_699b314669d72.jpg', 0, 0),
(175, 51, 'uploads/properties/prop_699b314669fab.jpg', 0, 0),
(176, 51, 'uploads/properties/prop_699b31466a1aa.jpg', 0, 0),
(177, 51, 'uploads/properties/prop_699b31466a493.jpg', 0, 0),
(178, 51, 'uploads/properties/prop_699b31466b323.jpg', 0, 0),
(179, 52, 'uploads/properties/prop_699b49d723122.jpg', 1, 0),
(180, 52, 'uploads/properties/prop_699b49d72398f.jpg', 0, 0),
(181, 52, 'uploads/properties/prop_699b49d723bf7.jpg', 0, 0),
(182, 52, 'uploads/properties/prop_699b49d724138.jpg', 0, 0),
(183, 52, 'uploads/properties/prop_699b49d72444f.jpg', 0, 0),
(184, 52, 'uploads/properties/prop_699b49d724678.jpg', 0, 0),
(185, 53, 'uploads/properties/prop_699b4c484de08.jpg', 1, 0),
(186, 53, 'uploads/properties/prop_699b4c484e153.jpg', 0, 0),
(187, 53, 'uploads/properties/prop_699b4c484e345.jpg', 0, 0),
(188, 53, 'uploads/properties/prop_699b4c484e554.jpg', 0, 0),
(189, 53, 'uploads/properties/prop_699b4c484e7aa.jpg', 0, 0),
(190, 53, 'uploads/properties/prop_699b4c484e980.jpg', 0, 0),
(191, 53, 'uploads/properties/prop_699b4c484eb4d.jpg', 0, 0),
(192, 53, 'uploads/properties/prop_699b4c484ed39.jpg', 0, 0),
(193, 53, 'uploads/properties/prop_699b4c484ef20.jpg', 0, 0),
(194, 53, 'uploads/properties/prop_699b4c484f0fb.jpg', 0, 0),
(195, 54, 'uploads/properties/prop_69a486e8099af.jpg', 1, 0),
(196, 54, 'uploads/properties/prop_69a486e809f1f.jpg', 0, 0),
(197, 54, 'uploads/properties/prop_69a486e80a21c.jpg', 0, 0),
(198, 54, 'uploads/properties/prop_69a486e80a4d0.jpg', 0, 0),
(199, 54, 'uploads/properties/prop_69a486e80a77c.jpg', 0, 0),
(200, 54, 'uploads/properties/prop_69a486e80a9f6.jpg', 0, 0),
(201, 54, 'uploads/properties/prop_69a486e80ac8b.jpg', 0, 0),
(202, 54, 'uploads/properties/prop_69a486e80b11e.jpg', 0, 0),
(203, 54, 'uploads/properties/prop_69a486e80b3fa.jpg', 0, 0),
(204, 54, 'uploads/properties/prop_69a486e80b907.jpg', 0, 0),
(205, 54, 'uploads/properties/prop_69a486e80bc2a.jpg', 0, 0),
(206, 55, 'uploads/properties/prop_69b1e03e480b1.jpg', 1, 0),
(207, 55, 'uploads/properties/prop_69b1e03e488a0.jpg', 0, 0),
(208, 55, 'uploads/properties/prop_69b1e03e48e81.jpg', 0, 0),
(209, 55, 'uploads/properties/prop_69b1e03e491a4.jpg', 0, 0),
(210, 55, 'uploads/properties/prop_69b1e03e49427.jpg', 0, 0),
(211, 55, 'uploads/properties/prop_69b1e03e49631.jpg', 0, 0),
(212, 55, 'uploads/properties/prop_69b1e03e49805.jpg', 0, 0),
(213, 55, 'uploads/properties/prop_69b1e03e49a7c.jpg', 0, 0),
(214, 55, 'uploads/properties/prop_69b1e03e49c70.jpg', 0, 0),
(215, 55, 'uploads/properties/prop_69b1e03e49e92.jpg', 0, 0),
(216, 55, 'uploads/properties/prop_69b1e03e4a0a2.jpg', 0, 0),
(217, 55, 'uploads/properties/prop_69b1e03e4a381.jpg', 0, 0),
(218, 55, 'uploads/properties/prop_69b1e03e4a58c.jpg', 0, 0),
(219, 55, 'uploads/properties/prop_69b1e03e4a80e.jpg', 0, 0),
(220, 55, 'uploads/properties/prop_69b1e03e4a9f4.jpg', 0, 0),
(221, 55, 'uploads/properties/prop_69b1e03e4ac83.jpg', 0, 0),
(222, 55, 'uploads/properties/prop_69b1e03e4aeba.jpg', 0, 0),
(223, 55, 'uploads/properties/prop_69b1e03e4b28f.jpg', 0, 0),
(224, 55, 'uploads/properties/prop_69b1e03e4b50b.jpg', 0, 0),
(225, 55, 'uploads/properties/prop_69b1e03e4b76e.jpg', 0, 0),
(226, 56, 'uploads/properties/prop_69b1f4cbc3e2c.jpg', 1, 0),
(227, 56, 'uploads/properties/prop_69b1f4cbc41ee.jpg', 0, 0),
(228, 56, 'uploads/properties/prop_69b1f4cbc4490.jpg', 0, 0),
(229, 56, 'uploads/properties/prop_69b1f4cbc4708.jpg', 0, 0),
(230, 56, 'uploads/properties/prop_69b1f4cbc4987.jpg', 0, 0),
(231, 56, 'uploads/properties/prop_69b1f4cbc4c61.jpg', 0, 0),
(232, 56, 'uploads/properties/prop_69b1f4cbc4f7b.jpg', 0, 0),
(233, 56, 'uploads/properties/prop_69b1f4cbc5229.jpg', 0, 0),
(234, 56, 'uploads/properties/prop_69b1f4cbc5579.jpg', 0, 0),
(235, 56, 'uploads/properties/prop_69b1f4cbc58f1.jpg', 0, 0),
(236, 56, 'uploads/properties/prop_69b1f4cbc5c44.jpg', 0, 0),
(237, 56, 'uploads/properties/prop_69b1f4cbc5ffe.jpg', 0, 0),
(238, 56, 'uploads/properties/prop_69b1f4cbc62ae.jpg', 0, 0),
(239, 57, 'uploads/properties/prop_69c5a2d532d69.jpg', 1, 0),
(240, 57, 'uploads/properties/prop_69c5a2d5337ea.jpg', 0, 0),
(241, 57, 'uploads/properties/prop_69c5a2d533d85.jpg', 0, 0),
(242, 57, 'uploads/properties/prop_69c5a2d5346f7.jpg', 0, 0),
(243, 57, 'uploads/properties/prop_69c5a2d534970.jpg', 0, 0),
(244, 57, 'uploads/properties/prop_69c5a2d534c6e.jpg', 0, 0),
(245, 57, 'uploads/properties/prop_69c5a2d534f20.jpg', 0, 0),
(246, 57, 'uploads/properties/prop_69c5a2d5351c0.jpg', 0, 0),
(247, 57, 'uploads/properties/prop_69c5a2d5353d3.jpg', 0, 0),
(248, 57, 'uploads/properties/prop_69c5a2d5355f9.jpg', 0, 0),
(249, 57, 'uploads/properties/prop_69c5a2d53580c.jpg', 0, 0),
(250, 57, 'uploads/properties/prop_69c5a2d535a54.jpg', 0, 0),
(251, 57, 'uploads/properties/prop_69c5a2d535cc1.jpg', 0, 0),
(252, 57, 'uploads/properties/prop_69c5a2d535f00.jpg', 0, 0),
(253, 57, 'uploads/properties/prop_69c5a2d5361a3.jpg', 0, 0),
(254, 57, 'uploads/properties/prop_69c5a2d53643b.jpg', 0, 0),
(255, 58, 'uploads/properties/prop_69c5a733115cd.jpg', 1, 0),
(256, 58, 'uploads/properties/prop_69c5a733118c6.jpg', 0, 0),
(257, 58, 'uploads/properties/prop_69c5a73311afc.jpg', 0, 0),
(258, 58, 'uploads/properties/prop_69c5a73311de8.jpg', 0, 0),
(259, 58, 'uploads/properties/prop_69c5a73312027.jpg', 0, 0),
(260, 58, 'uploads/properties/prop_69c5a73312202.jpg', 0, 0),
(261, 58, 'uploads/properties/prop_69c5a7331251b.jpg', 0, 0),
(262, 58, 'uploads/properties/prop_69c5a733126cb.jpg', 0, 0),
(263, 58, 'uploads/properties/prop_69c5a73312844.jpg', 0, 0),
(264, 58, 'uploads/properties/prop_69c5a73312a6e.jpg', 0, 0),
(265, 58, 'uploads/properties/prop_69c5a73312c32.jpg', 0, 0),
(266, 58, 'uploads/properties/prop_69c5a73312e0b.webp', 0, 0),
(267, 58, 'uploads/properties/prop_69c5a73312f7d.png', 0, 0),
(268, 58, 'uploads/properties/prop_69c5a7331334d.jpg', 0, 0),
(269, 58, 'uploads/properties/prop_69c5a73313606.jpg', 0, 0),
(270, 58, 'uploads/properties/prop_69c5a73313774.jpg', 0, 0),
(271, 58, 'uploads/properties/prop_69c5a73313897.jpg', 0, 0),
(272, 58, 'uploads/properties/prop_69c5a733139b3.jpg', 0, 0),
(273, 58, 'uploads/properties/prop_69c5a73313ac9.png', 0, 0),
(274, 58, 'uploads/properties/prop_69c5a73313bfb.png', 0, 0),
(275, 59, 'uploads/properties/prop_69cc72adeb91d.jpg', 1, 0),
(276, 59, 'uploads/properties/prop_69cc72adebda1.jpg', 0, 0),
(277, 59, 'uploads/properties/prop_69cc72adebfbc.jpg', 0, 0),
(278, 59, 'uploads/properties/prop_69cc72adec15d.jpg', 0, 0),
(279, 59, 'uploads/properties/prop_69cc72adec372.jpg', 0, 0),
(280, 59, 'uploads/properties/prop_69cc72adec4d5.jpg', 0, 0),
(281, 59, 'uploads/properties/prop_69cc72adec61c.jpg', 0, 0),
(282, 59, 'uploads/properties/prop_69cc72adec82e.jpg', 0, 0),
(283, 59, 'uploads/properties/prop_69cc72adeca28.jpg', 0, 0),
(284, 59, 'uploads/properties/prop_69cc72adecb7c.jpg', 0, 0),
(285, 59, 'uploads/properties/prop_69cc72adeccac.jpg', 0, 0),
(286, 59, 'uploads/properties/prop_69cc72adece4e.jpg', 0, 0),
(287, 59, 'uploads/properties/prop_69cc72aded002.jpg', 0, 0),
(288, 59, 'uploads/properties/prop_69cc72aded173.jpg', 0, 0),
(289, 59, 'uploads/properties/prop_69cc72aded2ca.jpg', 0, 0),
(290, 60, 'uploads/properties/prop_69cc753570957.jpg', 1, 0),
(291, 60, 'uploads/properties/prop_69cc753570cc6.jpg', 0, 0),
(292, 60, 'uploads/properties/prop_69cc753570fc6.jpg', 0, 0),
(293, 60, 'uploads/properties/prop_69cc75357130f.jpg', 0, 0),
(294, 60, 'uploads/properties/prop_69cc7535715c5.jpg', 0, 0),
(295, 60, 'uploads/properties/prop_69cc7535718a0.jpg', 0, 0),
(296, 60, 'uploads/properties/prop_69cc753571b4d.jpg', 0, 0),
(297, 60, 'uploads/properties/prop_69cc753571e5e.jpg', 0, 0),
(298, 60, 'uploads/properties/prop_69cc753572871.jpg', 0, 0),
(299, 60, 'uploads/properties/prop_69cc753572bd7.jpg', 0, 0),
(300, 60, 'uploads/properties/prop_69cc7535730bf.jpg', 0, 0),
(301, 60, 'uploads/properties/prop_69cc75357338e.jpg', 0, 0),
(302, 61, 'uploads/properties/prop_69cf21c0369f8.jpg', 1, 0),
(303, 61, 'uploads/properties/prop_69cf21c037523.jpg', 0, 0),
(304, 61, 'uploads/properties/prop_69cf21c037736.jpg', 0, 0),
(305, 61, 'uploads/properties/prop_69cf21c0378d0.jpg', 0, 0),
(306, 62, 'uploads/properties/prop_69dd25f10effd.jpg', 1, 0),
(307, 62, 'uploads/properties/prop_69dd25f10f401.jpg', 0, 0),
(308, 62, 'uploads/properties/prop_69dd25f10f72d.jpg', 0, 0),
(309, 62, 'uploads/properties/prop_69dd25f10f908.jpg', 0, 0),
(310, 62, 'uploads/properties/prop_69dd25f10fa6c.jpg', 0, 0),
(311, 62, 'uploads/properties/prop_69dd25f10fc0e.jpg', 0, 0),
(312, 62, 'uploads/properties/prop_69dd25f10fe60.jpg', 0, 0),
(313, 62, 'uploads/properties/prop_69dd25f10fffd.jpg', 0, 0),
(314, 62, 'uploads/properties/prop_69dd25f11021e.jpg', 0, 0),
(315, 62, 'uploads/properties/prop_69dd25f11041e.jpg', 0, 0),
(316, 62, 'uploads/properties/prop_69dd25f1105e4.jpg', 0, 0),
(317, 62, 'uploads/properties/prop_69dd25f1107cd.jpg', 0, 0),
(318, 63, 'uploads/properties/prop_69dd27a1968b9.jpg', 1, 0),
(319, 63, 'uploads/properties/prop_69dd27a196b31.jpg', 0, 0),
(320, 63, 'uploads/properties/prop_69dd27a196cd3.jpg', 0, 0),
(321, 63, 'uploads/properties/prop_69dd27a196e72.jpg', 0, 0),
(322, 63, 'uploads/properties/prop_69dd27a19700a.jpg', 0, 0),
(323, 63, 'uploads/properties/prop_69dd27a1971af.jpg', 0, 0),
(324, 63, 'uploads/properties/prop_69dd27a19732c.jpg', 0, 0),
(325, 63, 'uploads/properties/prop_69dd27a1974d4.jpg', 0, 0),
(326, 63, 'uploads/properties/prop_69dd27a1976cd.jpg', 0, 0),
(327, 63, 'uploads/properties/prop_69dd27a197843.jpg', 0, 0),
(328, 63, 'uploads/properties/prop_69dd27a197995.jpg', 0, 0),
(329, 63, 'uploads/properties/prop_69dd27a197bb3.jpg', 0, 0),
(330, 63, 'uploads/properties/prop_69dd27a197d83.jpg', 0, 0),
(331, 64, 'uploads/properties/prop_69dd2b3cdef0a.jpg', 1, 0),
(332, 64, 'uploads/properties/prop_69dd2b3cdf205.jpg', 0, 0),
(333, 64, 'uploads/properties/prop_69dd2b3cdf442.jpg', 0, 0),
(334, 64, 'uploads/properties/prop_69dd2b3cdf67b.jpg', 0, 0),
(335, 64, 'uploads/properties/prop_69dd2b3cdf889.jpg', 0, 0),
(336, 64, 'uploads/properties/prop_69dd2b3cdfa9b.jpg', 0, 0),
(337, 64, 'uploads/properties/prop_69dd2b3cdfead.jpg', 0, 0),
(338, 64, 'uploads/properties/prop_69dd2b3ce00aa.jpg', 0, 0),
(339, 64, 'uploads/properties/prop_69dd2b3ce02f3.jpg', 0, 0),
(340, 64, 'uploads/properties/prop_69dd2b3ce0548.jpg', 0, 0),
(341, 64, 'uploads/properties/prop_69dd2b3ce0769.jpg', 0, 0),
(342, 65, 'uploads/properties/prop_69e680ba9523a.jpg', 1, 0),
(343, 65, 'uploads/properties/prop_69e680ba9584c.jpg', 0, 0),
(344, 65, 'uploads/properties/prop_69e680ba95ba3.jpg', 0, 0),
(345, 65, 'uploads/properties/prop_69e680ba95e4e.jpg', 0, 0),
(346, 65, 'uploads/properties/prop_69e680ba960ef.jpg', 0, 0),
(347, 65, 'uploads/properties/prop_69e680ba963ea.jpg', 0, 0),
(348, 65, 'uploads/properties/prop_69e680ba96735.jpg', 0, 0),
(349, 65, 'uploads/properties/prop_69e680ba96999.jpg', 0, 0),
(350, 65, 'uploads/properties/prop_69e680ba96c26.jpg', 0, 0),
(351, 65, 'uploads/properties/prop_69e680ba96f2e.jpg', 0, 0),
(352, 66, 'uploads/properties/prop_69e689993605b.jpg', 1, 0),
(353, 66, 'uploads/properties/prop_69e6899936453.jpg', 0, 0),
(354, 66, 'uploads/properties/prop_69e68999369d5.jpg', 0, 0),
(355, 66, 'uploads/properties/prop_69e6899936cdb.jpg', 0, 0),
(356, 66, 'uploads/properties/prop_69e6899937031.jpg', 0, 0),
(357, 66, 'uploads/properties/prop_69e68999371ac.jpg', 0, 0),
(358, 66, 'uploads/properties/prop_69e68999372eb.jpg', 0, 0),
(359, 66, 'uploads/properties/prop_69e689993742f.jpg', 0, 0),
(360, 66, 'uploads/properties/prop_69e6899937599.jpg', 0, 0),
(361, 66, 'uploads/properties/prop_69e6899937bb7.jpg', 0, 0),
(362, 66, 'uploads/properties/prop_69e6899937e46.jpg', 0, 0),
(363, 66, 'uploads/properties/prop_69e6899937ff3.jpg', 0, 0),
(364, 66, 'uploads/properties/prop_69e6899938333.jpg', 0, 0),
(365, 66, 'uploads/properties/prop_69e689993867f.jpg', 0, 0),
(366, 67, 'uploads/properties/prop_67_32ba3815cb4f3d1d.png', 1, 0),
(367, 68, 'uploads/properties/prop_68_4c2d96282c9f6d7c.png', 1, 0),
(368, 69, 'uploads/properties/prop_69_31e22dd04c509b0b.jpg', 1, 0),
(369, 69, 'uploads/properties/prop_69_e6c9ce5358e3c465.jpg', 0, 1),
(370, 69, 'uploads/properties/prop_69_3ced78d3bbb5c0a1.jpg', 0, 2),
(371, 69, 'uploads/properties/prop_69_80edbda1f2cb3d5c.jpg', 0, 3),
(372, 70, 'uploads/properties/prop_70_c037dd02e0fdea3c.jpg', 1, 0),
(373, 70, 'uploads/properties/prop_70_477ad9f9dcd5b3fa.jpg', 0, 1),
(374, 70, 'uploads/properties/prop_70_30c088402ea6490f.jpg', 0, 2),
(375, 70, 'uploads/properties/prop_70_a4d5c08b4a37b1ea.jpg', 0, 3),
(376, 70, 'uploads/properties/prop_70_d3915c5b1c5bd34c.jpg', 0, 4),
(377, 71, 'uploads/properties/prop_71_c236324504695ed6.jpg', 1, 0),
(378, 71, 'uploads/properties/prop_71_f10052ceaef41e73.jpg', 0, 1),
(379, 71, 'uploads/properties/prop_71_e44089b1535a3587.jpg', 0, 2),
(380, 71, 'uploads/properties/prop_71_f07c956d26453661.jpg', 0, 3),
(381, 71, 'uploads/properties/prop_71_1d69c1013fe2a82e.jpg', 0, 4),
(382, 71, 'uploads/properties/prop_71_9f143087cb3fd52a.jpg', 0, 5),
(383, 71, 'uploads/properties/prop_71_2fd1e1537727da57.jpg', 0, 6),
(384, 72, 'uploads/properties/prop_72_71ac6d0ce7367f98.jpg', 1, 0),
(385, 72, 'uploads/properties/prop_72_e1059f9474cfd3c3.jpg', 0, 1),
(386, 73, 'uploads/properties/prop_73_e3632e4c9fefa6a5.jpg', 1, 0),
(387, 73, 'uploads/properties/prop_73_1c103f8c51e83b3d.jpg', 0, 1),
(388, 73, 'uploads/properties/prop_73_eec2e9b0ddfc1ad7.jpg', 0, 2),
(389, 73, 'uploads/properties/prop_73_20076bd5808a71d4.jpg', 0, 3),
(390, 73, 'uploads/properties/prop_73_4a0618244374d916.jpg', 0, 4),
(391, 73, 'uploads/properties/prop_73_bab92d82344543fd.jpg', 0, 5),
(392, 73, 'uploads/properties/prop_73_80a2564fe8027719.jpg', 0, 6),
(393, 73, 'uploads/properties/prop_73_396397dbb456dd35.jpg', 0, 7),
(394, 73, 'uploads/properties/prop_73_1563128e6d3c9365.jpg', 0, 8),
(395, 73, 'uploads/properties/prop_73_e6494490b32df291.jpg', 0, 9),
(396, 74, 'uploads/properties/prop_74_d9587e1923838f4c.jpg', 1, 0),
(397, 74, 'uploads/properties/prop_74_1a2b3222c7a53757.jpg', 0, 1),
(398, 74, 'uploads/properties/prop_74_82e9747014c159d1.jpg', 0, 2),
(399, 74, 'uploads/properties/prop_74_88c49c83c51d78f5.jpg', 0, 3),
(400, 74, 'uploads/properties/prop_74_4496ffaae2ae0914.jpg', 0, 4),
(401, 74, 'uploads/properties/prop_74_c693fdf00cbc4e6f.jpg', 0, 5),
(402, 74, 'uploads/properties/prop_74_4562a08fde0ed3b2.jpg', 0, 6),
(403, 74, 'uploads/properties/prop_74_9df18b2f69f7f114.jpg', 0, 7),
(404, 74, 'uploads/properties/prop_74_d944d29ea75614d1.jpg', 0, 8),
(405, 74, 'uploads/properties/prop_74_5cda546d73036ef2.jpg', 0, 9),
(406, 75, 'uploads/properties/prop_75_e32138d80aa13738.jpg', 1, 0),
(407, 75, 'uploads/properties/prop_75_55cf084e7f6b8b82.jpg', 0, 1),
(408, 75, 'uploads/properties/prop_75_3ed3a0212f668a7b.jpg', 0, 2),
(409, 75, 'uploads/properties/prop_75_25dfe70b8182e877.jpg', 0, 3),
(410, 76, 'uploads/properties/prop_76_d60743cecdc1d417.jpg', 1, 0),
(411, 76, 'uploads/properties/prop_76_ddac64090551d1d6.jpg', 0, 1),
(412, 76, 'uploads/properties/prop_76_36053b5825274665.jpg', 0, 2),
(413, 76, 'uploads/properties/prop_76_aa83f3da90e3de88.jpg', 0, 3),
(414, 76, 'uploads/properties/prop_76_9d51ef6d4852a3b1.jpg', 0, 4),
(415, 76, 'uploads/properties/prop_76_00352828b2762a3c.jpg', 0, 5),
(416, 76, 'uploads/properties/prop_76_2635527177e40f77.jpg', 0, 6),
(417, 77, 'uploads/properties/prop_77_4c6ab37ae96cba81.jpg', 1, 0),
(418, 77, 'uploads/properties/prop_77_5e9d34031eb2c693.jpg', 0, 1),
(419, 77, 'uploads/properties/prop_77_e17aed1c62cc8aca.jpg', 0, 2),
(420, 77, 'uploads/properties/prop_77_7c7d0df11610c789.jpg', 0, 3),
(421, 77, 'uploads/properties/prop_77_76ea4cb580f6ac47.jpg', 0, 4),
(422, 77, 'uploads/properties/prop_77_5a85f96c3599c7b3.jpg', 0, 5),
(423, 77, 'uploads/properties/prop_77_ef1449c302942c7f.jpg', 0, 6),
(424, 77, 'uploads/properties/prop_77_04f7eb1870ecbf3f.jpg', 0, 7),
(425, 77, 'uploads/properties/prop_77_0d7682075b929678.jpg', 0, 8),
(426, 77, 'uploads/properties/prop_77_48e0ac96c8eec265.jpg', 0, 9),
(427, 77, 'uploads/properties/prop_77_2b4a31d17ef6749f.jpg', 0, 10),
(428, 77, 'uploads/properties/prop_77_aaff45d989704251.jpg', 0, 11),
(429, 77, 'uploads/properties/prop_77_fde593ae07baf368.jpg', 0, 12),
(430, 77, 'uploads/properties/prop_77_fdea4036663648f1.jpg', 0, 13),
(431, 77, 'uploads/properties/prop_77_98efa5154ca18b5f.jpg', 0, 14),
(432, 77, 'uploads/properties/prop_77_8876ae08596ff711.jpg', 0, 15),
(433, 77, 'uploads/properties/prop_77_efd6396aedbb0ab9.jpg', 0, 16),
(434, 77, 'uploads/properties/prop_77_4c6b36cee4638310.jpg', 0, 17),
(435, 77, 'uploads/properties/prop_77_2b866d29a26ffd81.jpg', 0, 18),
(436, 77, 'uploads/properties/prop_77_68445f83e451915a.jpg', 0, 19),
(437, 78, 'uploads/properties/prop_78_7ff440a0535bcfc8.jpg', 1, 0),
(438, 78, 'uploads/properties/prop_78_95640871e3c3377e.jpg', 0, 1),
(439, 78, 'uploads/properties/prop_78_f3c49c7e21557742.jpg', 0, 2),
(440, 78, 'uploads/properties/prop_78_43fb81442b6ab500.jpg', 0, 3),
(441, 78, 'uploads/properties/prop_78_c769f03b60df0f1b.jpg', 0, 4),
(442, 78, 'uploads/properties/prop_78_eb5ff5140bbf8d56.jpg', 0, 5),
(443, 78, 'uploads/properties/prop_78_3f978237db2fdb14.jpg', 0, 6),
(444, 78, 'uploads/properties/prop_78_9b450d1c9554a959.jpg', 0, 7),
(445, 78, 'uploads/properties/prop_78_c24dccf2f1c46305.jpg', 0, 8),
(446, 78, 'uploads/properties/prop_78_e09608123ea5f226.jpg', 0, 9),
(447, 78, 'uploads/properties/prop_78_1eee4a8c960ed434.jpg', 0, 10),
(448, 78, 'uploads/properties/prop_78_b4897e870e5b99d0.jpg', 0, 11),
(449, 78, 'uploads/properties/prop_78_7f931b1d799c30f0.jpg', 0, 12),
(450, 78, 'uploads/properties/prop_78_c43c1c09ca644e46.jpg', 0, 13),
(451, 79, 'uploads/properties/prop_79_b6fca287e1c89058.webp', 1, 0),
(452, 79, 'uploads/properties/prop_79_083230a1148cc3b3.jpg', 0, 1),
(453, 79, 'uploads/properties/prop_79_1cc9123c590bb3ff.jpg', 0, 2),
(454, 80, 'uploads/properties/prop_80_ab429d66af156aca.jpg', 1, 0),
(455, 80, 'uploads/properties/prop_80_05945e140cb46a38.jpg', 0, 1),
(456, 80, 'uploads/properties/prop_80_e9d68780e50af331.jpg', 0, 2),
(457, 80, 'uploads/properties/prop_80_379d5bd94335e8d6.jpg', 0, 3),
(458, 80, 'uploads/properties/prop_80_aedb1a5a3947d7b0.jpg', 0, 4),
(459, 80, 'uploads/properties/prop_80_48c0f0672a7e566b.jpg', 0, 5),
(460, 81, 'uploads/properties/prop_81_823d9bf10e994794.jpg', 1, 0),
(461, 81, 'uploads/properties/prop_81_bfcc411bc67db60a.jpg', 0, 1),
(462, 81, 'uploads/properties/prop_81_6dc39f746f938055.jpg', 0, 2),
(463, 81, 'uploads/properties/prop_81_2ec286d24f169d10.jpg', 0, 3),
(464, 81, 'uploads/properties/prop_81_c9d44c0e49e3da35.jpg', 0, 4),
(465, 81, 'uploads/properties/prop_81_c449e82c5cc781db.jpg', 0, 5),
(466, 81, 'uploads/properties/prop_81_01f7e48b2a9e6f16.jpg', 0, 6),
(467, 81, 'uploads/properties/prop_81_66a01296b647387d.jpg', 0, 7),
(468, 81, 'uploads/properties/prop_81_aba30a4b92e54dc9.jpg', 0, 8),
(469, 82, 'uploads/properties/prop_82_7c614c968af03dd1.jpg', 1, 0),
(470, 82, 'uploads/properties/prop_82_467d26d541deb143.jpg', 0, 1),
(471, 82, 'uploads/properties/prop_82_1061ba6b29142475.jpg', 0, 2),
(472, 82, 'uploads/properties/prop_82_6287f78bb1a598c2.jpg', 0, 3),
(473, 82, 'uploads/properties/prop_82_88c8e528aa657c15.jpg', 0, 4),
(474, 82, 'uploads/properties/prop_82_9a4a55ebe46d2a7c.jpg', 0, 5),
(475, 82, 'uploads/properties/prop_82_01c8a9cfb1d1a1f4.jpg', 0, 6),
(476, 82, 'uploads/properties/prop_82_68a0ab8f3bd331b7.jpg', 0, 7),
(477, 82, 'uploads/properties/prop_82_d8f8696812bb9453.jpg', 0, 8);

-- --------------------------------------------------------

--
-- Table structure for table `property_interactions`
--

CREATE TABLE `property_interactions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `property_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `interaction_type` enum('view','whatsapp_click','call_reveal','share') NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `property_interactions`
--

INSERT INTO `property_interactions` (`id`, `property_id`, `user_id`, `interaction_type`, `created_at`) VALUES
(12, 64, NULL, 'view', '2026-04-29 22:28:12'),
(13, 35, NULL, 'view', '2026-04-29 22:28:13'),
(14, 35, NULL, 'view', '2026-04-29 22:28:22'),
(15, 64, NULL, 'view', '2026-04-29 22:28:22'),
(16, 35, NULL, 'view', '2026-04-29 22:28:23'),
(17, 35, NULL, 'view', '2026-04-29 22:28:23'),
(18, 35, NULL, 'view', '2026-04-29 22:28:24'),
(19, 35, NULL, 'view', '2026-04-29 22:28:46'),
(20, 46, NULL, 'view', '2026-04-29 22:28:53'),
(21, 33, NULL, 'view', '2026-04-29 22:29:01'),
(22, 33, NULL, 'view', '2026-04-29 22:29:11'),
(23, 35, NULL, 'view', '2026-04-29 22:29:34'),
(24, 35, NULL, 'whatsapp_click', '2026-04-29 22:29:37'),
(25, 35, NULL, 'call_reveal', '2026-04-29 22:29:46'),
(26, 64, NULL, 'view', '2026-04-29 22:29:51'),
(27, 50, NULL, 'view', '2026-04-29 22:29:52'),
(28, 64, NULL, 'view', '2026-04-29 22:30:00'),
(29, 66, NULL, 'view', '2026-04-29 22:30:19'),
(30, 64, NULL, 'view', '2026-04-29 22:30:22'),
(31, 64, NULL, 'view', '2026-04-29 22:31:13'),
(32, 62, NULL, 'view', '2026-04-29 22:31:50'),
(33, 64, NULL, 'view', '2026-04-29 22:33:03'),
(34, 44, NULL, 'view', '2026-04-30 00:15:03'),
(35, 57, NULL, 'view', '2026-04-30 02:29:00'),
(36, 50, NULL, 'view', '2026-04-30 02:34:05'),
(37, 50, NULL, 'view', '2026-04-30 02:34:12'),
(38, 57, NULL, 'view', '2026-04-30 06:20:33'),
(39, 59, NULL, 'view', '2026-05-01 00:23:51'),
(40, 48, NULL, 'view', '2026-05-01 20:06:42'),
(41, 35, NULL, 'view', '2026-05-02 22:12:49'),
(42, 58, NULL, 'view', '2026-05-09 03:51:35'),
(43, 65, NULL, 'view', '2026-05-10 15:32:18'),
(44, 65, NULL, 'view', '2026-05-10 15:48:10'),
(45, 45, NULL, 'view', '2026-05-13 13:00:13'),
(46, 64, NULL, 'view', '2026-05-13 16:28:17'),
(47, 64, NULL, 'view', '2026-05-13 16:29:27'),
(48, 64, NULL, 'view', '2026-05-14 05:57:57'),
(49, 68, 1, 'view', '2026-05-14 22:54:40'),
(50, 65, NULL, 'view', '2026-05-15 22:16:07'),
(51, 64, NULL, 'view', '2026-05-15 23:06:23'),
(52, 26, NULL, 'view', '2026-05-17 17:47:28'),
(53, 50, NULL, 'view', '2026-05-19 15:45:24'),
(54, 55, NULL, 'view', '2026-05-20 00:57:07'),
(55, 62, NULL, 'view', '2026-05-20 00:58:00'),
(56, 39, NULL, 'view', '2026-05-20 14:52:55'),
(57, 64, NULL, 'view', '2026-05-20 17:31:14'),
(58, 71, NULL, 'view', '2026-05-20 17:32:01'),
(59, 60, NULL, 'view', '2026-05-20 17:32:46'),
(60, 64, NULL, 'view', '2026-05-20 17:34:09'),
(61, 60, NULL, 'view', '2026-05-20 17:37:35'),
(62, 57, NULL, 'view', '2026-05-20 17:38:10'),
(63, 55, NULL, 'view', '2026-05-20 17:38:33'),
(64, 54, NULL, 'view', '2026-05-20 17:39:30'),
(65, 54, NULL, 'view', '2026-05-20 17:40:13'),
(66, 57, 1, 'view', '2026-05-20 17:43:17'),
(67, 49, NULL, 'view', '2026-05-20 18:40:50'),
(68, 48, NULL, 'view', '2026-05-21 02:43:32'),
(69, 64, 13, 'view', '2026-05-21 15:09:38'),
(70, 64, 13, 'view', '2026-05-21 15:32:03'),
(71, 64, 13, 'view', '2026-05-21 15:42:18'),
(72, 56, NULL, 'view', '2026-05-31 07:44:29'),
(73, 48, NULL, 'view', '2026-05-31 16:47:20'),
(74, 64, NULL, 'view', '2026-06-01 16:47:16'),
(75, 64, NULL, 'view', '2026-06-01 18:45:28'),
(76, 64, 1, 'view', '2026-06-01 19:08:38'),
(77, 64, 13, 'view', '2026-06-01 19:57:18'),
(78, 63, 13, 'view', '2026-06-01 19:57:28'),
(79, 61, 13, 'view', '2026-06-01 19:57:50'),
(80, 61, 1, 'view', '2026-06-01 20:01:15'),
(81, 56, 1, 'view', '2026-06-01 20:22:36'),
(82, 35, NULL, 'view', '2026-06-05 08:26:34'),
(83, 62, NULL, 'view', '2026-06-06 04:02:21'),
(84, 48, NULL, 'view', '2026-06-06 14:48:19'),
(85, 39, NULL, 'view', '2026-06-08 17:47:25'),
(86, 26, NULL, 'view', '2026-06-10 02:26:03'),
(87, 55, NULL, 'view', '2026-06-10 12:34:46'),
(88, 76, 1, 'view', '2026-06-11 23:30:17'),
(89, 75, 1, 'view', '2026-06-11 23:31:13'),
(90, 64, 1, 'view', '2026-06-11 23:31:37'),
(91, 51, 1, 'view', '2026-06-11 23:32:02'),
(92, 59, 13, 'view', '2026-06-12 00:23:39'),
(93, 76, 33, 'view', '2026-06-12 00:24:37'),
(94, 62, 33, 'view', '2026-06-12 00:24:49'),
(95, 58, NULL, 'view', '2026-06-12 11:33:48'),
(96, 30, NULL, 'view', '2026-06-15 00:58:03'),
(97, 65, NULL, 'view', '2026-06-15 01:51:35'),
(98, 50, NULL, 'view', '2026-06-15 16:10:45'),
(99, 72, NULL, 'view', '2026-06-15 16:11:52'),
(100, 50, NULL, 'view', '2026-06-15 16:12:13'),
(101, 62, NULL, 'view', '2026-06-17 16:04:30'),
(102, 23, NULL, 'view', '2026-06-19 07:18:58'),
(103, 48, NULL, 'view', '2026-06-20 13:41:10'),
(104, 42, NULL, 'view', '2026-06-22 19:04:46'),
(105, 26, NULL, 'view', '2026-06-24 05:50:16'),
(106, 30, NULL, 'view', '2026-06-24 07:25:38'),
(107, 78, NULL, 'view', '2026-06-24 07:26:08'),
(108, 48, NULL, 'view', '2026-06-24 09:01:41'),
(109, 61, NULL, 'view', '2026-06-24 21:50:18'),
(110, 64, NULL, 'view', '2026-06-25 15:24:47'),
(111, 64, NULL, 'view', '2026-06-29 15:11:31'),
(112, 60, NULL, 'view', '2026-06-29 15:12:39'),
(113, 60, NULL, 'view', '2026-06-29 21:40:47'),
(114, 60, NULL, 'view', '2026-06-29 21:40:49'),
(115, 56, NULL, 'view', '2026-06-30 05:50:59'),
(116, 30, NULL, 'view', '2026-07-01 09:46:03'),
(117, 30, NULL, 'view', '2026-07-02 13:28:39'),
(118, 50, 35, 'view', '2026-07-05 11:59:25'),
(119, 50, 35, 'view', '2026-07-05 11:59:31'),
(120, 46, NULL, 'view', '2026-07-05 14:58:19'),
(121, 46, NULL, 'view', '2026-07-05 15:16:09'),
(122, 35, NULL, 'view', '2026-07-09 10:01:45'),
(123, 39, NULL, 'view', '2026-07-09 16:36:50'),
(124, 58, NULL, 'view', '2026-07-09 18:40:38'),
(125, 66, NULL, 'view', '2026-07-09 19:38:40'),
(126, 33, NULL, 'view', '2026-07-09 19:59:45'),
(127, 22, NULL, 'view', '2026-07-09 23:31:19'),
(128, 43, NULL, 'view', '2026-07-09 23:48:41'),
(129, 62, NULL, 'view', '2026-07-09 23:50:47'),
(130, 54, NULL, 'view', '2026-07-10 01:58:23'),
(131, 31, NULL, 'view', '2026-07-10 05:25:41'),
(132, 55, NULL, 'view', '2026-07-10 05:35:35'),
(133, 23, NULL, 'view', '2026-07-10 05:37:45'),
(134, 56, NULL, 'view', '2026-07-10 07:33:54'),
(135, 73, NULL, 'view', '2026-07-10 08:54:59'),
(136, 34, NULL, 'view', '2026-07-10 08:58:17'),
(137, 51, NULL, 'view', '2026-07-10 09:30:13'),
(138, 42, NULL, 'view', '2026-07-10 09:48:27'),
(139, 30, NULL, 'view', '2026-07-10 10:59:43'),
(140, 64, NULL, 'view', '2026-07-10 11:05:51'),
(141, 26, NULL, 'view', '2026-07-10 11:36:37'),
(142, 53, NULL, 'view', '2026-07-10 11:53:34'),
(143, 40, NULL, 'view', '2026-07-10 12:57:36'),
(144, 21, NULL, 'view', '2026-07-10 13:53:24'),
(145, 35, NULL, 'view', '2026-07-10 14:28:00'),
(146, 63, NULL, 'view', '2026-07-10 15:31:53'),
(147, 61, NULL, 'view', '2026-07-10 16:18:21'),
(148, 76, NULL, 'view', '2026-07-10 17:27:31'),
(149, 50, NULL, 'view', '2026-07-10 18:47:49'),
(150, 28, NULL, 'view', '2026-07-11 01:33:36'),
(151, 38, NULL, 'view', '2026-07-11 04:40:16'),
(152, 41, NULL, 'view', '2026-07-11 23:32:16'),
(153, 48, NULL, 'view', '2026-07-12 03:39:40'),
(154, 39, NULL, 'view', '2026-07-12 09:52:49'),
(155, 78, NULL, 'view', '2026-07-13 20:13:22'),
(156, 64, NULL, 'view', '2026-07-13 20:13:44'),
(157, 78, NULL, 'view', '2026-07-13 20:18:56'),
(158, 78, NULL, 'view', '2026-07-13 20:19:06'),
(159, 64, NULL, 'view', '2026-07-13 20:20:37'),
(160, 78, NULL, 'view', '2026-07-13 20:27:27'),
(161, 64, NULL, 'view', '2026-07-13 20:36:29'),
(162, 64, NULL, 'view', '2026-07-14 16:26:31'),
(163, 64, NULL, 'view', '2026-07-14 16:32:02'),
(164, 64, NULL, 'view', '2026-07-14 16:42:22'),
(165, 65, NULL, 'view', '2026-07-14 16:45:13'),
(166, 78, NULL, 'view', '2026-07-14 16:58:14'),
(167, 64, NULL, 'view', '2026-07-14 17:03:11'),
(168, 64, NULL, 'view', '2026-07-14 17:04:58'),
(169, 75, NULL, 'view', '2026-07-14 17:06:02'),
(170, 75, NULL, 'whatsapp_click', '2026-07-14 17:07:04'),
(171, 75, NULL, 'view', '2026-07-14 17:07:11'),
(172, 75, NULL, 'view', '2026-07-14 17:07:12'),
(173, 75, NULL, 'view', '2026-07-14 17:07:13'),
(174, 75, NULL, 'view', '2026-07-14 17:07:14'),
(175, 75, NULL, 'view', '2026-07-14 17:07:17'),
(176, 75, NULL, 'view', '2026-07-14 17:07:19'),
(177, 75, NULL, 'view', '2026-07-14 17:07:23'),
(178, 75, NULL, 'view', '2026-07-14 17:07:24'),
(179, 64, NULL, 'view', '2026-07-14 17:07:28'),
(180, 76, NULL, 'view', '2026-07-14 17:07:33'),
(181, 72, NULL, 'view', '2026-07-14 17:08:12'),
(182, 76, NULL, 'view', '2026-07-14 17:08:22'),
(183, 64, NULL, 'view', '2026-07-14 17:08:23'),
(184, 63, NULL, 'view', '2026-07-14 17:08:49'),
(185, 26, NULL, 'view', '2026-07-15 02:56:40'),
(186, 78, NULL, 'view', '2026-07-15 16:10:05'),
(187, 55, NULL, 'view', '2026-07-16 22:11:21'),
(188, 64, NULL, 'view', '2026-07-16 23:20:44'),
(189, 58, NULL, 'view', '2026-07-18 23:17:51'),
(190, 32, NULL, 'view', '2026-07-21 02:08:28'),
(191, 64, NULL, 'view', '2026-07-24 16:39:09'),
(192, 64, NULL, 'view', '2026-07-26 18:05:30'),
(193, 62, NULL, 'view', '2026-07-27 01:35:01'),
(194, 65, NULL, 'view', '2026-07-27 15:34:09'),
(195, 34, NULL, 'view', '2026-07-28 17:31:16'),
(196, 52, NULL, 'view', '2026-07-29 09:35:33'),
(197, 52, NULL, 'view', '2026-07-29 09:35:40'),
(198, 72, NULL, 'view', '2026-07-29 12:35:30'),
(199, 62, NULL, 'view', '2026-07-29 19:10:33'),
(200, 76, NULL, 'view', '2026-07-29 19:53:15'),
(201, 72, NULL, 'view', '2026-07-29 19:53:32'),
(202, 72, NULL, 'view', '2026-07-29 19:54:24'),
(203, 50, NULL, 'view', '2026-07-29 19:54:39'),
(204, 43, NULL, 'view', '2026-07-29 19:55:08'),
(205, 31, NULL, 'view', '2026-07-29 19:55:13'),
(206, 72, NULL, 'view', '2026-07-29 23:54:09'),
(207, 78, 1, 'view', '2026-07-31 20:41:16'),
(208, 64, NULL, 'view', '2026-07-31 22:38:05');

-- --------------------------------------------------------

--
-- Table structure for table `property_stats`
--

CREATE TABLE `property_stats` (
  `property_id` bigint(20) UNSIGNED NOT NULL,
  `views_total` int(11) DEFAULT 0,
  `leads_total` int(11) DEFAULT 0,
  `last_viewed_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `property_stats`
--

INSERT INTO `property_stats` (`property_id`, `views_total`, `leads_total`, `last_viewed_at`) VALUES
(21, 1, 0, '2026-07-10 13:53:24'),
(22, 1, 0, '2026-07-09 23:31:19'),
(23, 2, 0, '2026-07-10 05:37:45'),
(26, 5, 0, '2026-07-15 02:56:40'),
(28, 1, 0, '2026-07-11 01:33:36'),
(30, 5, 0, '2026-07-10 10:59:43'),
(31, 2, 0, '2026-07-29 19:55:13'),
(32, 1, 0, '2026-07-21 02:08:28'),
(33, 3, 0, '2026-07-09 19:59:45'),
(34, 2, 0, '2026-07-28 17:31:16'),
(35, 11, 2, '2026-07-10 14:28:00'),
(38, 1, 0, '2026-07-11 04:40:16'),
(39, 4, 0, '2026-07-12 09:52:49'),
(40, 1, 0, '2026-07-10 12:57:36'),
(41, 1, 0, '2026-07-11 23:32:16'),
(42, 2, 0, '2026-07-10 09:48:27'),
(43, 2, 0, '2026-07-29 19:55:08'),
(44, 1, 0, '2026-04-30 00:15:03'),
(45, 1, 0, '2026-05-13 13:00:13'),
(46, 3, 0, '2026-07-05 15:16:09'),
(48, 7, 0, '2026-07-12 03:39:40'),
(49, 1, 0, '2026-05-20 18:40:50'),
(50, 10, 0, '2026-07-29 19:54:39'),
(51, 2, 0, '2026-07-10 09:30:13'),
(52, 2, 0, '2026-07-29 09:35:40'),
(53, 1, 0, '2026-07-10 11:53:34'),
(54, 3, 0, '2026-07-10 01:58:23'),
(55, 5, 0, '2026-07-16 22:11:21'),
(56, 4, 0, '2026-07-10 07:33:54'),
(57, 4, 0, '2026-05-20 17:43:17'),
(58, 4, 0, '2026-07-18 23:17:51'),
(59, 2, 0, '2026-06-12 00:23:39'),
(60, 5, 0, '2026-06-29 21:40:49'),
(61, 4, 0, '2026-07-10 16:18:21'),
(62, 8, 0, '2026-07-29 19:10:33'),
(63, 3, 0, '2026-07-14 17:08:49'),
(64, 38, 0, '2026-07-31 22:38:05'),
(65, 6, 0, '2026-07-27 15:34:09'),
(66, 2, 0, '2026-07-09 19:38:40'),
(68, 1, 0, '2026-05-14 22:54:40'),
(71, 1, 0, '2026-05-20 17:32:01'),
(72, 6, 0, '2026-07-29 23:54:09'),
(73, 1, 0, '2026-07-10 08:54:59'),
(75, 10, 1, '2026-07-14 17:07:24'),
(76, 6, 0, '2026-07-29 19:53:15'),
(78, 8, 0, '2026-07-31 20:41:16');

-- --------------------------------------------------------

--
-- Table structure for table `property_subtypes`
--

CREATE TABLE `property_subtypes` (
  `id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `slug` varchar(100) NOT NULL,
  `icon_class` varchar(50) DEFAULT NULL,
  `sort_order` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `property_subtypes`
--

INSERT INTO `property_subtypes` (`id`, `category_id`, `name`, `slug`, `icon_class`, `sort_order`) VALUES
(1, 1, 'House', 'house', 'ph-house', 1),
(2, 1, 'Flat', 'flat', 'ph-buildings', 2),
(3, 1, 'Upper Portion', 'upper-portion', 'ph-stairs', 3),
(4, 1, 'Lower Portion', 'lower-portion', 'ph-stairs', 4),
(5, 1, 'Farm House', 'farm-house', 'ph-tree', 5),
(6, 1, 'Room', 'room', 'ph-door', 6),
(7, 1, 'Penthouse', 'penthouse', 'ph-stack', 7),
(8, 2, 'Residential Plot', 'residential-plot', 'ph-map-pin', 1),
(9, 2, 'Commercial Plot', 'commercial-plot', 'ph-buildings', 2),
(10, 2, 'Agricultural Land', 'agricultural-land', 'ph-leaf', 3),
(11, 2, 'Industrial Land', 'industrial-land', 'ph-factory', 4),
(12, 3, 'Office', 'office', 'ph-briefcase', 1),
(13, 3, 'Shop', 'shop', 'ph-storefront', 2),
(14, 3, 'Warehouse', 'warehouse', 'ph-warehouse', 3),
(15, 3, 'Building', 'building', 'ph-buildings', 4),
(16, 1, 'test', 'test', 'ph-house-line', 0);

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `id` int(11) NOT NULL,
  `role_name` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`id`, `role_name`) VALUES
(1, 'admin'),
(2, 'agency_owner'),
(3, 'agent'),
(5, 'buyer'),
(4, 'seller');

-- --------------------------------------------------------

--
-- Table structure for table `saved_properties`
--

CREATE TABLE `saved_properties` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `property_id` bigint(20) UNSIGNED NOT NULL,
  `saved_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `site_settings`
--

CREATE TABLE `site_settings` (
  `id` int(11) NOT NULL,
  `setting_key` varchar(100) DEFAULT NULL,
  `setting_value` text DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `temp_mig_props_full`
--

CREATE TABLE `temp_mig_props_full` (
  `id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `slug` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `purpose` varchar(50) DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  `city_id` int(11) DEFAULT NULL,
  `sub_category` varchar(50) DEFAULT NULL,
  `portion` varchar(50) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `locality` varchar(100) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `price` decimal(15,2) DEFAULT NULL,
  `price_type` varchar(50) DEFAULT NULL,
  `area_size` decimal(10,2) DEFAULT NULL,
  `area_unit` varchar(50) DEFAULT NULL,
  `bedrooms` int(11) DEFAULT NULL,
  `bathrooms` int(11) DEFAULT NULL,
  `kitchens` int(11) DEFAULT NULL,
  `parking_spaces` int(11) DEFAULT NULL,
  `floors` int(11) DEFAULT NULL,
  `furnished` varchar(50) DEFAULT NULL,
  `plot_card_type` varchar(50) DEFAULT NULL,
  `plot_number` varchar(50) DEFAULT NULL,
  `possession_status` varchar(50) DEFAULT NULL,
  `corner_plot` tinyint(1) DEFAULT NULL,
  `boundary_wall` tinyint(1) DEFAULT NULL,
  `floor_level` varchar(50) DEFAULT NULL,
  `covered_area` decimal(10,2) DEFAULT NULL,
  `business_type` varchar(100) DEFAULT NULL,
  `maintenance_fee` decimal(10,2) DEFAULT NULL,
  `elevator` tinyint(1) DEFAULT NULL,
  `contact_name` varchar(100) DEFAULT NULL,
  `contact_phone` varchar(20) DEFAULT NULL,
  `contact_email` varchar(100) DEFAULT NULL,
  `show_phone` tinyint(1) DEFAULT NULL,
  `poster_type` varchar(50) DEFAULT NULL,
  `estate_name` varchar(255) DEFAULT NULL,
  `estate_address` text DEFAULT NULL,
  `video_url` varchar(255) DEFAULT NULL,
  `tour_url` varchar(255) DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  `is_featured` tinyint(1) DEFAULT NULL,
  `views` int(11) DEFAULT NULL,
  `listing_start_date` date DEFAULT NULL,
  `listing_end_date` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `temp_mig_props_full`
--

INSERT INTO `temp_mig_props_full` (`id`, `user_id`, `title`, `slug`, `description`, `purpose`, `category_id`, `city_id`, `sub_category`, `portion`, `city`, `locality`, `address`, `latitude`, `longitude`, `price`, `price_type`, `area_size`, `area_unit`, `bedrooms`, `bathrooms`, `kitchens`, `parking_spaces`, `floors`, `furnished`, `plot_card_type`, `plot_number`, `possession_status`, `corner_plot`, `boundary_wall`, `floor_level`, `covered_area`, `business_type`, `maintenance_fee`, `elevator`, `contact_name`, `contact_phone`, `contact_email`, `show_phone`, `poster_type`, `estate_name`, `estate_address`, `video_url`, `tour_url`, `status`, `is_featured`, `views`, `listing_start_date`, `listing_end_date`, `created_at`, `updated_at`) VALUES
(21, 1, 'Flat Is Available For Sale', 'flat-is-available-for-sale', '1800sqft\r\n Modern 2-Bedroom Apartment Featuring A Spacious Living Area,\r\n Well-Designed Bedrooms,\r\n A Contemporary Kitchen, And Stylish Bathrooms. Ideal For Comfortable Living In A Prime Location. \r\n High-demand category ideal for couples, small families, or short-term rental ROI\r\n Located in Emaar Oceanfront, offering unmatched seafront lifestyle\r\n Consistent rental demand with strong returns\r\n Secure & premium community living\r\n Community Features (Emaar Oceanfront):\r\n Private Beach Access for residents\r\n Infinity Swimming Pool, Gym, Sauna & Jacuzzi\r\n Childrens Play Areas, Parks & Gardens\r\n 24/7 Security & CCTV Surveillance\r\n Retail, Cafs & Lifestyle Outlets within community\r\n High-speed elevators & modern infrastructure\r\n Well-maintained & family-friendly environment\r\n Highlights:\r\n Pool + Sea facing unit one of the most desirable views\r\n Prime location in Coral Tower 1 Emaar Oceanfront\r\n Ready to move in secure your investment today!\r\n For Immediate Deal & Viewing:', 'Sale', 1, 11, 'Apartment', NULL, 'Karachi', '', '', NULL, NULL, 54000000.00, 'Negotiable', 200.00, 'Sq.yd', 2, 2, 1, 1, NULL, 'No', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, 0.00, 0, 'ARISH SHAH AU Group of Companies', '+923226392692', '', 1, 'user', NULL, NULL, '', NULL, 'Approved', 0, 78, '2026-01-07', '2026-01-30', '2026-01-06 15:46:30', '2026-04-28 18:59:53'),
(22, 1, 'Prime Location Emaar Pearl Towers House Sized 300 Square Yards For sale', 'prime-location-emaar-pearl-towers-house-sized-300-square-yards-for-sale', 'The demand price is set pretty reasonably at Rs. 82500000. For a luxurious lifestyle, you can check out properties in Karachi. Book your 300 Square Yards House today to mark the beginning of your prosperous future. You can be the owner of your dream home, with this beautiful House available for sale. All the routine facilities are at a close reach from the Houses in Emaar Pearl Towers. Ideally located on Emaar Pearl Towers, this is a rare and golden real estate opportunity. ', 'Sale', 1, 11, 'Apartment', NULL, 'Karachi', 'Clifton', 'Emaar Pearl Towers, Emaar Crescent Bay, DHA Phase 8, DHA Defence, Karachi, Sindh', NULL, NULL, 87000000.00, 'Negotiable', 300.00, 'Sq.yd', 2, 2, 1, 1, 5, 'Yes', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, 0.00, 0, 'Ali Raza', '03001234567', 'admin@gmail.com', 1, 'user', NULL, NULL, '', NULL, 'Approved', 0, 56, '2026-01-09', '2026-03-25', '2026-01-09 11:59:11', '2026-04-29 05:31:08'),
(23, 1, 'Prime Location Emaar Coral Towers House', 'prime-location-emaar-coral-towers-house', 'If you have a budget of Rs. 69000000, here is the listing you must explore. Looking for a well-constructed home for your family? This can be the best option for you. Want the perfect space and a good bargain? Look no further for we give you the tools necessary to make all 250 Square Yards of this property your next place. You can find the best properties in Emaar Coral Towers. The city of Karachi is developing fast and you can find some really good property deals. A House that is located in the prime location like this one is no less than an opportunity. ', 'Sale', 1, 11, 'Apartment', NULL, 'Karachi', 'DHA Phase 8, DHA Defence, Karachi, Sindh', 'Emaar Coral Towers, Emaar Crescent Bay, DHA Phase 8, DHA Defence, Karachi, Sindh', NULL, NULL, 75000000.00, 'Negotiable', 250.00, 'Sq.yd', 3, 2, 1, 1, 5, 'Yes', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, 0.00, 0, 'Sadat Salik', '03456789123', 'admin@gmail.com', 1, 'user', NULL, NULL, '', NULL, 'Approved', 0, 69, '2026-03-24', '2026-03-30', '2026-01-09 12:47:55', '2026-04-27 14:17:50'),
(26, 1, 'House for Sale ', 'house-for-sale', 'Amazing house west open Amazing house west open Amazing house west open Amazing house west open ', 'Sale', 1, 11, 'House', NULL, 'Karachi', 'Bahria Town', 'street 13', NULL, NULL, 25000000.00, 'Negotiable', 120.00, 'Sq.yd', 2, 2, 1, 1, 2, 'No', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, 0.00, 0, 'Haris Khan', '03001234567', 'admin@gmail.com', 1, 'user', NULL, NULL, '', NULL, 'Approved', 0, 77, '2026-01-13', '2026-01-30', '2026-01-13 03:11:24', '2026-04-29 00:21:26'),
(27, 1, 'House Available for sale west open near masjd', 'house-available-for-sale-west-open-near-masjd', 'House Available for sale west open near masjdHouse Available for sale west open near masjdHouse Available for sale west open near masjdHouse Available for sale west open near masjdHouse Available for sale west open near masjdHouse Available for sale west open near masjdHouse Available for sale west open near masjdHouse Available for sale west open near masjdHouse Available for sale west open near masjdHouse Available for sale west open near masjd', 'Sale', 1, 11, 'Apartment', NULL, 'Karachi', 'North Nazimabad', 'Block B 14 street', NULL, NULL, 3500000.00, 'Negotiable', 400.00, 'Sq.yd', 4, 4, 1, 2, 1, 'Yes', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, 0.00, 0, 'Saud Mirza', '03451234567', 'admin@gmail.com', 1, 'user', NULL, NULL, '', NULL, 'Approved', 0, 65, '2026-01-13', '2026-04-30', '2026-01-13 03:38:17', '2026-04-27 08:03:03'),
(28, 1, 'Beautiful house available for sale ', 'beautiful-house-available-for-sale', 'Beautiful house available for sale Beautiful house available for sale Beautiful house available for sale Beautiful house available for sale ', 'Sale', 1, 16, 'House', NULL, 'Islamabad', 'North Nazimabad', 'Block N', NULL, NULL, 3000000.00, 'Fixed', 120.00, 'Sq.yd', 2, 2, 1, 1, 2, 'Yes', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, 0.00, 0, 'Saud Khan', '03001233214', 'admin@gmail.com', 1, 'user', NULL, NULL, '', NULL, 'Approved', 0, 82, '2026-01-14', '2026-02-28', '2026-01-14 03:38:44', '2026-04-28 17:00:37'),
(30, 19, 'house Available for sell', 'house-available-for-sell', 'House Available for sell House Available for sell House Available for sell House Available for sell House Available for sell House Available for sell', 'Sale', 1, 11, 'House', NULL, 'Karachi', 'North Nazimabad', '', NULL, NULL, 25000000.00, 'Negotiable', 240.00, 'Sq.yd', 2, 2, 1, 2, 1, NULL, NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, 0.00, 0, 'Daniyal Ahmed', '03002312268', 'admin@gmail.com', 1, 'user', NULL, NULL, '', NULL, 'Approved', 0, 71, '2026-01-17', '2026-02-16', '2026-01-17 02:34:16', '2026-04-27 16:43:42'),
(31, 1, 'house for rent in near airport', 'house-for-rent-in-near-airport', '5 km meter from airport westopen no utlity issue 5 km meter from airport westopen no utlity issue5 km meter from airport westopen no utlity issue  5 km meter from airport westopen no utlity issue', 'Rent', 1, 11, 'House', NULL, 'Karachi', 'North Nazimabad', '', NULL, NULL, 220000.00, 'Negotiable', 600.00, 'Sq.yd', 2, 2, 1, 2, 2, 'No', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, 0.00, 0, 'Noman Ejaz', '03002312321', 'admin@gmail.com', 1, 'user', NULL, NULL, NULL, NULL, 'Approved', 1, 152, '2026-01-17', '2026-02-16', '2026-01-17 02:43:23', '2026-04-27 16:29:22'),
(32, 19, 'House Available for Sale 160sq.yd', 'house-available-for-sale-160sq-yd', 'House available for sell west open ', 'Sale', 1, 11, 'House', NULL, 'Karachi', 'Naya Nazimabad', '', NULL, NULL, 40000000.00, 'Fixed', 160.00, 'Sq.yd', 3, 3, 1, 1, 2, 'No', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, 0.00, 0, 'Noman Ejaz', '03038611893', 'Nomanejaz@gmail.com', 1, 'user', NULL, NULL, '', NULL, 'Approved', 0, 72, '2026-01-17', '2026-02-16', '2026-01-17 04:01:48', '2026-04-27 13:01:17'),
(33, 1, 'House Availble for Sell', 'house-availble-for-sell', 'House Availble for sell west side house for sale on the corner by a friend and a neighbor.', 'Sale', 1, 11, '', NULL, 'Karachi', 'Naya Nazimabad', '', NULL, NULL, 35000000.00, 'Negotiable', 120.00, 'Sq.yd', 2, 2, 1, 2, 2, 'Yes', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, 0.00, 0, 'Noman Ejaz', '03038611893', 'admin@gmail.com', 1, 'user', NULL, NULL, '', NULL, 'Approved', 1, 84, '2026-01-17', '2026-02-16', '2026-01-17 07:00:17', '2026-04-25 03:41:07'),
(34, 20, 'Banglow For Sale ', 'banglow-for-sale', '120Sq yrd+extra land \r\nWest Open \r\n60ft Road\r\nBlock A ideal location \r\nLavish Construction 💕', 'Sale', 1, 11, 'House', NULL, 'Karachi', 'Naya Nazimabad ', 'Block A ', NULL, NULL, 44500000.00, 'Negotiable', 120.00, 'Sq.yd', 5, 5, 1, 2, 2, 'No', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, 0.00, 0, 'Bilal khan ', '03362175091', 'bilalzai5678@gmail.com', 1, 'user', NULL, NULL, NULL, NULL, 'Approved', 0, 68, '2026-01-20', '2026-02-19', '2026-01-20 09:12:00', '2026-04-28 09:03:46'),
(35, 20, 'Commercial plot Naya Nazimabad ', 'commercial-plot-naya-nazimabad', '230Sq yrd Commercial plot in Naya Nazimabad Boundary wall Society located Block A near to Gymkhana opportunity for Builders investors ', 'Sale', 2, 11, 'Office', NULL, 'Karachi', 'Naya Nazimabad ', 'Block A ', NULL, NULL, 92000000.00, 'Fixed', 230.00, 'Sq.yd', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, '3rd+', NULL, NULL, 0.00, 0, 'Bilal khan ', '03362175091', 'bilalzai5678@gmail.com', 1, 'user', NULL, NULL, '', NULL, 'Approved', 0, 72, '2026-01-20', '2026-02-19', '2026-01-20 16:50:34', '2026-04-28 00:45:00'),
(37, 1, 'House Availble for Sell', 'house-availble-for-sell-1769015638', 'House available for sell west open american style kitchen spacious house. House available for sell west open american style kitchen spacious house. House available for sell west open american style kitchen spacious house.', 'Sale', 1, 11, 'House', NULL, 'Karachi', 'North Nazimabad', '', NULL, NULL, 60000000.00, 'Negotiable', 400.00, 'Sq.yd', 6, 5, 2, 2, 2, 'Yes', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, 0.00, 0, 'Haris Khan', '030023212245', 'admin@gmail.com', 1, 'user', NULL, NULL, '', NULL, 'Approved', 1, 75, '2026-01-21', '2026-02-20', '2026-01-21 11:45:32', '2026-04-27 01:22:58'),
(38, 1, 'House Available for sell in North Nazimabad', 'house-available-for-sell-in-north-nazimabad', 'House Available for sell in North Nazimabad. House Available for sell in North Nazimabad. House Available for sell in North Nazimabad', 'Sale', 1, 11, 'House', NULL, 'Karachi', 'North Nazimabad', '', NULL, NULL, 80000000.00, 'Negotiable', 400.00, 'Sq.yd', 5, 4, 2, 4, 2, 'Yes', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, 0.00, 0, 'Haris Khan', '03002312267', 'admin@gmail.com', 1, 'user', NULL, NULL, '', NULL, 'Approved', 1, 79, '2026-01-21', '2026-02-20', '2026-01-21 12:23:45', '2026-04-27 12:34:24'),
(39, 1, 'Flat Available For sale ', 'flat-available-for-sale', 'Flat Available for sale in main road area. Flat Available for sale in main road area. Flat Available for sale in main road area. Flat Available for sale in main road area.', 'Sale', 1, 11, 'House', NULL, 'Karachi', 'Naya Nazimabad', '', NULL, NULL, 55000000.00, 'Negotiable', 400.00, 'Sq.yd', 4, 4, 2, 2, 2, 'Yes', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, 0.00, 0, 'Kazim Ali', '0345457891', 'admin@gmail.com', 1, 'user', NULL, NULL, '', NULL, 'Approved', 1, 87, '2026-01-21', '2026-02-20', '2026-01-21 12:32:24', '2026-04-27 08:44:31'),
(40, 1, 'Plot Available for sell in west zone area', 'plot-available-for-sell-in-west-zone-area', 'Plot Available for sell in west zone area,Plot Available for sell in west zone area. Plot Available for sell in west zone area Plot Available for sell in west zone area.', 'Sale', 1, 11, 'House', NULL, 'Karachi', 'Naya Nazimabad Block \'D\'', '', NULL, NULL, 46500000.00, 'Negotiable', 240.00, 'Sq.yd', 4, 4, 2, 2, 2, 'Yes', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, 0.00, 0, 'Saud Mirza', '03212314576', 'admin@gmail.com', 1, 'user', NULL, NULL, '', NULL, 'Approved', 1, 94, '2026-01-21', '2026-02-20', '2026-01-21 12:40:35', '2026-04-24 06:20:00'),
(41, 1, 'Amazing house available for sale ', 'amazing-house-available-for-sale', 'Amazing house available for sale Amazing house available for sale Amazing house available for sale Amazing house available for sale Amazing house available for sale Amazing house available for sale ', 'Sale', 1, 11, 'House', NULL, 'Karachi', 'North Nazimabad', '', NULL, NULL, 55000000.00, 'Negotiable', 240.00, 'Sq.yd', 4, 2, 1, NULL, NULL, 'No', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, 0.00, 0, 'Asad Kumail', '03457863459', 'admin@gmail.com', 1, 'user', NULL, NULL, '', NULL, 'Approved', 1, 106, '2026-01-21', '2026-02-20', '2026-01-21 12:48:26', '2026-04-24 15:11:51'),
(42, 1, 'Amazing flat available for sale ', 'amazing-flat-available-for-sale', 'Amazing flat available for sale. Amazing flat available for sale. Amazing flat available for sale', 'Sale', 1, 11, 'House', NULL, 'Karachi', 'Defence', '', NULL, NULL, 75000000.00, 'Negotiable', 1600.00, 'Sq.ft', 3, 3, 2, 2, 2, 'Yes', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, 0.00, 0, 'Daniyal Ali', '03213456324', 'admin@gmail.com', 1, 'user', NULL, NULL, '', NULL, 'Approved', 1, 109, '2026-01-21', '2026-02-20', '2026-01-21 13:11:22', '2026-04-29 00:12:54'),
(43, 1, 'House available for rent west open full utilty no water gas issue', 'house-available-for-rent-west-open-full-utilty-no-water-gas-issue', 'House available for rent west open full utilty no water gas issueHouse available for rent west open full utilty no water gas issueHouse available for rent west open full utilty no water gas issueHouse available for rent west open full utilty no water gas issue', 'Rent', 1, 11, 'Apartment', NULL, 'Karachi', 'Clifton', '', NULL, NULL, 450000.00, 'Negotiable', 1400.00, 'Sq.ft', 4, 3, 1, 2, NULL, 'Yes', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, 0.00, 0, 'Noman Ali', '032145364321', 'admin@gmail.com', 1, 'user', NULL, NULL, NULL, NULL, 'Approved', 1, 184, '2026-01-21', '2026-02-20', '2026-01-21 13:18:10', '2026-04-28 19:22:58'),
(44, 1, 'House available for rent west open full utilty no water gas issue', 'house-available-for-rent-west-open-full-utilty-no-water-gas-issue-1769019673', 'House available for rent west open full utilty no water gas issueHouse available for rent west open full utilty no water gas issue', 'Sale', 2, 16, 'Shop', NULL, 'Islamabad', 'DHA Phase 8, DHA Defence, Karachi, Sindh', '', NULL, NULL, 35000000.00, 'Fixed', 300.00, 'Sq.yd', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, '2nd', 1400.00, 'Cafe', 5000.00, 1, 'Fahad Khan', '03458674523', 'admin@gmail.com', 1, 'user', NULL, NULL, '', NULL, 'Approved', 1, 128, '2026-01-21', '2026-02-20', '2026-01-21 13:21:13', '2026-04-27 21:27:25'),
(45, 1, 'House available for sale west open full utilty no water gas issue', 'house-available-for-sale-west-open-full-utilty-no-water-gas-issue', 'House available for rent west open full utilty no water gas issueHouse available for rent west open full utilty no water gas issue', 'Sale', 1, 18, 'House', NULL, 'Hyderabad', 'DHA', '', NULL, NULL, 45000000.00, 'Negotiable', 120.00, 'Sq.yd', 4, 3, 1, 2, 2, 'Yes', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, 0.00, 0, 'Zubair Shiekh', '03452314537', 'admin@gmail.com', 1, 'user', NULL, NULL, '', NULL, 'Approved', 1, 133, '2026-01-21', '2026-02-20', '2026-01-21 13:27:03', '2026-04-27 12:28:22'),
(46, 23, 'House Available for Sell', 'house-available-for-sell-1769095524', '120sq one unit benglow brand new block C Naya nazimabad masque facing brand new benglow', 'Sale', 1, 11, 'House', NULL, 'Karachi', 'Naya nazimabad ', '', NULL, NULL, 3700000.00, 'Negotiable', 120.00, 'Sq.yd', 5, 5, 2, NULL, 1, 'No', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, 0.00, 0, 'Danish', '03333458003', 'danishmasood537@gmail.com', 1, 'user', NULL, NULL, '', NULL, 'Approved', 0, 142, '2026-01-22', '2026-02-21', '2026-01-22 09:43:12', '2026-04-26 23:25:48'),
(47, 1, 'House Available for sell', 'house-available-for-sell-1771043056', 'A brand new, beautifully constructed luxury bungalow is available for sale in the prime location of Naya Nazimabad, This property has been built with high-class materials and modern design, making it an ideal choice for comfortable family living and smart investment.\r\nProperty Details & Features:\r\nPlot Size: 120 Square Yards\r\nWest Open Bungalow\r\nT-Facing\r\nNear Masjid\r\nNear Commercial Area\r\nElegant Class A Finishing Premium Luxury Tile Work\r\nWell-planned layout with modern elevation\r\nPeaceful & secure neighborhood\r\nIdeal for residential living as well as future value\r\nThis bungalow offers a perfect blend of luxury, location, and quality construction. Serious buyers are encouraged to contact for further details and site visit.', 'Sale', 1, 11, 'House', NULL, 'Karachi', 'Naya Nazimabad', NULL, NULL, NULL, 55000000.00, 'Fixed', 160.00, 'Sq.yd', 4, 2, 1, 2, 2, 'No', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, 0.00, 0, 'admin', '03212312258', 'admin@gmail.com', 1, 'user', NULL, NULL, NULL, NULL, 'Sold', 1, 28, '2026-01-28', '2026-02-27', '2026-01-28 11:52:24', '2026-02-13 23:24:16'),
(48, 1, 'Exquisite Bungalow for Sale in Naya Nazimabad!', 'exquisite-bungalow-for-sale-in-naya-nazimabad', 'Discover comfort and elegance in our move-in ready bungalow at the heart of Naya Nazimabad. With a prime location and stunning view, experience the best of modern living effortlessly. ✨ Features: 🏠 Move-In Ready: No waiting, it\'s ready to be your home. 📍 Prime Location: Close to everything you need.  Vibrant energy right around the corner. 🛋️ Spacious Interior: Comfortable living spaces for your family. 🏡 Modern Design: Stylish and functional. 🌟 ', 'Sale', 1, 11, 'House', NULL, 'Karachi', 'Naya Nazimabad, Block C.', NULL, NULL, NULL, 55000000.00, 'Fixed', 120.00, 'Sq.yd', 3, 3, 1, 2, 2, 'Semi-furnished', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, 0.00, 0, 'admin', '03180252772', 'admin@gmail.com', 1, 'user', NULL, NULL, NULL, NULL, 'Approved', 1, 212, '2026-02-06', '2026-03-08', '2026-02-06 11:28:49', '2026-04-29 06:27:36'),
(49, 25, 'Brand New Banglow For Sale In Naya Nazimabad Block A', 'brand-new-banglow-for-sale-in-naya-nazimabad-block-a', 'Brand New Banglow For Sale In Naya Nazimabad Block A\r\n40 Feet Road \r\nCross West Open \r\nNear To Main Gate \r\nNear To Park \r\nNear To Masjid ', 'Sale', 1, 11, 'House', NULL, 'Karachi', 'Naya Nazimabad Block A', NULL, NULL, NULL, 40000000.00, 'Fixed', 120.00, 'Sq.yd', 5, 5, 2, NULL, 1, 'Semi-furnished', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, 0.00, 0, 'waleediqbal12', '03132286920', 'albertfinch8@gmail.com', 1, 'user', NULL, NULL, NULL, NULL, 'Approved', 0, 98, '2026-02-17', '2026-03-19', '2026-02-17 09:04:42', '2026-04-27 22:40:15'),
(50, 20, 'Banglow For Rent ', 'banglow-for-rent', 'Banglow For Rent \r\n120sa yrd\r\nOne unit independent ', 'Rent', 1, 11, 'House', NULL, 'Karachi', 'Naya Nazimabad ', NULL, NULL, NULL, 120000.00, 'Fixed', 120.00, 'Sq.yd', 4, 4, 2, NULL, NULL, 'No', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, 0.00, 0, 'Bilalkhanzai', '03362175091', 'bilalzai5678@gmail.com', 1, 'user', NULL, NULL, NULL, NULL, 'Approved', 0, 111, '2026-02-21', '2026-03-23', '2026-02-21 16:03:03', '2026-04-28 19:13:32'),
(51, 1, 'HOUSE FOR SALE BAHRIA TOWN LAHORE', 'house-for-sale-bahria-town-lahore', '10 MARLA BRAND NEW HOUSE \r\nFOR SALE BAHRIA TOWN LAHORE\r\n👉 Hot Location \r\n👉 Near Park\r\n👉 Near Main Road\r\n👉 Accommodation\r\n▪️5 Bedroom\'s 🛏️ \r\n▪️2 Kitchen 🍱\r\n▪️2 TV Launch 📺\r\n▪️7 Bathroom 🛁', 'Sale', 1, 15, 'House', NULL, 'Lahore', 'BAHRIA TOWN LAHORE', NULL, NULL, NULL, 120000000.00, 'Fixed', 1.00, 'Kanal', 6, 4, 2, 4, 2, 'Yes', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, 0.00, 0, 'Mudassar Khokhar', '0301 4806133', 'MudassarKhokhar@gmail.com', 1, 'user', NULL, NULL, NULL, NULL, 'Approved', 1, 114, '2026-02-22', '2026-03-24', '2026-02-22 11:39:34', '2026-04-28 09:14:41'),
(52, 1, 'Brand new 120 yds house for sale in PS CITY 1 Scheme 33.', 'brand-new-120-yds-house-for-sale-in-ps-city-1-scheme-33', 'Ground + 1, west open .Near to Park and masjid .\r\nGated society . 24 hrs Security.\r\nNo loadshedding .\r\nSweet water .\r\nIdeal location with peacefully & educated families around.', 'Sale', 1, 11, 'House', NULL, 'Karachi', 'PS CITY 1 Scheme 33', NULL, NULL, NULL, 35000000.00, 'Fixed', 120.00, 'Sq.yd', 4, 4, 2, 2, 2, 'No', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, 0.00, 0, 'Alps Constructions', '0301-2191274', 'alphs@gmail.com', 1, 'user', NULL, NULL, NULL, NULL, 'Approved', 1, 117, '2026-02-22', '2026-03-24', '2026-02-22 13:24:23', '2026-04-26 13:07:01'),
(53, 1, 'Luxury Bungalow for Sale in DHA Lahor', 'luxury-bungalow-for-sale-in-dha-lahor', 'Welcome to this stunning, brand-new luxury bungalow located in the heart of DHA Lahore. Designed with elegance and comfort in mind, this exceptional property offers a perfect blend of modern architecture, premium features, and a secure environment for your family.\r\n\r\nSpread over 1000 square yards, this bungalow includes 2 grand master bedrooms and 4 additional bedrooms ideal for family members and guests. The double-door basement provides ample storage space and added security. A private swimming pool and in-house lift enhance the luxurious lifestyle this home offers.\r\n\r\nThis is a rare opportunity to own a dream home in one of Karachi’s most prestigious neighborhoods.\r\n', 'Sale', 1, 15, 'House', NULL, 'Lahore', 'DHA, Lahore.', NULL, NULL, NULL, 130000000.00, 'Fixed', 1000.00, 'Sq.yd', 6, 6, 2, 4, 2, 'No', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, 0.00, 0, 'Al Razzaq Associates', '0321345679', 'AlRazzaq@gmail.com', 1, 'user', NULL, NULL, NULL, NULL, 'Approved', 1, 121, '2026-02-22', '2026-03-24', '2026-02-22 13:34:48', '2026-04-28 15:15:50'),
(54, 1, 'House for Sale – 5 Marla (Half Triple Story)', 'house-for-sale-5-marla-half-triple-story', 'A beautifully designed and well-maintained house located in a prime residential area of Al Hafeez Phase 5.\r\n Ideal for families looking for comfort, space, and modern living.\r\n🏠 Property Features:\r\n4 Spacious Bedrooms\r\n5 Modern Washrooms\r\n2 Master Kitchens\r\n2 Lounges (Including 1 Master Lounge)\r\nWalk-in Closet\r\nPorch Space for Full SUV\r\nOpen Area at Back (Washing Area)\r\nOpen Area at Front\r\nRoof with Proper BBQ & Sitting Area\r\n✔ Solid construction\r\n✔ Practical layout\r\n✔ Peaceful residential environment', 'Sale', 1, 15, 'House', NULL, 'Lahore', 'Al Hafeez Phase 5.', NULL, NULL, NULL, 75000000.00, 'Fixed', 400.00, 'Sq.yd', 4, 4, 2, 2, 2, 'Yes', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, 0.00, 0, 'Al Rehman Developers', ' 03247936559', '', 1, 'user', NULL, NULL, NULL, NULL, 'Approved', 1, 118, '2026-03-01', '2026-03-31', '2026-03-01 13:35:20', '2026-04-26 08:03:38'),
(55, 1, '2 Kanal Royal Castle for Sale ', '2-kanal-royal-castle-for-sale', 'Property Details:\r\nDesign: Spanish+Classical style architecture with timeless elegance and modern functionality.Bedrooms: 7, Swimming Pool, Home Theater, Advanced Kitchen, Triple-Height Drawing Rooms & Lobby, Fully Furnished, Solid Construction, Mesmerizing Views,\r\nFor Inquiries or to Schedule a Visit \r\nAHDL3900 Contact us.\r\nDon’t miss the opportunity to own your dream home!\r\n𝐏𝐑𝐎𝐕𝐈𝐃𝐈𝐍𝐆 𝐒𝐄𝐑𝐕𝐈𝐂𝐄𝐒 𝐀𝐋𝐋 𝐎𝐕𝐄𝐑 𝐏𝐀𝐊𝐈𝐒𝐓𝐀𝐍!\r\nReal Estate | Architecture | Construction | Interior Design | Construction & Project Management Consultants\r\n#Architecture #interior #modernhome #dhalahore #newlisting #dha #pakistan #karachi #lahore ', 'Sale', 1, 15, 'House', NULL, 'Lahore', 'Lahore', NULL, NULL, NULL, 260000000.00, 'Fixed', 2.00, 'Kanal', 7, 9, 2, 4, 2, 'Yes', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, 0.00, 0, 'My Dream House ', '+92 300 0520897', 'MyDreamHouse@gmail.com', 1, 'user', NULL, NULL, NULL, NULL, 'Approved', 1, 71, '2026-03-11', '2026-04-10', '2026-03-11 16:35:58', '2026-04-26 10:12:06'),
(56, 1, '666 Sq. Yards Luxury Villa – DHA Phase 8 (Zone A)', '666-sq-yards-luxury-villa-dha-phase-8-zone-a', 'Discover an exceptional 10,000+ sq. ft. designer villa located on a prime street in DHA Phase 8, thoughtfully designed for sophisticated and comfortable living.\r\nKey Features\r\n• Spacious basement with a private home theatre and games lounge\r\n• 5 luxurious bedrooms, including a master suite with private terrace\r\n• Modern Italian kitchens with premium finishes\r\n• Elegant poolside courtyard ideal for relaxation and gatherings\r\n• High-quality mahogany woodwork throughout the home\r\n• Premium Grohe & Roca fittings\r\n• Fully furnished with imported Turkish furniture\r\nA perfect blend of luxury, space, and contemporary architecture, offering an exclusive lifestyle in one of the most sought-after locations.\r\n📞 For Details & Private Viewing\r\nKHAWAJA ENTERPRISE\r\nBuilder | Contractor | Property Advisor\r\n📞 +92 0317 8222701\r\n📞 +92 0331 2342065\r\n📧 info@khawajaenterprise.net\r\n🌐 khawajaenterprise.net\r\n#KhawajaEnterprise #DHAPhase5 #DHAKarachi #UltraLuxury #KarachiRealEstate #EliteLiving #LuxuryEstate #1000Yards #HighNetWorth #PrimeProperty #dhacitytime #karachi', 'Sale', 1, 11, 'House', NULL, 'Karachi', 'DHA Phase 8, DHA Defence, Karachi, Sindh', NULL, NULL, NULL, 220000000.00, 'Fixed', 666.00, 'Sq.yd', 5, 6, 2, 4, 2, 'Yes', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, 0.00, 0, 'khawajaenterprise', '+92 0331 2342065', 'info@khawajaenterprise.net', 1, 'user', NULL, NULL, NULL, NULL, 'Approved', 1, 77, '2026-03-11', '2026-04-10', '2026-03-11 18:03:39', '2026-04-27 23:59:17'),
(57, 1, 'BRAND NEW  HOUSE FOR SALE IN DHA LAHORE', 'brand-new-house-for-sale-in-dha-lahore', 'Mudassar Khokhar - 0301 4806133\r\n💼 Available For Visit 💼\r\n🏬 Prime Location\r\n🛣️ Near Ring Road \r\n🕌 Near Masjid\r\n🛍️ Walking Distance to Shopping Mart & Market\r\n🏥 Close to Medical Store & Labs\r\n🍽️ Nearby Restaurants\r\n🏢 Surrounded by Offices & Companies\r\n🏫 Campus Nearby', 'Sale', 1, 11, 'House', NULL, 'Karachi', 'DHA LAHORE', NULL, NULL, NULL, 140000000.00, 'Fixed', 2.00, 'Marla', 6, 6, 1, 4, 2, 'Yes', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, 0.00, 0, 'Mudassar Khokhar', '+92-3014289340', 'Khokhar@gmail.com', 1, 'user', NULL, NULL, NULL, NULL, 'Approved', 1, 31, '2026-03-26', '2026-04-25', '2026-03-26 16:19:17', '2026-04-24 11:37:04'),
(58, 1, '2 Kanal Full Furnished House For Sale.', '2-kanal-full-furnished-house-for-sale', 'Luxury | Elegance | Prime Location\r\nListed by: Ikramullah (CEO – HousesStars Real Estate &Construction\r\nCALL 📞 0307-6089887\r\n🏢 Office Address:\r\n57-N Plaza, 4th Floor,\r\nDefence Raya Fairways Commercial\r\nSerious buyers contact now! 📞✨\r\n', 'Sale', 1, 11, 'House', NULL, 'Karachi', 'DHA Phase 6 Lahore', NULL, NULL, NULL, 125000000.00, 'Fixed', 2.00, 'Kanal', 6, 5, 1, 4, 2, 'Yes', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, 0.00, 0, 'Ikramullah ', '0307-6089887', 'Ikramullah@gmail.com', 1, 'user', NULL, NULL, NULL, NULL, 'Approved', 1, 35, '2026-03-26', '2026-04-25', '2026-03-26 16:37:55', '2026-04-25 14:23:42'),
(59, 1, 'BRAND NEW HOUSE FOR SALE IN DHA LAHORE', 'brand-new-house-for-sale-in-dha-lahore-1775006381', '💼 Available For Visit 💼\r\n🏬 Prime Location\r\n🛣️ Near Ring Road \r\n🕌 Near Masjid\r\n🛍️ Walking Distance to Shopping Mart & Market\r\n🏥 Close to Medical Store & Labs\r\n🍽️ Nearby Restaurants\r\n🏢 Surrounded by Offices & Companies\r\n🏫 Campus Nearby', 'Sale', 1, 15, 'House', NULL, 'Lahore', 'DHA LAHORE', NULL, NULL, NULL, 220000000.00, 'Fixed', 2.00, 'Kanal', 6, 5, 1, 2, 2, 'Yes', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, 0.00, 0, 'Mudassar Khokhar', '0301 4806133', 'MudassarKhokhar@gmail.com', 1, 'user', NULL, NULL, NULL, NULL, 'Approved', 1, 29, '2026-04-01', '2026-05-01', '2026-03-31 20:19:41', '2026-04-28 19:29:59'),
(60, 1, 'LAVISH NEW HOUSE FOR SALE IN DHA LAHORE', 'lavish-new-house-for-sale-in-dha-lahore', '💼 Available For Visit 💼\r\n🏬 Prime Location\r\n🛣️ Near Ring Road \r\n🕌 Near Masjid\r\n🛍️ Walking Distance to Shopping Mart & Market\r\n🏥 Close to Medical Store & Labs\r\n🍽️ Nearby Restaurants\r\n🏢 Surrounded by Offices & Companies\r\n🏫 Campus Nearby', 'Sale', 1, 15, 'House', NULL, 'Lahore', 'DHA LAHORE', NULL, NULL, NULL, 240000000.00, 'Fixed', 2.00, 'Kanal', 6, 5, 1, 2, 2, 'Yes', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, 0.00, 0, 'Mudassar Khokhar', '0301 4806133', 'MudassarKhokhar@gmail.com', 1, 'user', NULL, NULL, NULL, NULL, 'Approved', 1, 32, '2026-04-01', '2026-05-01', '2026-03-31 20:30:29', '2026-04-28 19:44:05'),
(61, 1, 'Experience luxury living in this premium property', 'experience-luxury-living-in-this-premium-property', 'Live steps away from Giga Mall (WTC), banks, and schools in this stunning 1 Kanal residence. Located in a prime, secure sector, it offers the perfect blend of convenience and elegance.\r\n𝗞𝗲𝘆 𝗙𝗲𝗮𝘁𝘂𝗿𝗲𝘀:\r\n● ​5 Spacious Bedrooms with modern attached bathrooms.\r\n● ​Elegant Drawing & Dining Room for formal hosting.\r\n● ​Large TV Lounge & high-end Modern Kitchen.\r\n● ​Functional Extras: Store room & Servant room with bath.\r\n● ​Parking: Secure space for 2 cars.\r\n​This property combines a top-tier location with sophisticated design—an ideal choice for a premium family lifestyle or a high-value investment.\r\n𝗖𝗼𝗻𝘁𝗮𝗰𝘁 𝗳𝗼𝗿 𝗺𝗼𝗿𝗲 𝗱𝗲𝘁𝗮𝗶𝗹𝘀 📞 03306413823', 'Sale', 1, 16, 'House', NULL, 'Islamabad', 'Dha Phasa 8 ', NULL, NULL, NULL, 260000000.00, 'Fixed', 1.00, 'Kanal', 5, 6, 1, 2, 2, 'Yes', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, 0.00, 0, 'HS Advertising', ' 03306413823', 'HSAdvertising@gmail.com', 1, 'user', NULL, NULL, NULL, NULL, 'Approved', 1, 18, '2026-04-03', '2026-05-03', '2026-04-02 21:11:12', '2026-04-27 18:12:18'),
(62, 1, 'Ultra-Luxury 1,000 Sq. Yards Mansion for Sale', 'ultra-luxury-1-000-sq-yards-mansion-for-sale', '📍 DHA Phase 8 – Zone A, Karachi\r\n🏡 Architect-Designed by Hafiz Sher Ali\r\nStep into a world of elegance and prestige with this magnificent ultra-luxury mansion, designed by renowned architect Hafiz Sher Ali. This architectural masterpiece blends sophisticated design with modern convenience, offering an exceptional lifestyle in one of the most prestigious areas of DHA Phase 8.\r\n✨ Property Highlights:\r\n• 1,000 Sq. Yards – Prime Zone A Location\r\n• Fully Furnished with Premium Finishes\r\n• Solar Power System Installed – Eco-Friendly & Cost Efficient\r\n• High-Speed Elevator / Lift Serving All Floors\r\n🛏 Bedrooms & Living Spaces:\r\n• 6 Spacious Luxury Bedrooms with Designer Fittings\r\n• Attached Modern Bathrooms\r\n• Elegant Living, Dining & Entertainment Areas\r\n• Premium Interior Finishes Throughout\r\n🏝 Resort-Style Outdoor Amenities:\r\n• Private Swimming Pool with Jacuzzi\r\n• Beautiful Landscaped Garden Areas\r\n• Private Terraces & Outdoor Lounging Spaces\r\n🎬 Exclusive Full Basement:\r\nSeparate Entrance — Ideal for both leisure and professional use:\r\n✔️ Office / Workspace\r\n✔️ Executive Sitting Lounge\r\n✔️ Fully Equipped Gym\r\n✔️ Gaming & Entertainment Room\r\nA perfect combination of luxury, comfort, and functionality, making it ideal for families who desire premium living with modern amenities.\r\nDemand: 70 Cr\r\n📞 For ,Details & Site Visit:\r\nKHAWAJA ENTERPRISE\r\nBuilder | Contractor | Property Advisor\r\n📞 +92 0317 8222701\r\n📞 +92 0331 2342065\r\n📧 info@khawajaenterprise.net\r\n🌐 khawajaenterprise.net', 'Sale', 1, 11, 'House', NULL, 'Karachi', ' DHA Phase 8 – Zone A, Karachi', NULL, NULL, NULL, 750000000.00, 'Fixed', 1000.00, 'Sq.yd', 6, 6, 1, 2, 2, 'Yes', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, 0.00, 0, 'KHAWAJA ENTERPRISE', '+92 0317 8222701', 'info@khawajaenterprise.net', 1, 'user', NULL, NULL, NULL, NULL, 'Approved', 1, 20, '2026-04-13', '2026-05-13', '2026-04-13 12:20:49', '2026-04-27 17:31:32'),
(63, 1, 'Beautifully constructed house available for sale in a prime location.', 'beautifully-constructed-house-available-for-sale-in-a-prime-location', 'DHA Phase 8 – Zone A, Karachi\r\n🏡 Prime Location | Ultra-Luxury Living\r\nAn exceptional brand-new 6-bedroom luxury residence designed for those who seek elegance, space, and modern comfort. Located in the prestigious Zone A of DHA Phase 8, this home offers a perfect blend of luxury and functionality.\r\n✨ Property Overview:\r\n• Plot Size: 1,000 Sq. Yards\r\n• 6 Spacious Bedrooms with Attached Luxury Bathrooms\r\n• Premium Imported Fixtures & Fittings\r\n• Elegant Layout with Modern Design\r\n🏡 Ground Floor Features:\r\n• Private Swimming Pool with Changing Room\r\n• Spacious Designer Kitchen with Premium Appliances\r\n• High-End Mahogany Wood Finishes\r\n🛏 Bedrooms:\r\n• 6 Large Bedrooms with Modern Attached Baths\r\n• Master Suite with Luxury Ensuite & Bathtub\r\n🎬 Basement & Amenities:\r\n• Huge Family Living Area\r\n• Fully Equipped Private Gym\r\n• State-of-the-Art Home Theatre\r\n🌿 Additional Highlights:\r\n• Modern Lift Installed\r\n• Beautiful Landscaped Green Garden\r\n• Ample Parking Space\r\n• Located in a Prime & Secure Neighborhood\r\n🏠 A perfect combination of luxury, comfort, and convenience — ideal for elite family living in DHA Phase 8.', 'Sale', 1, 11, 'House', NULL, 'Karachi', 'DHA Phase 8 – Zone A.', NULL, NULL, NULL, 750000000.00, 'Fixed', 1000.00, 'Sq.yd', 6, 6, 2, 2, 2, 'Yes', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, 0.00, 0, 'Khawaja Enterprise', '+92 0317 8222701', 'info@khawajaenterprise.net', 1, 'user', NULL, NULL, NULL, NULL, 'Approved', 1, 19, '2026-04-13', '2026-05-13', '2026-04-13 12:28:01', '2026-04-27 17:51:28'),
(64, 1, 'Brand New 1,000 Yards Luxury Bungalow for Sale', 'brand-new-1-000-yards-luxury-bungalow-for-sale', ' DHA Phase 8 – Zone A, Karachi\r\n🏡 Prime Location | Ultra-Luxury Living\r\nAn exceptional brand-new 6-bedroom luxury residence designed for those who seek elegance, space, and modern comfort. Located in the prestigious Zone A of DHA Phase 8, this home offers a perfect blend of luxury and functionality.\r\n✨ Property Overview:\r\n• Plot Size: 1,000 Sq. Yards\r\n• 6 Spacious Bedrooms with Attached Luxury Bathrooms\r\n• Premium Imported Fixtures & Fittings\r\n• Elegant Layout with Modern Design\r\n🏡 Ground Floor Features:\r\n• Private Swimming Pool with Changing Room\r\n• Spacious Designer Kitchen with Premium Appliances\r\n• High-End Mahogany Wood Finishes\r\n🛏 Bedrooms:\r\n• 6 Large Bedrooms with Modern Attached Baths\r\n• Master Suite with Luxury Ensuite & Bathtub\r\n🎬 Basement & Amenities:\r\n• Huge Family Living Area\r\n• Fully Equipped Private Gym\r\n• State-of-the-Art Home Theatre\r\n🌿 Additional Highlights:\r\n• Modern Lift Installed\r\n• Beautiful Landscaped Green Garden\r\n• Ample Parking Space\r\n• Located in a Prime & Secure Neighborhood\r\n🏠 A perfect combination of luxury, comfort, and convenience — ideal for elite family living in DHA Phase 8.\r\n💰 Demand: On call\r\nKHAWAJA ENTERPRISE\r\nBuilder | Contractor | Property Advisor\r\n📞 +92 0317 8222701\r\n📞 +92 0331 2342065\r\n📧 info@khawajaenterprise.net\r\n🌐 khawajaenterprise.net\r\n#KhawajaEnterprise #DHAPhase5 #DHAKarachi #UltraLuxury #KarachiRealEstate #EliteLiving #LuxuryEstate #1000Yards #HighNetWorth #PrimeProperty #dhacitytime #karachi', 'Sale', 1, 11, 'House', NULL, 'Karachi', ' DHA Phase 8 – Zone A,', NULL, NULL, NULL, 800000000.00, 'Fixed', 1000.00, 'Sq.yd', 6, 6, 2, 2, 2, 'Yes', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, 0.00, 0, 'KHAWAJA ENTERPRISE', '+92 0317 8222701', 'info@khawajaenterprise.net', 1, 'user', NULL, NULL, NULL, NULL, 'Approved', 1, 20, '2026-04-13', '2026-05-13', '2026-04-13 12:43:24', '2026-04-29 11:45:09'),
(65, 13, 'FOR SALE', 'for-sale', '*Three bedroom with attached bath drawing lounge \r\n*2nd floor with roof \r\n* park facing \r\n*single belt west open \r\n*brand new\r\n* separate meters \r\n* 24 hours electricity water\r\n* location federal b area block 15 \r\n* near ubl complex lucky one mall karachi\r\n* demand 185 lac ', 'Sale', 1, 11, 'House', NULL, 'Karachi', 'location federal b area block 15', NULL, NULL, NULL, 45000000.00, 'Fixed', 200.00, 'Sq.yd', 4, 4, 1, 1, 1, 'Yes', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, 0.00, 0, 'Haris Ali', '03032187145', 'Harisali@gmail.com', 1, 'user', NULL, NULL, NULL, NULL, 'Approved', 0, 10, '2026-04-20', '2026-05-20', '2026-04-20 14:38:34', '2026-04-27 17:42:45'),
(66, 13, '500 Yards Brand-New Semi-Furnished Luxury Home for Sale', '500-yards-brand-new-semi-furnished-luxury-home-for-sale', 'Experience refined living in this stunning brand-new semi-furnished bungalow, located in one of DHA Phase 5’s most prestigious and well-connected areas.\r\n✨ Key Features:\r\n• Plot Size: 500 Sq. Yards\r\n• 6 Spacious Bedrooms – Designed for comfort, privacy & elegance\r\n• Semi-Furnished with Premium Finishes\r\n• Brand New Construction – Never Lived In\r\n🏠 Additional Highlights:\r\n• Basement Area – Ideal for Gym, Lounge, Play Area or Storage\r\n• Private Home Theatre 🎬 – Enjoy cinema at home\r\n• Contemporary Design & Modern Fittings\r\n• Spacious layout with excellent functionality\r\n📍 Located in a prime and secure neighborhood, offering easy access to main roads, commercial areas, and all essential amenities.\r\n🏠 A perfect choice for families seeking luxury, comfort, and a premium lifestyle in DHA Phase 5.\r\n📞 For Details & Visit:\r\nKhawaja Enterprise\r\n📱 0317-8222701\r\n📱 0331-2342065\r\n📧 info@khawajaenterprise.net\r\n🌐 khawajaenterprise.net\r\n#khawajaenterprise #DHAPhase5 #dhakarachi #ultraluxury #KarachiRealEstate #EliteLiving #luxuryestate #1000yards #HighNetWorth #PrimeProperty #dhacitytime #karachi #viralpost #viralreel', 'Sale', 1, 11, 'House', NULL, 'Karachi', 'Khayaban-e-Tanzeem, DHA Phase 5 – Karachi', NULL, NULL, NULL, 220000000.00, 'Fixed', 500.00, 'Sq.yd', 6, 6, 1, 2, 2, 'Yes', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, 0.00, 0, 'Haris Ali', '03171066689', 'Harisali@gmail.com', 1, 'user', NULL, NULL, NULL, NULL, 'Approved', 0, 12, '2026-04-20', '2026-05-20', '2026-04-20 15:16:25', '2026-04-28 01:26:10');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `google_id` varchar(100) DEFAULT NULL,
  `oauth_provider` varchar(20) DEFAULT NULL,
  `username` varchar(100) NOT NULL,
  `full_name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `avatar_url` varchar(512) DEFAULT NULL,
  `status` enum('active','inactive','suspended') DEFAULT 'active',
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `google_id`, `oauth_provider`, `username`, `full_name`, `email`, `password_hash`, `phone`, `avatar_url`, `status`, `email_verified_at`, `created_at`, `updated_at`) VALUES
(1, NULL, NULL, 'admin', 'adminpro', 'admin@gmail.com', '$2y$10$QOv6BVZdw/GrmVdGMZLifOOXEWj6I2mA5DxsdY4ERJKN1cKd7RvdW', '', 'uploads/avatars/79235730e4e72ca6b8cd124e4ba90de1.jpg', 'active', NULL, '2025-12-22 16:43:37', '2026-04-29 17:56:11'),
(3, NULL, NULL, 'test', 'test', 'test@gmail.com', '$2y$10$7pcCCQRygMs/EMmY1MbNXuq/WKY3KNx9/ZWtF1c1sMgnSN7vsbuoe', NULL, NULL, 'active', NULL, '2025-12-22 21:26:35', '2026-04-29 17:29:00'),
(8, NULL, NULL, 'Junaid', 'Junaid Ali', 'Junaidali@gmail.com', '$2y$10$BcOGIwNmJqWu0AHbqLaD7u36oH.Z9Hg9JVvd2PIzKGDYgI7IOnJZS', NULL, NULL, 'active', NULL, '2026-01-06 23:17:02', '2026-04-29 17:29:00'),
(9, NULL, NULL, 'Ali Khan', 'Ali Khan', 'Ali@gmail.com', '$2y$10$s52CbKVqUwaiSG6g.f3S0uLPdOhVhZHO2cP/foAdYWim4KQsu.1B6', NULL, NULL, 'active', NULL, '2026-01-06 23:19:16', '2026-04-29 17:29:00'),
(10, NULL, NULL, 'Bilal khan', 'Bilal Khan', 'BilalKhan@gmail.comm', '$2y$10$lgo5dyGaAEbHcIipGtxyWeqg70VdiW63t5tyIhIXwquwcnU/1u3H6', NULL, NULL, 'active', NULL, '2026-01-06 23:21:08', '2026-04-29 17:29:00'),
(12, '100829006345647880989', 'google', 'muhammadshahrukhsiddiqui329', 'Muhammad Shahrukh Siddiqui', 'ishahrukhsq1@gmail.com', '', NULL, 'https://lh3.googleusercontent.com/a/ACg8ocJUr2rLqDB1d1qrurUVq8kQPBdIXegDnBB_jcZUo2ZButU1cQ=s96-c', 'active', NULL, '2026-01-08 18:07:19', '2026-04-29 17:29:00'),
(13, NULL, NULL, 'Haris Ali', 'Haris Ali', 'Harisali@gmail.com', '$2y$10$D.ivG.J5F7ND4OOxhJgENuoiz89wDEsBZZb1Cj92CmSUP/gxCF1RO', '03038611893', NULL, 'active', NULL, '2026-01-13 07:47:52', '2026-05-17 17:31:12'),
(17, '100870014800008832797', 'google', 'akamaanullah', 'Muhammad Zain', 'imuhammadzain01@gmail.com', '$2y$10$M8xXeQB/WhtTTVMC70LfTuKIujGNrL08wHBIYcGuWNjJIqE5AKac.', '03442882239', NULL, 'active', NULL, '2026-01-14 22:13:56', '2026-04-29 17:29:00'),
(18, NULL, NULL, 'WaqasKhan', 'Syed Waqas Khan', 'Waqaskhan@gmail.com', '$2y$10$5SALrCkfGrxd0gFlY8Igg.dvGIYdDJ0ozXVQeGHpE379YBWzZwyqi', '03008765432', NULL, 'active', NULL, '2026-01-15 12:09:35', '2026-04-29 17:29:00'),
(19, NULL, NULL, 'Shahrukh', 'Shahrukh Siddiqui', 'shahrukhsiddiqui42@gmail.com', '$2y$10$ZZWdW1MNm0yObrIqEvM2.Osk.osRLFliug/130KvDgY4guJljmfcu', '03038611893', NULL, 'active', NULL, '2026-01-15 12:11:10', '2026-04-29 17:29:00'),
(20, '108139647454707727959', 'google', 'Bilalkhanzai', 'Bilal khan', 'bilalzai5678@gmail.com', '$2y$10$fIsPFI82lvcJUVYsG8BrxuLh0SKluUCVUMdzhzETTEkahu/XL7Bpe', '03362175091', 'uploads/avatars/3bdf372eb6bc1ebe6388748d563f1e09.jpg', 'active', NULL, '2026-01-15 14:11:21', '2026-04-29 17:56:11'),
(21, NULL, NULL, 'Akbar', 'Muhammad Akbar', 'akbarhingorjo24762@gmail.com', '$2y$10$BUtrd8rnAcZRrKiUoCBe2.SmraE/4b7B6wXB2ulZx/Uj/L4DbE3H.', '03331325545', NULL, 'active', NULL, '2026-01-20 14:29:15', '2026-04-29 17:29:00'),
(22, NULL, NULL, 'danishmasood537', 'Syed Danish masood', 'danishmasood538@gmail.com', '$2y$10$/0BYeFk.UrSkZGTmvu6.tOQSBl158np4TzAmi5A2Vgt1OyY7IkPmC', '0333 3458003', NULL, 'active', NULL, '2026-01-22 14:33:39', '2026-04-29 17:29:00'),
(23, '112607622190121001376', 'google', 'danishmasood843', 'danish masood', 'danishmasood537@gmail.com', '', NULL, 'https://lh3.googleusercontent.com/a/ACg8ocKu6B7LckB6lLRVU1CeprwALaS0rsoIhIfa1dG3AIfLCD-4krxS=s96-c', 'active', NULL, '2026-01-22 14:35:37', '2026-04-29 17:29:00'),
(24, '112816914442978391211', 'google', 'sadafzahid422', 'Sadaf Zahid', 'zahidsadaf577@gmail.com', '', NULL, 'https://lh3.googleusercontent.com/a/ACg8ocL11yGEo_mxst-08W-sCboUt2AcBP3qgi6sFcDNb5712J7oiw=s96-c', 'active', NULL, '2026-01-22 14:47:58', '2026-04-29 17:29:00'),
(25, NULL, NULL, 'waleediqbal12', 'Waleed Iqbal', 'albertfinch8@gmail.com', '$2y$10$EA4M98DsBFE0cwWtzXjltOmrH0m5E5A3fu2fOAod/GL8W.g2KUNHa', '03132286920', NULL, 'active', NULL, '2026-02-17 13:34:29', '2026-04-29 17:29:00'),
(26, NULL, NULL, 'mahmood25', 'Mahmood Masood', 'mahmoodmasood66@gmail.com.com', '$2y$10$JgAGeI6HXX7SWnwoPB/6.eb.boK23a0vw957InwWgKKsdJJyyyq3C', '03472854064', NULL, 'active', NULL, '2026-04-04 14:20:57', '2026-05-17 17:56:21'),
(27, '102514558065133994692', 'google', 'arhamshaikh725', 'arham shaikh', 'arhamshaikh1368@gmail.com', '', NULL, 'https://lh3.googleusercontent.com/a/ACg8ocJkhhbNe7xxURND8w_gGilg1SPI0txvebN4WVVRqBQlKpnYh6CT=s96-c', 'active', NULL, '2026-04-16 14:44:16', '2026-04-29 17:29:00'),
(28, NULL, NULL, 'ATIF', 'Syed Atif Shahzad', 'atifshahzad82@gmail.com', '$2y$10$niURYfnn7hTVMG1HE88ehegLr4VwTBH/RUMbh2xljcEnvgn36lvgS', '03312392147', NULL, 'active', NULL, '2026-04-16 15:17:34', '2026-05-17 17:56:40'),
(29, NULL, NULL, 'aster23sx', '⚡85.000 Lira Seni Bekliyor - Tek Tıkla Al! https://bit.ly/4rKU3YO ⚡', 'salavat@ya.ru', '$2y$10$ANta19p2skVUMrLag2CUceOpBhKPCR.12NHzgx5ZPz7ef5C5kAqre', '9093429282', NULL, 'inactive', NULL, '2026-04-18 15:52:25', '2026-04-29 17:29:00'),
(30, NULL, NULL, 'aliyandatusing151006@gmail.com', 'Aliyan Ali', 'aliyandatusing151006@gmail.com', '$2y$10$r3Ju0pr2lTOA0GQ5SRA6OeucKCuvo/WTuypQe3gaQc.Nc24X989JW', NULL, NULL, 'active', NULL, '2026-05-10 21:59:32', '2026-05-10 21:59:32'),
(31, NULL, NULL, 'admin@gmail.com', 'Ali Naqi', 'AliNaqi@gmail.com', '$2y$10$kvq4MYHF7C2i4WmOqYenMO4G6u/kY4NwJUpr43IA4UdNZg/Q01ndW', NULL, NULL, 'active', NULL, '2026-05-17 18:19:29', '2026-05-17 18:19:29'),
(32, NULL, NULL, 'Imran Ali', 'Imran Ali', 'ImranAli@gmail.com', '$2y$10$kchVfrssUUSUm.nDHAQXYeVlaBaotSWUysVTbYiKBQ/bHjavBUz96', NULL, NULL, 'active', NULL, '2026-05-17 18:23:02', '2026-05-17 18:23:02'),
(33, NULL, NULL, 'Asad Khan', 'Asad Khan', 'AsadKhan@gmail.com', '$2y$10$0eugA8jiTSImV12glYiUpe9Ez8R5n.Lp6Zx3CawuzDU1ZRO9q6K.a', NULL, NULL, 'active', NULL, '2026-05-19 01:07:30', '2026-05-19 01:07:30'),
(34, NULL, NULL, 'Uzair', 'Khan', 'Uzair@gmail.com', '$2y$10$Mcowqq6cQ26EQe/MHu/D2enqTwFAadL2JUmYrX9IMqlR1ebfDdKuC', NULL, NULL, 'active', NULL, '2026-06-10 02:17:30', '2026-06-10 02:17:30'),
(35, NULL, NULL, 'Ikram', 'Ikramullah', 'ikram56haseeb@gmail.com', '$2y$10$yYIGsqVqyZX56/fRfM71XuZLiNu74J37G9H.Mvgg5lOPCWefFupkW', NULL, NULL, 'active', NULL, '2026-07-05 11:58:03', '2026-07-05 11:58:03'),
(36, NULL, NULL, 'Ikramkhan', 'Ikramullah', 'amna56hameed@gmail.com', '$2y$10$9rnzIoHepT0Wh9P1aX6emOtsJV7Xr0AKcFBRz8pRtQx0nmJk1IxlC', NULL, NULL, 'active', NULL, '2026-07-05 12:01:05', '2026-07-05 12:01:05'),
(37, NULL, NULL, 'muhammadzain', 'Muhammad Zain', 'imuhammadzain012@gmail.com', '$2y$10$lZR1yuokPrROETt7ufV12ucfBKWbkrvoHkLIhSZNN1B0HQKXIaLS.', NULL, NULL, 'active', NULL, '2026-07-31 22:34:34', '2026-07-31 22:34:34');

-- --------------------------------------------------------

--
-- Table structure for table `user_roles`
--

CREATE TABLE `user_roles` (
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `role_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_roles`
--

INSERT INTO `user_roles` (`user_id`, `role_id`) VALUES
(1, 1),
(31, 2),
(32, 2),
(33, 2),
(3, 3),
(8, 3),
(9, 3),
(26, 3),
(10, 4),
(12, 4),
(13, 4),
(17, 4),
(18, 4),
(19, 4),
(20, 4),
(21, 4),
(22, 4),
(23, 4),
(24, 4),
(25, 4),
(27, 4),
(28, 4),
(29, 4),
(30, 4),
(34, 4),
(36, 4),
(37, 4),
(35, 5);

-- --------------------------------------------------------

--
-- Table structure for table `user_settings`
--

CREATE TABLE `user_settings` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_settings`
--

INSERT INTO `user_settings` (`id`, `user_id`, `setting_key`, `setting_value`) VALUES
(1, 1, 'admin_theme', 'dark');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `activity_logs`
--
ALTER TABLE `activity_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_logs_user` (`user_id`);

--
-- Indexes for table `agencies`
--
ALTER TABLE `agencies`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_agencies_owner` (`owner_id`);

--
-- Indexes for table `agency_documents`
--
ALTER TABLE `agency_documents`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_docs_agency` (`agency_id`);

--
-- Indexes for table `agents`
--
ALTER TABLE `agents`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_agents_user` (`user_id`),
  ADD KEY `fk_agents_agency` (`agency_id`);

--
-- Indexes for table `agent_reviews`
--
ALTER TABLE `agent_reviews`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_reviews_agent` (`agent_id`),
  ADD KEY `fk_reviews_reviewer` (`reviewer_id`);

--
-- Indexes for table `amenity_fields`
--
ALTER TABLE `amenity_fields`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_amenity_group` (`group_id`);

--
-- Indexes for table `amenity_groups`
--
ALTER TABLE `amenity_groups`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `blogs`
--
ALTER TABLE `blogs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`),
  ADD KEY `author_id` (`author_id`);

--
-- Indexes for table `cities`
--
ALTER TABLE `cities`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `city_slug_unique` (`slug`);

--
-- Indexes for table `leads`
--
ALTER TABLE `leads`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_leads_property` (`property_id`),
  ADD KEY `fk_leads_buyer` (`buyer_id`);

--
-- Indexes for table `locations`
--
ALTER TABLE `locations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_location_city` (`city_id`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `is_read` (`is_read`),
  ADD KEY `created_at` (`created_at`);

--
-- Indexes for table `premium_requests`
--
ALTER TABLE `premium_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `properties`
--
ALTER TABLE `properties`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `properties_slug_unique` (`slug`),
  ADD KEY `properties_price_index` (`price`),
  ADD KEY `fk_properties_author` (`author_id`),
  ADD KEY `fk_properties_agency` (`agency_id`),
  ADD KEY `fk_properties_category` (`category_id`),
  ADD KEY `fk_properties_subtype` (`subtype_id`),
  ADD KEY `fk_properties_city` (`city_id`),
  ADD KEY `fk_properties_location` (`location_id`);

--
-- Indexes for table `property_amenity_values`
--
ALTER TABLE `property_amenity_values`
  ADD PRIMARY KEY (`property_id`,`amenity_field_id`),
  ADD KEY `fk_val_amenity` (`amenity_field_id`);

--
-- Indexes for table `property_categories`
--
ALTER TABLE `property_categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `cat_slug_unique` (`slug`);

--
-- Indexes for table `property_contacts`
--
ALTER TABLE `property_contacts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_contacts_property` (`property_id`);

--
-- Indexes for table `property_documents`
--
ALTER TABLE `property_documents`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_docs_property` (`property_id`);

--
-- Indexes for table `property_images`
--
ALTER TABLE `property_images`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_images_property` (`property_id`);

--
-- Indexes for table `property_interactions`
--
ALTER TABLE `property_interactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_interactions_property` (`property_id`),
  ADD KEY `fk_interactions_user` (`user_id`);

--
-- Indexes for table `property_stats`
--
ALTER TABLE `property_stats`
  ADD PRIMARY KEY (`property_id`);

--
-- Indexes for table `property_subtypes`
--
ALTER TABLE `property_subtypes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `subtype_slug_unique` (`slug`),
  ADD KEY `fk_subtype_category` (`category_id`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `roles_name_unique` (`role_name`);

--
-- Indexes for table `saved_properties`
--
ALTER TABLE `saved_properties`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_save` (`user_id`,`property_id`),
  ADD KEY `fk_saved_property` (`property_id`);

--
-- Indexes for table `site_settings`
--
ALTER TABLE `site_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `setting_key` (`setting_key`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `google_id` (`google_id`);

--
-- Indexes for table `user_roles`
--
ALTER TABLE `user_roles`
  ADD PRIMARY KEY (`user_id`,`role_id`),
  ADD KEY `fk_user_roles_role` (`role_id`);

--
-- Indexes for table `user_settings`
--
ALTER TABLE `user_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_setting_unique` (`user_id`,`setting_key`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `activity_logs`
--
ALTER TABLE `activity_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `agencies`
--
ALTER TABLE `agencies`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `agency_documents`
--
ALTER TABLE `agency_documents`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `agents`
--
ALTER TABLE `agents`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `agent_reviews`
--
ALTER TABLE `agent_reviews`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `amenity_fields`
--
ALTER TABLE `amenity_fields`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `amenity_groups`
--
ALTER TABLE `amenity_groups`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `blogs`
--
ALTER TABLE `blogs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `cities`
--
ALTER TABLE `cities`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `leads`
--
ALTER TABLE `leads`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `locations`
--
ALTER TABLE `locations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=40;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `premium_requests`
--
ALTER TABLE `premium_requests`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `properties`
--
ALTER TABLE `properties`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=83;

--
-- AUTO_INCREMENT for table `property_categories`
--
ALTER TABLE `property_categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `property_contacts`
--
ALTER TABLE `property_contacts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=60;

--
-- AUTO_INCREMENT for table `property_documents`
--
ALTER TABLE `property_documents`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `property_images`
--
ALTER TABLE `property_images`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=478;

--
-- AUTO_INCREMENT for table `property_interactions`
--
ALTER TABLE `property_interactions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=209;

--
-- AUTO_INCREMENT for table `property_subtypes`
--
ALTER TABLE `property_subtypes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `saved_properties`
--
ALTER TABLE `saved_properties`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `site_settings`
--
ALTER TABLE `site_settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT for table `user_settings`
--
ALTER TABLE `user_settings`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `activity_logs`
--
ALTER TABLE `activity_logs`
  ADD CONSTRAINT `fk_logs_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `agencies`
--
ALTER TABLE `agencies`
  ADD CONSTRAINT `fk_agencies_owner` FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `agency_documents`
--
ALTER TABLE `agency_documents`
  ADD CONSTRAINT `fk_docs_agency` FOREIGN KEY (`agency_id`) REFERENCES `agencies` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `agents`
--
ALTER TABLE `agents`
  ADD CONSTRAINT `fk_agents_agency` FOREIGN KEY (`agency_id`) REFERENCES `agencies` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_agents_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `agent_reviews`
--
ALTER TABLE `agent_reviews`
  ADD CONSTRAINT `fk_reviews_agent` FOREIGN KEY (`agent_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_reviews_reviewer` FOREIGN KEY (`reviewer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `amenity_fields`
--
ALTER TABLE `amenity_fields`
  ADD CONSTRAINT `fk_amenity_group` FOREIGN KEY (`group_id`) REFERENCES `amenity_groups` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `blogs`
--
ALTER TABLE `blogs`
  ADD CONSTRAINT `blogs_ibfk_1` FOREIGN KEY (`author_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `leads`
--
ALTER TABLE `leads`
  ADD CONSTRAINT `fk_leads_buyer` FOREIGN KEY (`buyer_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_leads_property` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `locations`
--
ALTER TABLE `locations`
  ADD CONSTRAINT `fk_location_city` FOREIGN KEY (`city_id`) REFERENCES `cities` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `properties`
--
ALTER TABLE `properties`
  ADD CONSTRAINT `fk_properties_agency` FOREIGN KEY (`agency_id`) REFERENCES `agencies` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_properties_author` FOREIGN KEY (`author_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_properties_category` FOREIGN KEY (`category_id`) REFERENCES `property_categories` (`id`),
  ADD CONSTRAINT `fk_properties_city` FOREIGN KEY (`city_id`) REFERENCES `cities` (`id`),
  ADD CONSTRAINT `fk_properties_location` FOREIGN KEY (`location_id`) REFERENCES `locations` (`id`),
  ADD CONSTRAINT `fk_properties_subtype` FOREIGN KEY (`subtype_id`) REFERENCES `property_subtypes` (`id`);

--
-- Constraints for table `property_amenity_values`
--
ALTER TABLE `property_amenity_values`
  ADD CONSTRAINT `fk_val_amenity` FOREIGN KEY (`amenity_field_id`) REFERENCES `amenity_fields` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_val_property` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `property_contacts`
--
ALTER TABLE `property_contacts`
  ADD CONSTRAINT `fk_contacts_property` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `property_documents`
--
ALTER TABLE `property_documents`
  ADD CONSTRAINT `fk_docs_property` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `property_images`
--
ALTER TABLE `property_images`
  ADD CONSTRAINT `fk_images_property` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `property_interactions`
--
ALTER TABLE `property_interactions`
  ADD CONSTRAINT `fk_interactions_property` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_interactions_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `property_stats`
--
ALTER TABLE `property_stats`
  ADD CONSTRAINT `fk_stats_property` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `property_subtypes`
--
ALTER TABLE `property_subtypes`
  ADD CONSTRAINT `fk_subtype_category` FOREIGN KEY (`category_id`) REFERENCES `property_categories` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `saved_properties`
--
ALTER TABLE `saved_properties`
  ADD CONSTRAINT `fk_saved_property` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_saved_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_roles`
--
ALTER TABLE `user_roles`
  ADD CONSTRAINT `fk_user_roles_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_user_roles_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_settings`
--
ALTER TABLE `user_settings`
  ADD CONSTRAINT `fk_user_settings_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
