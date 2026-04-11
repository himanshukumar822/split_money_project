const mongoose = require("mongoose");

const activitySchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true
  },
  type: String,
  message: String,
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