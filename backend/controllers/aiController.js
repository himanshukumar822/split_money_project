const { GoogleGenAI } = require("@google/genai");

const Group = require("../models/Group");
const Expense = require("../models/Expense");
const AIChat = require("../models/AIChat");

const balanceController = require("./balanceController");

const ai = new GoogleGenAI({
  apiKey: process.env.GEMINI_API_KEY,
});

exports.chatWithAI = async (req, res) => {
  try {
    const { message, userId } = req.body;

    if (!message || !message.trim()) {
      return res.status(400).json({
        message: "Message is required",
      });
    }

    if (!userId) {
      return res.status(400).json({
        message: "User ID is required",
      });
    }

    const cleanMessage = message.trim();
    const lowerMessage = cleanMessage.toLowerCase();

    // --------------------------------------------------
    // MONEY AI DOMAIN RESTRICTION
    // --------------------------------------------------

    const greetings = [
      "hi",
      "hello",
      "hey",
      "hii",
      "hiii",
      "good morning",
      "good afternoon",
      "good evening",
      "good night",
    ];

    const isGreeting = greetings.includes(lowerMessage);

    const moneyKeywords = [
      "expense",
      "expenses",
      "spend",
      "spending",
      "spent",
      "money",
      "balance",
      "balances",
      "owe",
      "owes",
      "owed",
      "debt",
      "debts",
      "settle",
      "settlement",
      "settlements",
      "paid",
      "pay",
      "payment",
      "payments",
      "group",
      "groups",
      "friend",
      "friends",
      "split",
      "splits",
      "share",
      "shares",
      "transaction",
      "transactions",
      "bill",
      "bills",
      "cost",
      "costs",
      "app",
      "account",
      "spending",
      "financial",
      "finance",
      "trip",
      "roommate",
      "roommates",
    ];

    const isMoneyRelated = moneyKeywords.some((keyword) =>
      lowerMessage.includes(keyword)
    );

    // --------------------------------------------------
    // HANDLE GREETINGS WITHOUT USING GEMINI
    // --------------------------------------------------

    if (isGreeting) {
      const greetingReply =
          "Hello! 👋 I'm Money AI. How can I help you with your expenses, balances, groups or settlements?";

      await AIChat.create({
        userId,
        role: "user",
        message: cleanMessage,
      });

      await AIChat.create({
        userId,
        role: "assistant",
        message: greetingReply,
      });

      return res.json({
        reply: greetingReply,
      });
    }

    // --------------------------------------------------
    // BLOCK UNRELATED QUESTIONS BEFORE GEMINI
    // --------------------------------------------------

    if (!isMoneyRelated) {
      const restrictedReply =
          "I'm Money AI, your Split Money assistant. 😊 I can help with your expenses, groups, balances, settlements, spending and other money-related questions.";

      // We don't save unrelated questions because they are
      // outside the purpose of Money AI.
      return res.json({
        reply: restrictedReply,
      });
    }

    // --------------------------------------------------
    // GET USER'S GROUPS
    // --------------------------------------------------

    const groups = await Group.find({
      members: userId,
    });

    const groupData = [];

    for (const group of groups) {
      const expenses = await Expense.find({
        groupId: group._id,
      });

      const balances =
        balanceController.calculateBalances(expenses);

      const transactions =
        balanceController.splitMoney(balances);

      groupData.push({
        groupName: group.name,
        groupType: group.groupType,

        expenses: expenses.map((expense) => ({
          description: expense.description,
          amount: expense.amount,
          paidBy: expense.paidBy,
          splitBetween: expense.splitBetween,
          isSettlement: expense.isSettlement,
          createdAt: expense.createdAt,
        })),

        balances,

        suggestedSettlements: transactions,
      });
    }

    // --------------------------------------------------
    // SAVE USER MESSAGE
    // --------------------------------------------------

    await AIChat.create({
      userId,
      role: "user",
      message: cleanMessage,
    });

    // --------------------------------------------------
    // GET PREVIOUS AI CONVERSATION
    // --------------------------------------------------

    const previousChats = await AIChat.find({
      userId,
    })
      .sort({ createdAt: -1 })
      .limit(20);

    // Reverse so oldest message comes first
    previousChats.reverse();

    const conversationHistory = previousChats
      .map((chat) => {
        return `${chat.role}: ${chat.message}`;
      })
      .join("\n");

    // --------------------------------------------------
    // GEMINI CONTEXT
    // --------------------------------------------------

    const context = `
You are Money AI, the intelligent financial assistant
inside the Split Money app.

Your purpose is ONLY to help the user with:
- Shared expenses
- Group expenses
- Spending
- Balances
- Money owed
- Debts
- Settlements
- Payments
- Splitting bills
- Friends and roommates
- Financial information inside the Split Money app
- Questions about using the Split Money app

Do NOT answer general knowledge questions that are
unrelated to Split Money or personal/shared finances.

Do NOT answer questions about:
- Cooking
- Recipes
- General programming
- General education
- Entertainment
- Sports
- Travel unrelated to expenses
- General science
- General trivia
- Any other unrelated topic

If a question is unrelated to Money AI's purpose,
politely tell the user that you can only help with
Split Money and money-related questions.

Do not invent financial information.

Only use the user's actual financial data provided below.

USER'S GROUP DATA:
${JSON.stringify(groupData, null, 2)}

PREVIOUS MONEY AI CONVERSATION:
${conversationHistory}

CURRENT USER MESSAGE:
${cleanMessage}

Answer the current user message naturally,
concisely and clearly.

If the user asks about their expenses, balances,
groups, spending or settlements, use the provided
financial data.
`;

    // --------------------------------------------------
    // CALL GEMINI
    // --------------------------------------------------

    const response = await ai.models.generateContent({
      model: "gemini-3.6-flash",
      contents: context,
    });

    const reply = response.text;

    // --------------------------------------------------
    // SAVE AI RESPONSE
    // --------------------------------------------------

    await AIChat.create({
      userId,
      role: "assistant",
      message: reply,
    });

    res.json({
      reply,
    });
  } catch (error) {
    console.error("AI ERROR:", error);

    res.status(500).json({
      message: "AI request failed",
      error: error.message,
    });
  }
};

// --------------------------------------------------
// GET MONEY AI HISTORY
// --------------------------------------------------

exports.getChatHistory = async (req, res) => {
  try {
    const { userId } = req.params;

    if (!userId) {
      return res.status(400).json({
        message: "User ID is required",
      });
    }

    const chats = await AIChat.find({
      userId,
    }).sort({ createdAt: 1 });

    res.json({
      chats,
    });
  } catch (error) {
    console.error("AI HISTORY ERROR:", error);

    res.status(500).json({
      message: "Failed to load AI history",
      error: error.message,
    });
  }
};