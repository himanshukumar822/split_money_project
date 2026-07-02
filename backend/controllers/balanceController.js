const Expense = require("../models/Expense");


// ✅ STEP 1 — Calculate Net Balances
exports.calculateBalances = (expenses) => {
  const balances = {};

  expenses.forEach((expense) => {

    if (!expense.splitBetween || expense.splitBetween.length === 0) return;

    // 🟢 NORMAL EXPENSE (FIXED SPLIT)
    if (!expense.isSettlement) {

      const total = expense.amount;
      const count = expense.splitBetween.length;

      const baseShare = Math.floor(total / count);
      let remainder = total % count;

      expense.splitBetween.forEach((user) => {
        let share = baseShare;

        if (remainder > 0) {
          share += 1;
          remainder--;
        }

        balances[user] = (balances[user] || 0) - share;
      });

      balances[expense.paidBy] =
        (balances[expense.paidBy] || 0) + expense.amount;
    }

    // 🔥 SETTLEMENT (NO CHANGE)
    else {
      const receiver = expense.paidBy;
      const payer = expense.splitBetween[0];

      balances[receiver] = (balances[receiver] || 0) - expense.amount;
      balances[payer] = (balances[payer] || 0) + expense.amount;
    }

  });

  // ✅ rounding safeguard
  for (let user in balances) {
    balances[user] = Math.round(balances[user]);
  }

  return balances;
};



// ✅ STEP 2 — Simplify to Transactions
exports.splitMoney = (balances) => {

  const creditors = [];
  const debtors = [];
  const transactions = [];

  for (let user in balances) {

    if (balances[user] > 0) {
      creditors.push({ user, amount: balances[user] });
    }

    if (balances[user] < 0) {
      debtors.push({ user, amount: -balances[user] });
    }
  }

  let i = 0, j = 0;

  while (i < debtors.length && j < creditors.length) {

    let debtor = debtors[i];
    let creditor = creditors[j];

    let amount = Math.min(debtor.amount, creditor.amount);
    amount = Math.round(amount);

    transactions.push({
      from: debtor.user,
      to: creditor.user,
      amount
    });

    debtor.amount -= amount;
    creditor.amount -= amount;

    if (debtor.amount === 0) i++;
    if (creditor.amount === 0) j++;
  }

  return transactions;
};



// ✅ STEP 3 — API: Get Group Balance
exports.getGroupBalances = async (req, res) => {
  try {
    const { groupId } = req.params;

  
    const expenses = await Expense.find({ groupId });

// 🔥 FILTER INVALID DATA (IMPORTANT)
const cleanExpenses = expenses.filter((e) => {
  return (
    e.paidBy &&
    typeof e.paidBy === "string" &&
    e.splitBetween &&
    e.splitBetween.length > 0
  );
});

    const balances = exports.calculateBalances(cleanExpenses);
    const transactions = exports.splitMoney(balances);

    // 🔥 RETURN ONLY TRANSACTIONS (IMPORTANT)
    res.json(transactions);

  } catch (error) {
    console.error("Balance Error:", error);
    res.status(500).json({ error: error.message });
  }
};



// ✅ STEP 4 — USER SUMMARY (FINAL FIXED)
exports.getUserSummary = async (req, res) => {
  try {
    const { userId } = req.params;

    const expenses = await Expense.find();

    let netBalance = 0;

    expenses.forEach((expense) => {

      if (!expense.splitBetween || expense.splitBetween.length === 0) return;

      const share = expense.amount / expense.splitBetween.length;

      const paidBy = expense.paidBy;
      const members = expense.splitBetween;

      // ✅ FILTER
      if (paidBy !== userId && !members.includes(userId)) {
        return;
      }

      // 🟢 NORMAL EXPENSE
      if (!expense.isSettlement) {

        if (paidBy === userId) {
          netBalance += expense.amount - share;
        } else if (members.includes(userId)) {
          netBalance -= share;
        }

      }

      // 🔥 SETTLEMENT
      else {
        const receiver = paidBy;
        const payer = members[0];

        if (payer === userId) {
          netBalance += expense.amount;
        }

        if (receiver === userId) {
          netBalance -= expense.amount;
        }
      }

    });

    let youOwe = 0;
    let youGet = 0;

    if (netBalance > 0) {
      youGet = netBalance;
    } else {
      youOwe = Math.abs(netBalance);
    }

    res.json({
      youOwe: Math.round(youOwe),
      youGet: Math.round(youGet),
    });

  } catch (error) {
    console.log("BALANCE ERROR:", error);
    res.status(500).json({ error: error.message });
  }
};