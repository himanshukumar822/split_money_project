const express = require("express");
const router = express.Router();

const auth = require("../config/auth"); // ✅ ADD THIS

const {
  addExpense,
  getGroupExpenses
} = require("../controllers/expenseController");

router.post("/add", auth, addExpense);          // ✅ FIXED
router.get("/:groupId", auth, getGroupExpenses); // ✅ FIXED

module.exports = router;