const express = require("express");
const {
    registerUser,
    loginUser,
    getCurrentUser
} = require("../controllers/UserController");

const {
    authenticateToken
} = require("../middleware/authMiddleware");

const router = express.Router();

router.post("/register", registerUser);
router.post("/login", loginUser);
router.get("/me", authenticateToken, getCurrentUser);

router.post("/register", registerUser);

module.exports = router;