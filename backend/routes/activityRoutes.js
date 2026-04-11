const express = require("express");
const router = express.Router();

const auth = require("../config/auth");
const { getActivities } = require("../controllers/activityController");

router.get("/", auth, getActivities);

module.exports = router;