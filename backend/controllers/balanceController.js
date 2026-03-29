exports.calculateBalances = (expenses) => {

  const balances = {};

  expenses.forEach(expense => {

    const share = expense.amount / expense.splitBetween.length;

    expense.splitBetween.forEach(user => {

      if (!balances[user]) {
        balances[user] = 0;
      }

      balances[user] -= share;
    });

    if (!balances[expense.paidBy]) {
      balances[expense.paidBy] = 0;
    }

    balances[expense.paidBy] += expense.amount;

  });

  return balances;
};

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

  while (creditors.length && debtors.length) {

    let creditor = creditors[0];
    let debtor = debtors[0];

    let amount = Math.min(creditor.amount, debtor.amount);

    transactions.push({
      from: debtor.user,
      to: creditor.user,
      amount
    });

    creditor.amount -= amount;
    debtor.amount -= amount;

    if (creditor.amount === 0) creditors.shift();
    if (debtor.amount === 0) debtors.shift();
  }

  return transactions;
};

const Expense = require("../models/Expense");

exports.getGroupBalances = async (req, res) => {

  try {

    const { groupId } = req.params;

    const expenses = await Expense.find({ groupId });

    const balances = exports.calculateBalances(expenses);

    const transactions = exports.splitMoney(balances);

    res.json({
      balances,
      transactions
    });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }

};