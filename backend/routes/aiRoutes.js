const express = require("express");

const router = express.Router();

const {
  chatWithAI,
  getChatHistory,
} = require("../controllers/aiController");

router.post("/chat", chatWithAI);

router.get("/history/:userId", getChatHistory);

module.exports = router;