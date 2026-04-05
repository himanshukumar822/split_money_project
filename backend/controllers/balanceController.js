const Expense = require("../models/Expense");


// ✅ STEP 1 — Calculate Net Balances (FIXED)
exports.calculateBalances = (expenses) => {
  const balances = {};

  expenses.forEach((expense) => {

    if (!expense.splitBetween || expense.splitBetween.length === 0) return;

    const share = expense.amount / expense.splitBetween.length;

    // 🟢 NORMAL EXPENSE
    if (!expense.isSettlement) {

      expense.splitBetween.forEach((user) => {
        balances[user] = (balances[user] || 0) - share;
      });

      balances[expense.paidBy] =
        (balances[expense.paidBy] || 0) + expense.amount;
    }

    // 🔥 SETTLEMENT EXPENSE (REVERSE EFFECT)
    else {
      const from = expense.paidBy;
      const to = expense.splitBetween[0];

      balances[from] = (balances[from] || 0) - expense.amount;
      balances[to] = (balances[to] || 0) + expense.amount;
    }

  });

  // ✅ rounding
  for (let user in balances) {
    balances[user] = Math.round(balances[user]);
  }

  return balances;
};



// ✅ STEP 2 — Simplify to Transactions (NO CHANGE)
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



// ✅ STEP 3 — API: Get Group Balance (FIXED)
exports.getGroupBalances = async (req, res) => {

  try {

    const { groupId } = req.params;

    // ✅ FETCH ALL (NO FILTER ❌)
    const expenses = await Expense.find({ groupId });

    const balances = exports.calculateBalances(expenses);
    const transactions = exports.splitMoney(balances);

    res.json({
      balances,
      transactions
    });

  } catch (error) {
    console.error("Balance Error:", error);
    res.status(500).json({ error: error.message });
  }
};



// ✅ STEP 4 — USER SUMMARY (FIXED)
exports.getUserSummary = async (req, res) => {
  try {
    const { userName } = req.params;

    // ✅ FETCH ALL (NO FILTER ❌)
    const expenses = await Expense.find();

    let netBalance = 0;

    expenses.forEach(expense => {

      if (!expense.splitBetween || expense.splitBetween.length === 0) return;

      const share = expense.amount / expense.splitBetween.length;

      const paidBy =
        expense.paidBy === "You" ? userName : expense.paidBy;

      const members = expense.splitBetween.map(u =>
        u === "You" ? userName : u
      );

      // 🟢 NORMAL EXPENSE
      if (!expense.isSettlement) {

        if (paidBy === userName) {
          netBalance += expense.amount - share;
        } else if (members.includes(userName)) {
          netBalance -= share;
        }

      }

      // 🔥 SETTLEMENT
      else {
        const from = expense.paidBy;
        const to = expense.splitBetween[0];

        if (from === userName) {
          netBalance -= expense.amount;
        }

        if (to === userName) {
          netBalance += expense.amount;
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