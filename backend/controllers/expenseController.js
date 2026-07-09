const Expense = require("../models/Expense");
const Group = require("../models/Group");
const Activity = require("../models/activity");

exports.addExpense = async (req, res) => {
  try {
    const {
      groupId,
      description,
      amount,
      paidBy,
      splitBetween,
      isSettlement,
    } = req.body;

    const isSettlementFlag =
      isSettlement === true || isSettlement === "true";

    // Save names directly
    const expense = new Expense({
      groupId,
      description,
      amount,
      paidBy,
      splitBetween,
      isSettlement: isSettlementFlag,
    });

    await expense.save();

    // Add expense to group
    await Group.findByIdAndUpdate(groupId, {
      $push: { expenses: expense._id },
    });

    const group = await Group.findById(groupId);

    // Activity
    if (isSettlementFlag) {
      await Activity.create({
        type: "SETTLEMENT",
        message: `${splitBetween[0]} paid ₹${amount} to ${paidBy} in ${
          group?.name || "group"
        }`,
        groupId,
      });
    } else {
      await Activity.create({
        type: "EXPENSE_ADDED",
        message: `${paidBy} added "${description}" in ${
          group?.name || "group"
        }`,
        groupId,
      });
    }

    res.status(201).json({
      message: "Expense added successfully",
      expense,
    });
  } catch (error) {
    console.log("ERROR SAVING EXPENSE:", error);
    res.status(500).json({
      error: error.message,
    });
  }
};

// GET GROUP EXPENSES
exports.getGroupExpenses = async (req, res) => {
  try {
    const { groupId } = req.params;

    const expenses = await Expense.find({
      groupId,
      isSettlement: false,
    });

    res.json({
      expenses,
    });
  } catch (error) {
    console.log("ERROR FETCHING EXPENSES:", error);
    res.status(500).json({
      error: error.message,
    });
  }
};
