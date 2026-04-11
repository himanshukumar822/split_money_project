const Activity = require("../models/activity");

exports.getActivities = async (req, res) => {
  try {

    const activities = await Activity
      .find({ userId: req.user.id })
      .sort({ createdAt: -1 });

    res.json({ activities });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};