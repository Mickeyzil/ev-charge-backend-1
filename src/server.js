require("dotenv").config();
const userRoutes = require("./routes/UserRoutes");
const express = require("express");
const pool = require("./config/db");
const stationRoutes = require("./routes/stationRoutes");

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());
app.use("/api/stations", stationRoutes);
app.use("/api/users", userRoutes);

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

app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});