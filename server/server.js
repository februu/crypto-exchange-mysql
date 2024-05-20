const express = require("express");
const mysql = require("mysql");
const bodyParser = require("body-parser");
const session = require("express-session");
const bcrypt = require("bcryptjs");
const cors = require("cors");

const app = express();
const port = 3000;

app.use(cors());
app.use(bodyParser.json());
app.use(
  session({
    secret: "secret-key",
    resave: false,
    saveUninitialized: true,
  })
);

const db = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "",
  database: "crypto_exchange",
});

db.connect((err) => {
  if (err) {
    throw err;
  }
  console.log("> MySQL Connected.");
});

// Register route
app.post("/api/register", async (req, res) => {
  const { fullname, username, email, password, dob, fulladdress } = req.body;

  if (!fullname || !username || !email || !password || !dob || !fulladdress) {
    return res.status(400).json({
      title: "Error",
      message: "Please fill in all fields.",
    });
  }

  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    const userQuery =
      "INSERT INTO Users (username, email, password_hash, account_type_id, account_status) VALUES (?, ?, ?, 1, 'active')";
    db.query(userQuery, [username, email, hashedPassword], (err, result) => {
      if (err) {
        if (err.code === "ER_DUP_ENTRY") {
          return res.status(400).json({
            title: "Error",
            message: "User already exists! ",
          });
        }
        throw err;
      }

      const userId = result.insertId;
      const kycQuery =
        "INSERT INTO KYC_Data (user_id, full_name, date_of_birth, address) VALUES (?, ?, ?, ?)";
      db.query(kycQuery, [userId, fullname, dob, fulladdress], (kycErr) => {
        if (kycErr) throw kycErr;
        return res.status(201).json({
          title: "Success",
          message:
            "User registered successfully! You will now be redirected to the login page.",
        });
      });
    });
  } catch (error) {
    return res.status(500).json({
      title: "Server Error",
      message: "Please try again later.",
    });
  }
});

// Login route
app.post("/api/login", (req, res) => {
  const { username, password } = req.body;

  if (!username || !password) {
    return res
      .status(400)
      .json({ title: "Error", message: "Please fill in all fields." });
  }

  const query = "SELECT * FROM Users WHERE username = ?";
  db.query(query, [username], async (err, results) => {
    if (err) throw err;

    if (results.length === 0) {
      return res
        .status(400)
        .json({ title: "Error", message: "Invalid username or password." });
    }

    const user = results[0];

    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      return res
        .status(400)
        .json({ title: "Error", message: "Invalid username or password." });
    }

    if (user.account_status !== "active") {
      return res.status(403).json({
        title: "Error",
        message: "Account is disabled. Please contact support for assistance.",
      });
    }

    req.session.loggedin = true;
    req.session.username = user.username;
    res.json({
      message: "Login successful.",
      username: user.username,
      user_id: user.user_id,
    });
  });
});

// Get all crypto coins route
app.get("/api/crypto-coins", (req, res) => {
  // Query the database for crypto coins
  const query = "SELECT * FROM Coins WHERE type = 'crypto'";
  db.query(query, (err, results) => {
    if (err) {
      console.error("Error retrieving crypto coins:", err);
      return res.status(500).json({
        message: "An error occurred while fetching crypto coins.",
      });
    }
    // Return the list of crypto coins as JSON response
    res.json(results);
  });
});

// Get highest buy price for a coin route
app.get("/api/coin-price/buy/:coinId", (req, res) => {
  // Query the database for crypto coins
  const query = `Call getHighestBuyPrice(${req.params.coinId})`;
  db.query(query, (err, results) => {
    if (err) {
      console.error("Error retrieving price:", err);
      return res.status(500).json({
        message: "An error occurred while fetching crypto coins.",
      });
    }
    // Return the list of crypto coins as JSON response
    res.json(results);
  });
});

// Get lowest sell price for a coin route
app.get("/api/coin-price/sell/:coinId", (req, res) => {
  // Query the database for crypto coins
  const query = `Call GetLowestSellPrice(${req.params.coinId})`;
  db.query(query, (err, results) => {
    if (err) {
      console.error("Error retrieving price:", err);
      return res.status(500).json({
        message: "An error occurred while fetching crypto coins.",
      });
    }
    // Return the list of crypto coins as JSON response
    res.json(results);
  });
});

// Get balance of all coins for a user route
app.get("/api/user/coins-balance/:user_id", (req, res) => {
  const user_id = req.params.user_id;

  // Query the database to get the balance of all coins for the user
  const query = `
    SELECT c.coin_id, c.coin_name, c.coin_symbol, c.coin_logo_url, w.balance 
    FROM Coins c 
    LEFT JOIN Wallets w ON c.coin_id = w.coin_id AND w.user_id = ?`;

  db.query(query, [user_id], (err, results) => {
    if (err) {
      console.error("Error retrieving user's coins balance:", err);
      return res.status(500).json({
        message: "An error occurred while fetching user's coins balance.",
      });
    }
    // Return the list of coins with their balances as JSON response
    res.json(results);
  });
});

