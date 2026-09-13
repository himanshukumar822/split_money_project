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

    // Get user's groups
    const groups = await Group.find({
      members: userId,
    });

    const groupData = [];

    for (const group of groups) {
      const expenses = await Expense.find({
        groupId: group._id,
      });

      const balances =
          balanceController.calculateBalances(
            expenses
          );

      const transactions =
          balanceController.splitMoney(
            balances
          );

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

    // Save user's message
    await AIChat.create({
      userId,
      role: "user",
      message: message.trim(),
    });

    // Get previous AI conversation
    const previousChats = await AIChat.find({
      userId,
    })
      .sort({ createdAt: -1 })
      .limit(20);

    // Reverse so oldest message comes first
    previousChats.reverse();

    const conversationHistory =
      previousChats
        .map((chat) => {
          return `${chat.role}: ${chat.message}`;
        })
        .join("\n");

    const context = `
You are Money AI, the intelligent financial assistant
inside the Split Money app.

You help the user understand their shared expenses,
balances, settlements, groups and spending.

Be helpful, concise and clear.

Do not invent financial information.
Only use the user's actual financial data provided below.

USER'S GROUP DATA:
${JSON.stringify(groupData, null, 2)}

PREVIOUS MONEY AI CONVERSATION:
${conversationHistory}

CURRENT USER MESSAGE:
${message}

Answer the current user message naturally.
If the user asks about their expenses or balances,
use the provided financial data.
`;

    const response = await ai.models.generateContent({
      model: "gemini-3.6-flash",
      contents: context,
    });

    const reply = response.text;

    // Save AI response
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