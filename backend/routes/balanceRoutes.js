const express = require("express");
const router = express.Router();

const { getGroupBalances ,getUserSummary} = require("../controllers/balanceController");

router.get("/:groupId", getGroupBalances);
router.get("/summary/:userName", getUserSummary);

module.exports = router;