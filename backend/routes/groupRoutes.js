const express = require("express");

const router = express.Router();

const {
  createGroup,
  getUserGroups,
  addMember,
  archiveGroup,
  getArchivedGroups,
  restoreGroup,
} = require("../controllers/groupController");

const {
  getGroupBalances,
} = require("../controllers/balanceController");

router.post("/create", createGroup);

router.get("/:userId", getUserGroups);

// Backup / Archive
router.post("/:groupId/archive", archiveGroup);

router.get("/:userId/backup", getArchivedGroups);

router.post("/:groupId/restore", restoreGroup);

router.post("/:groupId/add-member", addMember);

// Balance
router.get("/:groupId/balance", getGroupBalances);

module.exports = router;