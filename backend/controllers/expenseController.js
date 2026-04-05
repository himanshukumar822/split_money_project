const Expense = require("../models/Expense");
const Group = require("../models/Group");
const Activity = require("../models/activity");

exports.addExpense = async (req, res) => {
  try {
    const { groupId, description, amount, paidBy, splitBetween, isSettlement } = req.body;

    // ✅ ensure boolean
    const isSettlementFlag = isSettlement === true || isSettlement === "true";

    const expense = new Expense({
      groupId,
      description,
      amount,
      paidBy,
      splitBetween,
      isSettlement: isSettlementFlag
    });

    const savedExpense = await expense.save();

    const group = await Group.findById(groupId);

    // ✅ CLEAN ACTIVITY (NO "OWES")
    if (isSettlementFlag) {
      const payer = splitBetween[0];
      const receiver = paidBy;

      await Activity.create({
        user: payer,
        type: "SETTLEMENT",
        message: `${payer} paid ₹${amount} to ${receiver} in ${group?.name || "group"}`,
        groupId: groupId
      });

    } else {
      await Activity.create({
        user: paidBy,
        type: "EXPENSE_ADDED",
        message: `Expense "${description}" added in ${group?.name || "group"}`,
        groupId: groupId
      });
    }

    await Group.findByIdAndUpdate(groupId, {
      $push: { expenses: expense._id },
    });

    res.status(201).json({
      message: "Expense added successfully",
      expense
    });

  } catch (error) {
    console.log("ERROR SAVING EXPENSE:", error);
    res.status(500).json({ error: error.message });
  }
};


// ✅ GET GROUP EXPENSES (NO CHANGE)
exports.getGroupExpenses = async (req, res) => {
  try {
    const { groupId } = req.params;

    const expenses = await Expense.find({
      groupId,
      isSettlement: false // hide settlement
    });

    res.json({
      expenses
    });

  } catch (error) {
    console.log("ERROR FETCHING EXPENSES:", error);
    res.status(500).json({ error: error.message });
  }
};
// //exports.settleExpense = async (req, res) => {
//   try {
//     const { expenseId } = req.params;

//     const expense = await Expense.findById(expenseId);

//     if (!expense) {
//       return res.status(404).json({ message: "Expense not found" });
//     }

//     if (expense.settled) {
//       return res.status(400).json({ message: "Already settled" });
//     }

//     expense.settled = true;
//     await expense.save();

//     res.status(200).json({
//       message: "Expense settled successfully",
//       expense
//     });

//   } catch (error) {
//     res.status(500).json({ error: error.message });
//   }
// //};