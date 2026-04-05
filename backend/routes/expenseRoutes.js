const express = require("express");
const router = express.Router();

const {
  addExpense,
  getGroupExpenses
} = require("../controllers/expenseController");

// 🔍 DEBUG
console.log("addExpense:", addExpense);
console.log("getGroupExpenses:", getGroupExpenses);

router.post("/add", addExpense);
router.get("/:groupId", getGroupExpenses);

module.exports = router;