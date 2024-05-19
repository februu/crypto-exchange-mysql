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

app.get("/", (req, res) => {
  if (req.session.loggedin) {
    res.json({ message: `Welcome back, ${req.session.username}!` });
  } else {
    res.json({ message: "Please login to view this page!" });
  }
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
    return res.status(400).json({ message: "Please fill in all fields." });
  }

  const query = "SELECT * FROM Users WHERE username = ?";
  db.query(query, [username], async (err, results) => {
    if (err) throw err;

    if (results.length === 0) {
      return res.status(400).json({ message: "Invalid username or password." });
    }

    const user = results[0];

    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      return res.status(400).json({ message: "Invalid username or password." });
    }

    if (user.account_status !== "active") {
      return res.status(403).json({
        message: "Account is disabled. Please contact support for assistance.",
      });
    }

    req.session.loggedin = true;
    req.session.username = user.username;
    res.json({ message: "Login successful.", username: user.username });
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

// Get balance of all coins for a user route
app.get("/api/user/coins-balance/:userId", (req, res) => {
  const userId = req.params.userId;

  // Query the database to get the balance of all coins for the user
  const query = `
    SELECT c.coin_id, c.coin_name, c.coin_symbol, w.balance 
    FROM Coins c 
    LEFT JOIN Wallets w ON c.coin_id = w.coin_id AND w.user_id = ?`;

  db.query(query, [userId], (err, results) => {
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

app.listen(port, () => {
  console.log(`> Server running on http://localhost:${port}.`);
});
