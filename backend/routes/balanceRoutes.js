const express = require("express");
const router = express.Router();

const { getGroupBalances } = require("../controllers/balanceController");

router.get("/:groupId", getGroupBalances);

module.exports = router;