// Place a new order route
app.post("/api/place-order", (req, res) => {
  const { user_id, coin_id, order_type, quantity, price } = req.body;

  if (!user_id || !coin_id || !order_type || !quantity || !price) {
    return res.status(400).json({ message: "Please fill in all fields." });
  }

  const insertOrderQuery = `
    INSERT INTO Active_orders (user_id, coin_id, order_type, quantity, price)
    VALUES (?, ?, ?, ?, ?)`;

  db.query(
    insertOrderQuery,
    [user_id, coin_id, order_type, quantity, price],
    (err, results) => {
      if (err) {
        return res
          .status(400)
          .json({ message: `Failed to place order. ${err}` });
      }

      const callMatchOrdersQuery = `CALL MatchOrders()`;

      db.query(callMatchOrdersQuery, (matchErr, matchResults) => {
        if (matchErr) {
          console.error("Error matching orders:", matchErr);
          return res
            .status(500)
            .json({ message: "Order placed, but failed to match orders." });
        }

        res.status(201).json({ message: "Order placed." });
      });
    }
  );
});

// Deposit route
app.post("/api/deposit", (req, res) => {
  const { user_id, coin_id, amount } = req.body;

  if (!user_id || !coin_id || !amount) {
    return res.status(400).json({ message: "Please fill in all fields." });
  }

  const insertTransactionQuery = `
    INSERT INTO Wallet_transactions (user_id, coin_id, transaction_type, amount, transaction_date)
    VALUES (?, ?, 'deposit', ?, NOW())`;

  db.query(
    insertTransactionQuery,
    [user_id, coin_id, amount],
    (err, results) => {
      if (err) {
        console.error("Error inserting deposit transaction:", err);
        return res.status(400).json({ message: "Failed to deposit." });
      }

      res.status(201).json({ message: "Deposit successful." });
    }
  );
});

app.post("/api/withdraw", (req, res) => {
  const { user_id, coin_id, amount } = req.body;

  if (!user_id || !coin_id || !amount) {
    return res.status(400).json({ message: "Please fill in all fields." });
  }

  const withdrawProcedureQuery = `
    CALL Withdraw(?, ?, ?)`;

  db.query(
    withdrawProcedureQuery,
    [user_id, coin_id, amount],
    (err, results) => {
      if (err) {
        console.error("Error executing withdrawal procedure:", err);
        return res.status(400).json({ message: "Failed to withdraw." });
      }

      res.status(201).json({ message: "Withdrawal successful." });
    }
  );
});

// Route to change user account type
app.put("/api/user/account-type", (req, res) => {
  const { user_id, new_account_type_id } = req.body;

  if (!user_id || !new_account_type_id) {
    return res
      .status(400)
      .json({ message: "User ID and new account type ID are required." });
  }

  const query = "UPDATE Users SET account_type_id = ? WHERE user_id = ?";
  db.query(query, [new_account_type_id, user_id], (err, result) => {
    if (err) {
      console.error("Error updating account type:", err);
      return res
        .status(500)
        .json({ message: "An error occurred while updating account type." });
    }

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: "User not found." });
    }

    res.status(200).json({ message: "Account type updated successfully." });
  });
});

// Route to get all account types
app.get("/api/account-types", (req, res) => {
  const query = "SELECT * FROM Account_Types";

  db.query(query, (err, results) => {
    if (err) {
      console.error("Error retrieving account types:", err);
      return res
        .status(500)
        .json({ message: "An error occurred while fetching account types." });
    }

    res.status(200).json(results);
  });
});

// Route to get all users
app.get("/api/users", (req, res) => {
  const query = `
    SELECT u.*, k.full_name, k.address, at.type_name AS account_type_name
    FROM Users u
    LEFT JOIN KYC_Data k ON u.user_id = k.user_id
    LEFT JOIN Account_Types at ON u.account_type_id = at.type_id
  `;

  db.query(query, (err, results) => {
    if (err) {
      console.error("Error retrieving users:", err);
      return res
        .status(500)
        .json({ message: "An error occurred while fetching users." });
    }

    res.status(200).json(results);
  });
});

// Route to set user account status
app.put("/api/user/account-status", (req, res) => {
  const { user_id, account_status } = req.body;

  if (!user_id || !account_status) {
    return res
      .status(400)
      .json({ message: "User ID and account status are required." });
  }

  if (account_status !== "active" && account_status !== "blocked") {
    return res.status(400).json({ message: "Invalid account status." });
  }

  const query = "UPDATE Users SET account_status = ? WHERE user_id = ?";
  db.query(query, [account_status, user_id], (err, result) => {
    if (err) {
      console.error("Error updating account status:", err);
      return res
        .status(500)
        .json({ message: "An error occurred while updating account status." });
    }

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: "User not found." });
    }

    res.status(200).json({ message: "Account status updated successfully." });
  });
});

app.listen(port, () => {
  console.log(`> Server running on http://localhost:${port}.`);
});
