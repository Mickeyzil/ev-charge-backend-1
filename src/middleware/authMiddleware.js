const jwt = require("jsonwebtoken");

const authenticateToken = (req, res, next) => {
    const authorizationHeader = req.headers.authorization;

    if (
        !authorizationHeader ||
        !authorizationHeader.startsWith("Bearer ")
    ) {
        return res.status(401).json({
            success: false,
            message: "Authentication token is required"
        });
    }

    const token = authorizationHeader.substring(7);

    try {
        const decoded = jwt.verify(
            token,
            process.env.JWT_SECRET,
            {
                algorithms: ["HS256"]
            }
        );

        if (!decoded.userId) {
            return res.status(401).json({
                success: false,
                message: "Invalid authentication token"
            });
        }

        req.userId = decoded.userId;

        next();
    } catch (error) {
        if (error.name === "TokenExpiredError") {
            return res.status(401).json({
                success: false,
                message: "Authentication token has expired"
            });
        }

        return res.status(401).json({
            success: false,
            message: "Invalid authentication token"
        });
    }
};

module.exports = {
    authenticateToken
};