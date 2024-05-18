const express = require("express");
const mysql = require("mysql");
const bodyParser = require("body-parser");
const session = require("express-session");
const bcrypt = require("bcryptjs");

const app = express();
const port = 3000;

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

app.listen(port, () => {
  console.log(`> Server running on http://localhost:${port}.`);
});
