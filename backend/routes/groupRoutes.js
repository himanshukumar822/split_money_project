const express = require("express");
const router = express.Router();

const {
  createGroup,
  getUserGroups,
  addMember
} = require("../controllers/groupController");

const {
  getGroupBalances
} = require("../controllers/balanceController");

router.post("/create", createGroup);
router.get("/:userId", getUserGroups);
router.post("/:groupId/add-member", addMember);

// ✅ ADD THIS
router.get("/:groupId/balance", getGroupBalances);

module.exports = router;