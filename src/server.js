require("dotenv").config();

const express = require("express");
const pool = require("./config/db");

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

app.get("/api/health", (req, res) => {
    res.status(200).json({
        success: true,
        message: "EV Charge server is running"
    });
});

// בדיקה זמנית של החיבור למסד הנתונים
app.get("/api/health/database", async (req, res) => {
    try {
        const [rows] = await pool.query(
            "SELECT DATABASE() AS databaseName, NOW() AS serverTime"
        );

        res.status(200).json({
            success: true,
            message: "Database connection is working",
            data: rows[0]
        });
    } catch (error) {
        console.error("Database connection failed:", error.message);

        res.status(500).json({
            success: false,
            message: "Database connection failed"
        });
    }
});

app.get("/api/health/tables", async (req, res) => {
    try {
        const [rows] = await pool.query(`
            SELECT TABLE_NAME AS tableName
            FROM information_schema.tables
            WHERE TABLE_SCHEMA = DATABASE()
            ORDER BY TABLE_NAME
        `);

        res.status(200).json({
            success: true,
            tables: rows.map(row => row.tableName)
        });
    } catch (error) {
        console.error("Failed to read tables:", error.message);

        res.status(500).json({
            success: false,
            message: "Failed to read database tables"
        });
    }
});

app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});