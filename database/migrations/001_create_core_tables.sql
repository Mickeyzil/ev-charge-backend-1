USE ev_charge_v2_dev;

-- טבלת מפעילים 
-- 		שדה             	 תפקיד                        
-- | --------------- | ---------------------------- |
-- | `operator_id`   | מזהה פנימי וייחודי של המפעיל |
-- | `name`          | שם החברה, לדוגמה `EV-Edge`   |
-- | `website_url`   | אתר המפעיל                   |
-- | `support_phone` | טלפון לתמיכה                 |
-- | `support_email` | אימייל לתמיכה                |
-- | `is_active`     | האם המפעיל עדיין פעיל במערכת |
-- | `created_at`    | מתי הרשומה נוצרה             |
-- | `updated_at`    | מתי הרשומה עודכנה לאחרונה    |
CREATE TABLE operators (
    operator_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(160) NOT NULL,
    website_url VARCHAR(500) NULL,
    support_phone VARCHAR(32) NULL,
    support_email VARCHAR(254) NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_operators_name UNIQUE (name)
) ENGINE=InnoDB;


-- מיקומי טעינה
-- 		שדה                 	 תפקיד                                       |
-- | ------------------- | ------------------------------------------- |
-- | `location_id`       | מזהה פנימי של המקום                         |
-- | `operator_id`       | המפעיל שאחראי למקום                         |
-- | `name`              | שם המקום או החניון                          |
-- | `address`           | הכתובת המלאה                                |
-- | `city`              | העיר שבה המקום נמצא                         |
-- | `country_code`      | קוד המדינה; ברירת המחדל היא ישראל           |
-- | `latitude`          | קו רוחב להצגה במפה                          |
-- | `longitude`         | קו אורך להצגה במפה                          |
-- | `access_type`       | סוג הגישה: ציבורי, פרטי, לקוחות בלבד וכדומה |
-- | `is_active`         | האם המקום עדיין פעיל                        |
-- | `source_updated_at` | מתי המקור החיצוני עדכן את הנתון             |
-- | `created_at`        | מתי המקום נשמר אצלנו                        |
-- | `updated_at`        | מתי הרשומה אצלנו השתנתה                     |

CREATE TABLE charging_locations (
    location_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    operator_id BIGINT UNSIGNED NULL,
    name VARCHAR(200) NOT NULL,
    address VARCHAR(255) NULL,
    city VARCHAR(120) NULL,
    country_code CHAR(2) NOT NULL DEFAULT 'IL',
    latitude DECIMAL(10,7) NOT NULL,
    longitude DECIMAL(11,7) NOT NULL,
    access_type VARCHAR(40) NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    source_updated_at TIMESTAMP NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_locations_operator
        FOREIGN KEY (operator_id)
        REFERENCES operators(operator_id)
        ON DELETE SET NULL,
    INDEX idx_locations_city (city),
    INDEX idx_locations_coordinates (latitude, longitude)
) ENGINE=InnoDB;


-- מטענים פיזיים
-- 		שדה                  		 תפקיד                                   |
-- | -------------------- | --------------------------------------- |
-- | `evse_id`            | המזהה הפנימי של המטען                   |
-- | `location_id`        | המיקום שאליו המטען שייך                 |
-- | `external_uid`       | מזהה המטען אצל המקור החיצוני            |
-- | `physical_reference` | סימון פיזי שמופיע על המטען, למשל `A-04` |
-- | `current_status`     | המצב הנוכחי של המטען                    |
-- | `last_status_at`     | מתי התקבל עדכון הסטטוס האחרון           |
-- | `source_updated_at`  | זמן העדכון כפי שנשלח מהמקור             |
-- | `created_at`         | מתי המטען נוצר אצלנו                    |
-- | `updated_at`         | מתי הרשומה השתנתה אצלנו                 |
CREATE TABLE evses (
    evse_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    location_id BIGINT UNSIGNED NOT NULL,
    external_uid VARCHAR(191) NULL,
    physical_reference VARCHAR(100) NULL,
    current_status VARCHAR(32) NOT NULL DEFAULT 'UNKNOWN',
    last_status_at TIMESTAMP NULL,
    source_updated_at TIMESTAMP NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_evses_location
        FOREIGN KEY (location_id)
        REFERENCES charging_locations(location_id)
        ON DELETE CASCADE,
    CONSTRAINT uq_evses_location_external
        UNIQUE (location_id, external_uid),
    INDEX idx_evses_location_status
        (location_id, current_status)
) ENGINE=InnoDB;


