CREATE DATABASE IF NOT EXISTS chargepoint_il;
USE chargepoint_il;

CREATE TABLE customers (
    customer_id   INT PRIMARY KEY AUTO_INCREMENT,
    full_name     VARCHAR(100) NOT NULL,
    email         VARCHAR(150) NOT NULL UNIQUE,
    phone         VARCHAR(20),
    date_of_birth DATE,
    payment_info  VARCHAR(255),
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE stations (
    station_id   INT PRIMARY KEY AUTO_INCREMENT,
    station_name VARCHAR(100) NOT NULL,
    address      VARCHAR(255) NOT NULL,
    city         VARCHAR(100),
    latitude     DECIMAL(9,6),
    longitude    DECIMAL(9,6)
);

CREATE TABLE charging_ports (
    port_id        INT PRIMARY KEY AUTO_INCREMENT,
    station_id     INT NOT NULL,
    port_number    VARCHAR(10) NOT NULL,
    connector_type VARCHAR(30) NOT NULL,
    max_power_kw   INT NOT NULL,
    status         VARCHAR(20) NOT NULL DEFAULT 'available',
    FOREIGN KEY (station_id) REFERENCES stations(station_id)
);

CREATE TABLE sessions (
    session_id   INT PRIMARY KEY AUTO_INCREMENT,
    customer_id  INT NOT NULL,
    port_id      INT NOT NULL,
    start_time   DATETIME NOT NULL,
    end_time     DATETIME,
    energy_kwh   DECIMAL(8,2),
    status       VARCHAR(20) NOT NULL DEFAULT 'active',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (port_id)     REFERENCES charging_ports(port_id)
);

CREATE TABLE payments (
    payment_id     INT PRIMARY KEY AUTO_INCREMENT,
    session_id     INT NOT NULL,
    amount         DECIMAL(8,2) NOT NULL,
    payment_time   DATETIME NOT NULL,
    payment_status VARCHAR(30) NOT NULL,
    FOREIGN KEY (session_id) REFERENCES sessions(session_id)
);

CREATE TABLE maintenance_records (
    maintenance_id   INT PRIMARY KEY AUTO_INCREMENT,
    port_id          INT NOT NULL,
    maintenance_type VARCHAR(50),
    description      TEXT,
    start_date       DATE NOT NULL,
    end_date         DATE,
    FOREIGN KEY (port_id) REFERENCES charging_ports(port_id)
);

CREATE TABLE incidents (
    incident_id   INT PRIMARY KEY AUTO_INCREMENT,
    port_id       INT NOT NULL,
    session_id    INT,
    reported_at   DATETIME NOT NULL,
    incident_type VARCHAR(50),
    description   TEXT,
    resolved      TINYINT(1) DEFAULT 0,
    FOREIGN KEY (port_id)    REFERENCES charging_ports(port_id),
    FOREIGN KEY (session_id) REFERENCES sessions(session_id)
);