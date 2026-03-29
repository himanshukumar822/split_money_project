const express = require("express");
const router = express.Router();

const { createGroup,getUserGroups,addMember } = require("../controllers/groupController");

router.post("/create", createGroup);
router.get("/:userId", getUserGroups);
router.post("/:groupId/add-member",addMember);
module.exports = router;