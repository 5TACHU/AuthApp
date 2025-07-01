const express = require("express");
const cors = require("cors");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const mysql = require("mysql2/promise");
require("dotenv").config();

const app = express();
app.use(cors());
app.use(express.json());

const db = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

// Walidatory
function isValidEmail(email) {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

function isStrongPassword(password) {
  const lengthValid = password.length >= 8;
  const hasUppercase = /[A-Z]/.test(password);
  const hasSpecialChar = /[^a-zA-Z0-9]/.test(password);
  return lengthValid && hasUppercase && hasSpecialChar;
}


// Rejestracja
app.post("/register", async (req, res) => {
  const { email, password } = req.body;

  if(!email || !password){
    return res.status(400).json({ error: "Email i hasło są wymagane."});
  }
  if(!isValidEmail(email)){
    return res.status(400).json({ error: "Niepoprawny format adresu email."});
  }
  if (!isStrongPassword(password)){
    return res.status(400).json({error: "Hasło musi mieć min. 8 znaków, jedną dużą literę i znak specjalny." });
  }

  try {
    const hash = await bcrypt.hash(password, 10);
    await db.query("INSERT INTO users (email, password) VALUES (?, ?)", [email, hash]);
    res.json({ success: true, message: "Konto zostało utworzone." });
  } catch (err) {
    if (err.code === "ER_DUP_ENTRY") {
      res.status(400).json({ error: "Użytkownik z tym adresem email już istnieje." });
    } else {
      res.status(500).json({ error: "Błąd serwera." });
    }
  }
});

// Logowanie
app.post("/login", async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password){
    return res.status(400).json({ error: "Email i hasło są wymagane." });
  }

  const [rows] = await db.query("SELECT * FROM users WHERE email = ?", [email]);
  const user = rows[0];
  if (!user) return res.status(400).json({ error: "Nie znaleziono użytkownika." });

  const match = await bcrypt.compare(password, user.password);
  if (!match) return res.status(401).json({ error: "Niepoprawne hasło." });

  const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET);
  res.json({ token });
});

// Zmiana hasła
app.post("/change-password", async (req, res) => {
  const { token, newPassword } = req.body;

  if (!newPassword){
    return res.status(400).json({ error: "Nowe hasło jest wymagane." });
  }
  if (!isStrongPassword(newPassword)){
    return res.status(400).json({ error: "Nowe hasło musi mieć min. 8 znaków, dużą literę i znak specjalny." });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const hash = await bcrypt.hash(newPassword, 10);
    await db.query("UPDATE users SET password = ? WHERE id = ?", [hash, decoded.id]);
    res.json({ success: true, message: "Hasło zostało zmienione." });
  } catch {
    res.status(401).json({ error: "Nieprawidłowy token." });
  }
});

// Usunięcie konta
app.post("/delete-account", async (req, res) => {
  const { token } = req.body;
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    await db.query("DELETE FROM users WHERE id = ?", [decoded.id]);
    res.json({ success: true, message: "Konto zostało utworzone." });
  } catch {
    res.status(401).json({ error: "Nieprawidłowy token." });
  }
});

app.listen(process.env.PORT, () => {
  console.log(`Server running at http://localhost:${process.env.PORT}`);
});
