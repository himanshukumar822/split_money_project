const mongoose = require("mongoose");

const activitySchema = new mongoose.Schema({
  user: String,        // who did action
  type: String,        // "GROUP_CREATED", "EXPENSE_ADDED"
  message: String,     // readable text
  groupId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Group"
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model("Activity", activitySchema);