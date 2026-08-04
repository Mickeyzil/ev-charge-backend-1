const express = require("express");
const {
    getAllStations,
    getStationById
} = require("../controllers/stationController");

const router = express.Router();

router.get("/", getAllStations);
router.get("/:id", getStationById);

module.exports = router;