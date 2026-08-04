const pool = require("../config/db");

const getAllStations = async (req, res) => {
    try {
        const [stations] = await pool.query(`
            SELECT
                station_id,
                name,
                available_slots,
                total_slots,
                power_kw,
                price_kwh,
                connectors,
                amenities,
                latitude,
                longitude
            FROM stations
            ORDER BY station_id
        `);

        return res.status(200).json({
            success: true,
            count: stations.length,
            stations
        });
    } catch (error) {
        console.error("Get stations error:", error);

        return res.status(500).json({
            success: false,
            message: "Internal server error"
        });
    }
};

const getStationById = async (req, res) => {
    try {
        const stationId = Number(req.params.id);

        if (!Number.isInteger(stationId) || stationId <= 0) {
            return res.status(400).json({
                success: false,
                message: "Invalid station ID"
            });
        }

        const [stations] = await pool.query(
            `SELECT
                station_id,
                name,
                available_slots,
                total_slots,
                power_kw,
                price_kwh,
                connectors,
                amenities,
                latitude,
                longitude
             FROM stations
             WHERE station_id = ?`,
            [stationId]
        );

        if (stations.length === 0) {
            return res.status(404).json({
                success: false,
                message: "Station not found"
            });
        }

        return res.status(200).json({
            success: true,
            station: stations[0]
        });
    } catch (error) {
        console.error("Get station by ID error:", error);

        return res.status(500).json({
            success: false,
            message: "Internal server error"
        });
    }
};

module.exports = {
    getAllStations,
    getStationById
};