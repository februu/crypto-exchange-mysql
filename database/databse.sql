CREATE DATABASE crypto_exchange;
USE crypto_exchange;

CREATE TABLE Account_Types (
    type_id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(50) UNIQUE NOT NULL,
    description VARCHAR(255) NOT NULL,
    fee_rate DECIMAL(10, 8) NOT NULL
);

CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    account_type_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_type_id) REFERENCES Account_Types(type_id)
);

CREATE TABLE Coins (
    coin_id INT AUTO_INCREMENT PRIMARY KEY,
    coin_name VARCHAR(50) UNIQUE NOT NULL,
    coin_symbol VARCHAR(10) UNIQUE NOT NULL,
    coin_logo_url VARCHAR(255)
);

ALTER TABLE Coins
ADD COLUMN type ENUM('crypto', 'fiat') DEFAULT 'crypto';

CREATE TABLE Wallets (
    wallet_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    coin_id INT NOT NULL,
    balance DECIMAL(20, 8) DEFAULT 0.0,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (coin_id) REFERENCES Coins(coin_id),
    UNIQUE(user_id, coin_id)
);

CREATE TABLE Active_orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    coin_id INT NOT NULL,
    order_type ENUM('buy', 'sell') NOT NULL,
    quantity DECIMAL(20, 8) NOT NULL,
    price DECIMAL(20, 8) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (coin_id) REFERENCES Coins(coin_id)
);

CREATE TABLE Transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    buyer_id INT NOT NULL,
    seller_id INT NOT NULL,
    coin_id INT NOT NULL,
    quantity DECIMAL(20, 8) NOT NULL,
    price DECIMAL(20, 8) NOT NULL,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (buyer_id) REFERENCES Users(user_id),
    FOREIGN KEY (seller_id) REFERENCES Users(user_id),
    FOREIGN KEY (coin_id) REFERENCES Coins(coin_id)
);

CREATE TABLE KYC_Data (
    kyc_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    address VARCHAR(255) NOT NULL,
    identification_type VARCHAR(50) NOT NULL,
    identification_number VARCHAR(50) NOT NULL,
    verification_status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

CREATE TABLE Wallet_Transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    coin_id INT NOT NULL,
    transaction_type ENUM('deposit', 'withdrawal') NOT NULL,
    amount DECIMAL(20, 8) NOT NULL,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (coin_id) REFERENCES Coins(coin_id)
);

INSERT INTO Account_Types (type_name, description, fee_rate) VALUES 
('Basic', 'Basic account', 0.0025),
('Professional', 'Professional account with lower fees', 0.001);

INSERT INTO Coins (coin_name, coin_symbol, coin_logo_url, type) VALUES 
('Złoty', 'PLN', 'https://upload.wikimedia.org/wikipedia/commons/1/1b/Z%C5%82oty.svg', 'fiat'),
('Bitcoin', 'BTC', 'https://upload.wikimedia.org/wikipedia/commons/4/46/Bitcoin.svg', 'crypto'),
('Ethereum', 'ETH', 'https://upload.wikimedia.org/wikipedia/commons/0/05/Ethereum_logo_2014.svg', 'crypto'),
('Ripple', 'XRP', 'https://altcoinsbox.com/wp-content/uploads/2023/09/xrp-logo-white-background.svg', 'crypto'),
('Litecoin', 'LTC', 'https://upload.wikimedia.org/wikipedia/commons/1/1c/Litecoin.svg', 'crypto');