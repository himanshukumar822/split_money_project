const Expense = require("../models/Expense");
const Group = require("../models/Group");
const Activity = require("../models/activity");
const User = require("../models/user");

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

    // ✅ ensure boolean
    const isSettlementFlag =
      isSettlement === true || isSettlement === "true";

    // 🔥 STEP 1: CONVERT paidBy → userId
    let paidById = paidBy;

    if (!paidBy.match(/^[0-9a-fA-F]{24}$/)) {
      const user = await User.findOne({ name: paidBy });
      if (user) paidById = user._id;
    }

    // 🔥 STEP 2: CONVERT splitBetween → userIds
    let splitBetweenIds = await Promise.all(
      splitBetween.map(async (item) => {
        if (item.match(/^[0-9a-fA-F]{24}$/)) return item;

        const user = await User.findOne({ name: item });
        return user ? user._id : null;
      })
    );

    // remove null values
    splitBetweenIds = splitBetweenIds.filter(Boolean);

    // 🔥 STEP 3: CREATE EXPENSE
    const expense = new Expense({
      groupId,
      description,
      amount,
      paidBy: paidById,
      splitBetween: splitBetweenIds,
      isSettlement: isSettlementFlag,
    });

    const savedExpense = await expense.save();

    const group = await Group.findById(groupId);

    // 🔥 STEP 4: GET USER NAMES (for activity logs only)
    const paidByUser = await User.findById(paidById);
    const paidByName = paidByUser?.name || "Unknown";

    // ✅ ACTIVITY LOGIC
    if (isSettlementFlag) {
      const payerId = splitBetweenIds[0]; // who paid back
      const receiverId = paidById;

      const payerUser = await User.findById(payerId);
      const receiverUser = await User.findById(receiverId);

      const payerName = payerUser?.name || "Unknown";
      const receiverName = receiverUser?.name || "Unknown";

      await Activity.create({
        user: payerId,
        type: "SETTLEMENT",
        message: `${payerName} paid ₹${amount} to ${receiverName} in ${
          group?.name || "group"
        }`,
        groupId: groupId,
      });
    } else {
      await Activity.create({
        user: paidById,
        type: "EXPENSE_ADDED",
        message: `${paidByName} added "${description}" in ${
          group?.name || "group"
        }`,
        groupId: groupId,
      });
    }

    // 🔥 STEP 5: ADD EXPENSE TO GROUP
    await Group.findByIdAndUpdate(groupId, {
      $push: { expenses: expense._id },
    });

    res.status(201).json({
      message: "Expense added successfully",
      expense,
    });
  } catch (error) {
    console.log("ERROR SAVING EXPENSE:", error);
    res.status(500).json({ error: error.message });
  }
};

// ✅ GET GROUP EXPENSES
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