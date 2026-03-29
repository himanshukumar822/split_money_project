const Expense = require("../models/Expense");

exports.addExpense = async (req, res) => {
  try {

    const { groupId, description, amount, paidBy, splitBetween } = req.body;

    const expense = new Expense({
      groupId,
      description,
      amount,
      paidBy,
      splitBetween
    });

    await expense.save();

    res.status(201).json({
      message: "Expense added successfully",
      expense
    });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getGroupExpenses = async (req, res) => {
  try {

    const { groupId } = req.params;

    const expenses = await Expense.find({ groupId });

    res.json({
      expenses
    });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
