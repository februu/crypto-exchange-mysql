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
    account_status ENUM('active', 'blocked') DEFAULT 'blocked',
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
('Złoty', 'PLN', 'https://www.svgrepo.com/show/242317/poland.svg', 'fiat'),
('Bitcoin', 'BTC', 'https://upload.wikimedia.org/wikipedia/commons/4/46/Bitcoin.svg', 'crypto'),
('Ethereum', 'ETH', 'https://upload.wikimedia.org/wikipedia/commons/0/05/Ethereum_logo_2014.svg', 'crypto'),
('Ripple', 'XRP', 'https://altcoinsbox.com/wp-content/uploads/2023/09/xrp-logo-white-background.svg', 'crypto'),
('Litecoin', 'LTC', 'https://upload.wikimedia.org/wikipedia/commons/1/1c/Litecoin.svg', 'crypto');

CREATE VIEW All_Crypto_Coins AS
SELECT *
FROM Coins
WHERE type = 'crypto';

DELIMITER //

CREATE PROCEDURE GetUserAssets(IN userId INT)
BEGIN
    SELECT w.wallet_id, w.user_id, c.coin_name, c.coin_symbol, w.balance
    FROM Wallets w
    JOIN Coins c ON w.coin_id = c.coin_id
    WHERE w.user_id = userId;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE MatchOrders()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE buyOrderId INT;
    DECLARE sellOrderId INT;
    DECLARE buyUserId INT;
    DECLARE sellUserId INT;
    DECLARE coinId INT;
    DECLARE buyQuantity DECIMAL(20, 8);
    DECLARE sellQuantity DECIMAL(20, 8);
    DECLARE buyPrice DECIMAL(20, 8);
    DECLARE sellPrice DECIMAL(20, 8);

    DECLARE cur CURSOR FOR 
        SELECT o1.order_id, o1.user_id, o1.coin_id, o1.quantity, o1.price, o2.order_id, o2.user_id, o2.quantity, o2.price
        FROM Active_orders o1
        JOIN Active_orders o2 ON o1.coin_id = o2.coin_id AND o2.price <= o1.price
        WHERE o1.order_type = 'buy' AND o2.order_type = 'sell'
        ORDER BY o1.price DESC, o1.created_at ASC, o2.price ASC, o2.created_at ASC;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO buyOrderId, buyUserId, coinId, buyQuantity, buyPrice, sellOrderId, sellUserId, sellQuantity, sellPrice;
        IF done THEN
            LEAVE read_loop;
        END IF;

        IF buyQuantity = sellQuantity THEN
            INSERT INTO Transactions (buyer_id, seller_id, coin_id, quantity, price) 
            VALUES (buyUserId, sellUserId, coinId, buyQuantity, buyPrice);

            DELETE FROM Active_orders WHERE order_id = buyOrderId;
            DELETE FROM Active_orders WHERE order_id = sellOrderId;

        ELSEIF buyQuantity < sellQuantity THEN
            INSERT INTO Transactions (buyer_id, seller_id, coin_id, quantity, price) 
            VALUES (buyUserId, sellUserId, coinId, buyQuantity, buyPrice);

            DELETE FROM Active_orders WHERE order_id = buyOrderId;

            UPDATE Active_orders 
            SET quantity = sellQuantity - buyQuantity 
            WHERE order_id = sellOrderId;

        ELSEIF buyQuantity > sellQuantity THEN
            INSERT INTO Transactions (buyer_id, seller_id, coin_id, quantity, price) 
            VALUES (buyUserId, sellUserId, coinId, sellQuantity, sellPrice);

            DELETE FROM Active_orders WHERE order_id = sellOrderId;

            UPDATE Active_orders 
            SET quantity = buyQuantity - sellQuantity 
            WHERE order_id = buyOrderId;
        END IF;
    END LOOP;

    CLOSE cur;
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER after_insert_transactions
AFTER INSERT ON Transactions
FOR EACH ROW
BEGIN
    DECLARE buyerWalletId INT;
    DECLARE sellerWalletId INT;
    DECLARE buyerFeeRate DECIMAL(10, 8);
    DECLARE sellerFeeRate DECIMAL(10, 8);
    DECLARE buyerPayment DECIMAL(20, 8);
    DECLARE sellerReceive DECIMAL(20, 8);

    -- Retrieve the fee rate for the buyer
    SELECT at.fee_rate INTO buyerFeeRate
    FROM Users u
    JOIN Account_Types at ON u.account_type_id = at.type_id
    WHERE u.user_id = NEW.buyer_id;

    -- Retrieve the fee rate for the seller
    SELECT at.fee_rate INTO sellerFeeRate
    FROM Users u
    JOIN Account_Types at ON u.account_type_id = at.type_id
    WHERE u.user_id = NEW.seller_id;

    -- Calculate the payment amount including the buyer's fee
    SET buyerPayment = NEW.quantity * NEW.price * (1 + buyerFeeRate);

    -- Calculate the amount the seller will receive after fees
    SET sellerReceive = NEW.quantity * NEW.price * (1 - sellerFeeRate);

    -- Deduct the payment from the buyer's fiat wallet (assuming USD coin_id = 1)
    UPDATE Wallets
    SET balance = balance - buyerPayment
    WHERE user_id = NEW.buyer_id AND coin_id = 1;

    -- Add the received amount to the seller's fiat wallet (assuming USD coin_id = 1)
    UPDATE Wallets
    SET balance = balance + sellerReceive
    WHERE user_id = NEW.seller_id AND coin_id = 1;

    -- Deduct the sold amount from the seller's crypto wallet
    UPDATE Wallets
    SET balance = balance - NEW.quantity
    WHERE user_id = NEW.seller_id AND coin_id = NEW.coin_id;

    -- Add the bought amount to the buyer's crypto wallet
    SET buyerWalletId = (SELECT wallet_id FROM Wallets WHERE user_id = NEW.buyer_id AND coin_id = NEW.coin_id);
    
    IF buyerWalletId IS NOT NULL THEN
        UPDATE Wallets
        SET balance = balance + NEW.quantity
        WHERE wallet_id = buyerWalletId;
    ELSE
        -- If the buyer's crypto wallet doesn't exist, create one and add the bought amount to it
        INSERT INTO Wallets (user_id, coin_id, balance)
        VALUES (NEW.buyer_id, NEW.coin_id, NEW.quantity);
    END IF;

