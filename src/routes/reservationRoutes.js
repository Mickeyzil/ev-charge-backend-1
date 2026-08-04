const express = require("express");

const {
    getMyReservations
} = require("../controllers/reservationController");

const {
    authenticateToken
} = require("../middleware/authMiddleware");

const router = express.Router();

router.get("/my", authenticateToken, getMyReservations);

module.exports = router;