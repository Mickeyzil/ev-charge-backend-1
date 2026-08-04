const bcrypt = require("bcryptjs");
const pool = require("../config/db");
const jwt = require("jsonwebtoken");

const registerUser = async (req, res) => {
    try {
        const {
            full_name,
            email,
            password,
            phone,
            car_model
        } = req.body;

        // בדיקה שכל השדות התקבלו
        if (!full_name || !email || !password || !phone || !car_model) {
            return res.status(400).json({
                success: false,
                message: "All fields are required"
            });
        }

        // יצירת Hash מהסיסמה
        const hashedPassword = await bcrypt.hash(password, 10);

        const [result] = await pool.query(
            `INSERT INTO users
             (full_name, email, password, phone, car_model)
             VALUES (?, ?, ?, ?, ?)`,
            [
                full_name.trim(),
                email.trim().toLowerCase(),
                hashedPassword,
                phone.trim(),
                car_model.trim()
            ]
        );

        return res.status(201).json({
            success: true,
            message: "User registered successfully",
            user: {
                user_id: result.insertId,
                full_name: full_name.trim(),
                email: email.trim().toLowerCase(),
                phone: phone.trim(),
                car_model: car_model.trim()
            }
        });
    } catch (error) {
        // ניסיון להירשם עם אימייל שכבר קיים
        if (error.code === "ER_DUP_ENTRY") {
            return res.status(409).json({
                success: false,
                message: "Email already exists"
            });
        }

        console.error("Register user error:", error);

        return res.status(500).json({
            success: false,
            message: "Internal server error"
        });
    }
};

const loginUser = async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({
                success: false,
                message: "Email and password are required"
            });
        }

        const normalizedEmail = email.trim().toLowerCase();

        // חיפוש המשתמש לפי האימייל
        const [rows] = await pool.query(
            `SELECT user_id, full_name, email, password, phone, car_model
             FROM users
             WHERE email = ?`,
            [normalizedEmail]
        );

        // לא מציינים אם האימייל או הסיסמה שגויים
        if (rows.length === 0) {
            return res.status(401).json({
                success: false,
                message: "Invalid email or password"
            });
        }

        const user = rows[0];

        // השוואת הסיסמה ל-Hash השמור
        const passwordMatches = await bcrypt.compare(
            password,
            user.password
        );

        if (!passwordMatches) {
            return res.status(401).json({
                success: false,
                message: "Invalid email or password"
            });
        }

        const token = jwt.sign(
            {
                userId: user.user_id
            },
            process.env.JWT_SECRET,
            {
                expiresIn: process.env.JWT_EXPIRES_IN || "1h",
                algorithm: "HS256"
            }
        );

        return res.status(200).json({
            success: true,
            message: "Login successful",
            token,
            user: {
                user_id: user.user_id,
                full_name: user.full_name,
                email: user.email,
                phone: user.phone,
                car_model: user.car_model
            }
        });
    } catch (error) {
        console.error("Login user error:", error);

        return res.status(500).json({
            success: false,
            message: "Internal server error"
        });
    }
};

const getCurrentUser = async (req, res) => {
    try {
        const [rows] = await pool.query(
            `SELECT user_id, full_name, email, phone, car_model
             FROM users
             WHERE user_id = ?`,
            [req.userId]
        );

        if (rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: "User not found"
            });
        }

        return res.status(200).json({
            success: true,
            user: rows[0]
        });
    } catch (error) {
        console.error("Get current user error:", error);

        return res.status(500).json({
            success: false,
            message: "Internal server error"
        });
    }
};

module.exports = {
    registerUser,
    loginUser,
    getCurrentUser
};