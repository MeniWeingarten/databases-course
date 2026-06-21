CREATE TABLE customers (
    customer_id    INT          NOT NULL AUTO_INCREMENT,
    full_name      VARCHAR(100) NOT NULL,
    email          VARCHAR(150) NOT NULL UNIQUE,
    phone          VARCHAR(20),
    date_of_birth  DATE,
    license_number VARCHAR(50)  NOT NULL UNIQUE,
    payment_info   VARCHAR(255),
    created_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (customer_id)
);


CREATE TABLE scooter_models (
    model_id      INT          NOT NULL AUTO_INCREMENT,
    model_name    VARCHAR(100) NOT NULL,
    manufacturer  VARCHAR(100),
    max_speed_kmh INT,
    range_km      INT,
    PRIMARY KEY (model_id)
);


CREATE TABLE scooters (
    scooter_id    INT          NOT NULL AUTO_INCREMENT,
    model_id      INT          NOT NULL,
    serial_number VARCHAR(100) NOT NULL UNIQUE,
    status        VARCHAR(30)  NOT NULL DEFAULT 'available',
    -- values: 'available', 'rented', 'maintenance', 'damaged', 'retired'
    battery_level INT,
    last_location VARCHAR(255),
    PRIMARY KEY (scooter_id),
    FOREIGN KEY (model_id) REFERENCES scooter_models(model_id)
);


CREATE TABLE rentals (
    rental_id       INT          NOT NULL AUTO_INCREMENT,
    customer_id     INT          NOT NULL,
    scooter_id      INT          NOT NULL,
    start_time      DATETIME     NOT NULL,
    end_time        DATETIME,
    pickup_location VARCHAR(255),
    return_location VARCHAR(255),
    distance_km     DECIMAL(8,2),
    status          VARCHAR(30)  NOT NULL DEFAULT 'active',
    -- values: 'active', 'completed', 'cancelled'
    PRIMARY KEY (rental_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (scooter_id)  REFERENCES scooters(scooter_id)
);


CREATE TABLE payments (
    payment_id     INT          NOT NULL AUTO_INCREMENT,
    rental_id      INT          NOT NULL,
    amount         DECIMAL(8,2) NOT NULL,
    payment_time   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_status VARCHAR(30)  NOT NULL DEFAULT 'pending',
    -- values: 'pending', 'completed', 'failed', 'refunded'
    PRIMARY KEY (payment_id),
    FOREIGN KEY (rental_id) REFERENCES rentals(rental_id)
);


CREATE TABLE maintenance_records (
    maintenance_id   INT          NOT NULL AUTO_INCREMENT,
    scooter_id       INT          NOT NULL,
    maintenance_type VARCHAR(100) NOT NULL,
    description      TEXT,
    start_date       DATE         NOT NULL,
    end_date         DATE,
    PRIMARY KEY (maintenance_id),
    FOREIGN KEY (scooter_id) REFERENCES scooters(scooter_id)
);


CREATE TABLE incidents (
    incident_id   INT          NOT NULL AUTO_INCREMENT,
    scooter_id    INT          NOT NULL,
    rental_id     INT,              -- NULL for post-return incidents
    reported_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    incident_type VARCHAR(100) NOT NULL,
    description   TEXT,
    resolved      BOOLEAN      NOT NULL DEFAULT FALSE,
    PRIMARY KEY (incident_id),
    FOREIGN KEY (scooter_id) REFERENCES scooters(scooter_id),
    FOREIGN KEY (rental_id)  REFERENCES rentals(rental_id)
);