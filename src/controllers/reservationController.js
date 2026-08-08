const pool = require("../config/db");

const getMyReservations = async (req, res) => {
    try {
        // מתקבל מה-token, לא מהמשתמש
        const userId = req.userId;

        const [reservations] = await pool.query(
            `SELECT
                full_name,
                DATE_FORMAT(arrival_date, '%Y-%m-%d') AS arrival_date,
                TIME_FORMAT(arrival_time, '%H:%i') AS arrival_time
             FROM reservations
             WHERE user_id = ?
             ORDER BY arrival_date ASC, arrival_time ASC`,
            [userId]
        );

        return res.status(200).json({
            success: true,
            reservations
        });
    } catch (error) {
        console.error("Get reservations error:", error);

        return res.status(500).json({
            success: false,
            message: "Internal server error"
        });
    }
};

module.exports = {
    getMyReservations
};