END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER before_insert_active_orders
BEFORE INSERT ON Active_orders
FOR EACH ROW
BEGIN
    DECLARE userBalance DECIMAL(20, 8);
    DECLARE orderValue DECIMAL(20, 8);
    DECLARE requiredBalance DECIMAL(20, 8);
    DECLARE coinType VARCHAR(10);
    DECLARE accountStatus ENUM('active', 'blocked');

    -- Check the user's account status
    SELECT account_status INTO accountStatus
    FROM Users
    WHERE user_id = NEW.user_id;
    
    IF accountStatus != 'active' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account is blocked.';
    END IF;
    
    SELECT type INTO coinType
    FROM Coins
    WHERE coin_id = NEW.coin_id;
    
    IF NEW.order_type = 'sell' THEN
        IF coinType = 'crypto' THEN
            SELECT balance INTO userBalance
            FROM Wallets
            WHERE user_id = NEW.user_id AND coin_id = NEW.coin_id;
            
            IF userBalance IS NULL OR userBalance < NEW.quantity THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient coins to sell';
            END IF;
        ELSE
          SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You cannot sell fiat currencies.';
        END IF;
    ELSEIF NEW.order_type = 'buy' THEN
        IF coinType = 'crypto' THEN
            -- Calculate the required balance including fees
            SELECT (NEW.quantity * NEW.price) * (1 + (
                SELECT fee_rate
                FROM Account_Types
                WHERE type_id = (
                    SELECT account_type_id
                    FROM Users
                    WHERE user_id = NEW.user_id
                )
            )) INTO requiredBalance;
            
            SELECT balance INTO userBalance
            FROM Wallets
            WHERE user_id = NEW.user_id AND coin_id = 1;
            
            IF userBalance IS NULL OR userBalance < requiredBalance THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient funds to buy';
            END IF;
          ELSE
          SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You cannot buy fiat currencies.';
        END IF;
    END IF;
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER after_insert_wallet_transactions
AFTER INSERT ON Wallet_Transactions
FOR EACH ROW
BEGIN
    DECLARE walletId INT;
    
    -- Find the wallet ID for the user and coin
    SELECT wallet_id INTO walletId
    FROM Wallets
    WHERE user_id = NEW.user_id AND coin_id = NEW.coin_id;
    
    IF NEW.transaction_type = 'deposit' THEN
        IF walletId IS NOT NULL THEN
            -- If the wallet exists, update the balance by adding the amount
            UPDATE Wallets
            SET balance = balance + NEW.amount
            WHERE wallet_id = walletId;
        ELSE
            -- If the wallet does not exist, create a new wallet entry
            INSERT INTO Wallets (user_id, coin_id, balance)
            VALUES (NEW.user_id, NEW.coin_id, NEW.amount);
        END IF;
    ELSEIF NEW.transaction_type = 'withdrawal' THEN
        IF walletId IS NOT NULL THEN
            -- If the wallet exists, update the balance by subtracting the amount
            UPDATE Wallets
            SET balance = balance - NEW.amount
            WHERE wallet_id = walletId;
        ELSE
            -- If the wallet does not exist, create a new wallet entry with a negative balance (which should not happen normally)
            INSERT INTO Wallets (user_id, coin_id, balance)
            VALUES (NEW.user_id, NEW.coin_id, -NEW.amount);
        END IF;
    END IF;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE GetHighestBuyPrice(IN coin_id_param INT)
BEGIN
    SELECT MAX(price) AS highest_buy_price
    FROM Active_orders
    WHERE coin_id = coin_id_param AND order_type = 'buy';
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE GetLowestSellPrice(IN coin_id_param INT)
BEGIN
    SELECT MIN(price) AS lowest_sell_price
    FROM Active_orders
    WHERE coin_id = coin_id_param AND order_type = 'sell';
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE Withdraw(IN user_id INT, IN coin_id INT, IN amount DECIMAL(20, 8))
BEGIN
    DECLARE user_balance DECIMAL(20, 8);
    
    -- Check the current balance of the user for the given coin
    SELECT balance INTO user_balance
    FROM Wallets
    WHERE user_id = user_id AND coin_id = coin_id;
    
    -- If the user's balance is NULL or less than the amount to withdraw, throw an error
    IF user_balance IS NULL OR user_balance < amount THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient balance for withdrawal';
    ELSE
        -- Insert a new record into the Wallet_Transactions table for the withdrawal
        INSERT INTO Wallet_Transactions (user_id, coin_id, transaction_type, amount, transaction_date)
        VALUES (user_id, coin_id, 'withdrawal', amount, NOW());
    END IF;
END //

DELIMITER ;
