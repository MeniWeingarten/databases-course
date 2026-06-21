-- ============================================================
--  Car Rental Database Schema
--  Assignment 6 – DDL: Database Modeling
-- ============================================================

CREATE DATABASE IF NOT EXISTS car_rental;
USE car_rental;

-- ------------------------------------------------------------
-- 1. VEHICLE MODELS
--    Shared specs for all cars of the same model
-- ------------------------------------------------------------
CREATE TABLE vehicle_models (
    model_id        INT             NOT NULL AUTO_INCREMENT,
    brand           VARCHAR(50)     NOT NULL,
    model_name      VARCHAR(50)     NOT NULL,
    category        VARCHAR(30)     NOT NULL,   -- economy / SUV / luxury
    seats           INT             NOT NULL,
    fuel_type       VARCHAR(20)     NOT NULL,   -- petrol / diesel / electric / hybrid
    PRIMARY KEY (model_id)
);

-- ------------------------------------------------------------
-- 2. VEHICLES
--    Each individual physical car
-- ------------------------------------------------------------
CREATE TABLE vehicles (
    vehicle_id      INT             NOT NULL AUTO_INCREMENT,
    model_id        INT             NOT NULL,
    license_plate   VARCHAR(20)     NOT NULL UNIQUE,
    color           VARCHAR(30),
    year            YEAR            NOT NULL,
    status          VARCHAR(20)     NOT NULL DEFAULT 'available',
                                    -- available / rented / maintenance / damaged
    PRIMARY KEY (vehicle_id),
    FOREIGN KEY (model_id) REFERENCES vehicle_models(model_id)
);

-- ------------------------------------------------------------
-- 3. CUSTOMERS
--    Registered customers with license and renting score
-- ------------------------------------------------------------
CREATE TABLE customers (
    customer_id         INT             NOT NULL AUTO_INCREMENT,
    full_name           VARCHAR(100)    NOT NULL,
    email               VARCHAR(150)    NOT NULL UNIQUE,
    phone               VARCHAR(20),
    date_of_birth       DATE            NOT NULL,
    license_number      VARCHAR(50)     NOT NULL UNIQUE,
    license_expiry_date DATE            NOT NULL,
    license_issue_date  DATE            NOT NULL,   -- used to calculate road experience
    renting_score       DECIMAL(5,2)    NOT NULL DEFAULT 100.00,
                                                    -- starts at 100, updated after each rental
    created_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (customer_id)
);

-- ------------------------------------------------------------
-- 4. PRICING PLANS
--    Different rate plans (daily, weekly, monthly)
--    Rates are adjusted per customer by road experience & renting score
-- ------------------------------------------------------------
CREATE TABLE pricing_plans (
    plan_id             INT             NOT NULL AUTO_INCREMENT,
    plan_name           VARCHAR(50)     NOT NULL,   -- e.g. Daily / Weekly / Monthly
    base_daily_rate     DECIMAL(10,2)   NOT NULL,
    base_weekly_rate    DECIMAL(10,2),
    base_monthly_rate   DECIMAL(10,2),
    min_driver_age      INT             NOT NULL DEFAULT 24,
    description         VARCHAR(255),
    PRIMARY KEY (plan_id)
);

-- ------------------------------------------------------------
-- 5. RENTALS
--    One row per rental order
-- ------------------------------------------------------------
CREATE TABLE rentals (
    rental_id           INT             NOT NULL AUTO_INCREMENT,
    customer_id         INT             NOT NULL,
    vehicle_id          INT             NOT NULL,
    plan_id             INT             NOT NULL,
    pickup_location     VARCHAR(150)    NOT NULL,
    return_location     VARCHAR(150),
    planned_start_date  DATE            NOT NULL,
    planned_end_date    DATE            NOT NULL,
    actual_end_date     DATE,                       -- NULL while rental is active
    final_price         DECIMAL(10,2),              -- calculated at return
    status              VARCHAR(20)     NOT NULL DEFAULT 'active',
                                                    -- active / completed / cancelled
    created_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (rental_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (vehicle_id)  REFERENCES vehicles(vehicle_id),
    FOREIGN KEY (plan_id)     REFERENCES pricing_plans(plan_id)
);

-- ------------------------------------------------------------
-- 6. PAYMENTS
--    Every charge event linked to a rental
-- ------------------------------------------------------------
CREATE TABLE payments (
    payment_id      INT             NOT NULL AUTO_INCREMENT,
    rental_id       INT             NOT NULL,
    amount          DECIMAL(10,2)   NOT NULL,
    payment_date    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_method  VARCHAR(30)     NOT NULL,   -- credit_card / cash / bank_transfer
    payment_type    VARCHAR(30)     NOT NULL,   -- base_charge / damage_surcharge / deposit / refund
    payment_status  VARCHAR(20)     NOT NULL DEFAULT 'pending',
                                                -- pending / completed / failed / refunded
    PRIMARY KEY (payment_id),
    FOREIGN KEY (rental_id) REFERENCES rentals(rental_id)
);

-- ------------------------------------------------------------
-- 7. DAMAGE REPORTS
--    Damage found at vehicle return, linked to the rental
-- ------------------------------------------------------------
CREATE TABLE damage_reports (
    damage_id           INT             NOT NULL AUTO_INCREMENT,
    rental_id           INT             NOT NULL,
    vehicle_id          INT             NOT NULL,
    reported_at         DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    description         TEXT            NOT NULL,
    estimated_cost      DECIMAL(10,2)   NOT NULL,
    photo_reference     VARCHAR(255),              -- path or URL to damage photos
    PRIMARY KEY (damage_id),
    FOREIGN KEY (rental_id)  REFERENCES rentals(rental_id),
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id)
);

-- ------------------------------------------------------------
-- 8. MAINTENANCE RECORDS
--    Scheduled or corrective maintenance per vehicle
-- ------------------------------------------------------------
CREATE TABLE maintenance_records (
    maintenance_id      INT             NOT NULL AUTO_INCREMENT,
    vehicle_id          INT             NOT NULL,
    maintenance_type    VARCHAR(50)     NOT NULL,   -- routine / repair / inspection
    description         TEXT,
    start_date          DATE            NOT NULL,
    end_date            DATE,                       -- NULL while ongoing
    technician_name     VARCHAR(100),
    PRIMARY KEY (maintenance_id),
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id)
);