-- מחברים
 -- 	שדה                     	 תפקיד                           |
-- | ----------------------- | ------------------------------- |
-- | `connector_id`          | מזהה פנימי של המחבר             |
-- | `evse_id`               | המטען שאליו המחבר שייך          |
-- | `external_connector_id` | מזהה המחבר אצל ספק המידע        |
-- | `connector_type`        | סוג המחבר, למשל CCS2 או Type 2  |
-- | `connector_format`      | האם מדובר בכבל או בשקע          |
-- | `power_type`            | סוג החשמל: AC או DC             |
-- | `max_voltage`           | המתח המקסימלי                   |
-- | `max_amperage`          | הזרם המקסימלי                   |
-- | `max_power_kw`          | הספק הטעינה המקסימלי בקילוואט   |
-- | `source_updated_at`     | מתי המקור החיצוני עדכן את המחבר |
-- | `created_at`            | מתי המחבר נוצר אצלנו            |
-- | `updated_at`            | מתי הרשומה השתנתה               |
CREATE TABLE connectors (
    connector_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    evse_id BIGINT UNSIGNED NOT NULL,
    external_connector_id VARCHAR(64) NOT NULL,
    connector_type VARCHAR(64) NOT NULL,
    connector_format VARCHAR(24) NULL,
    power_type VARCHAR(24) NOT NULL,
    max_voltage INT UNSIGNED NULL,
    max_amperage INT UNSIGNED NULL,
    max_power_kw DECIMAL(8,2) NULL,
    source_updated_at TIMESTAMP NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_connectors_evse
        FOREIGN KEY (evse_id)
        REFERENCES evses(evse_id)
        ON DELETE CASCADE,
    CONSTRAINT uq_connectors_external
        UNIQUE (evse_id, external_connector_id),
    INDEX idx_connectors_type (connector_type),
    INDEX idx_connectors_power (max_power_kw)
) ENGINE=InnoDB;


-- התאמת מקור חיצוני
--  	שדה            	      תפקיד                        |
-- | ------------------- | ---------------------------- |
-- | `source_record_id`  | מזהה פנימי של רשומת המקור    |
-- | `location_id`       | התחנה אצלנו שאליה המידע שייך |
-- | `source_name`       | שם המקור, למשל `GOV_IL`      |
-- | `external_id`       | מזהה התחנה במקור החיצוני     |
-- | `raw_payload`       | ה־JSON המקורי שהתקבל מהמקור  |
-- | `source_updated_at` | מתי המקור עדכן את הנתונים    |
-- | `last_synced_at`    | מתי אנחנו משכנו את המידע     |
-- | `created_at`        | מתי הקישור נוצר אצלנו        |
-- | `updated_at`        | מתי הקישור השתנה             |
CREATE TABLE external_location_sources (
    source_record_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    location_id BIGINT UNSIGNED NOT NULL,
    source_name VARCHAR(100) NOT NULL,
    external_id VARCHAR(191) NOT NULL,
    raw_payload JSON NOT NULL,
    source_updated_at TIMESTAMP NULL,
    last_synced_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_external_sources_location
        FOREIGN KEY (location_id)
        REFERENCES charging_locations(location_id)
        ON DELETE CASCADE,
    CONSTRAINT uq_external_source_record
        UNIQUE (source_name, external_id),
    INDEX idx_external_sources_location (location_id)
) ENGINE=InnoDB;

-- משתמשים
-- שדה              	 תפקיד                                |
-- | ---------------- | ------------------------------------ |
-- | `user_id`        | מזהה ייחודי של המשתמש                |
-- | `full_name`      | שמו המלא                             |
-- | `email`          | אימייל להתחברות                      |
-- | `password_hash`  | הסיסמה לאחר הצפנה באמצעות bcrypt     |
-- | `phone`          | מספר טלפון אופציונלי                 |
-- | `role`           | תפקיד המשתמש, למשל `USER` או `ADMIN` |
-- | `account_status` | מצב החשבון                           |
-- | `created_at`     | מתי החשבון נוצר                      |
-- | `updated_at`     | מתי החשבון עודכן                     |
CREATE TABLE users (
    user_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(120) NOT NULL,
    email VARCHAR(254) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(32) NULL,
    role VARCHAR(24) NOT NULL DEFAULT 'USER',
    account_status VARCHAR(24) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_users_email UNIQUE (email),
    INDEX idx_users_account_status (account_status)
) ENGINE=InnoDB;