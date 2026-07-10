const Activity = require("../models/activity");
const Group = require("../models/Group");

exports.getActivities = async (req, res) => {
  try {
    const { owner } = req.query;

    if (!owner) {
      return res.status(400).json({
        message: "Owner id is required",
      });
    }

    // Find all groups created by this logged-in user
    const groups = await Group.find({
      createdBy: owner,
    });

    const groupIds = groups.map((g) => g._id);

    // Get every activity of those groups
    const activities = await Activity.find({
      groupId: { $in: groupIds },
    }).sort({ createdAt: -1 });

    res.json({
      activities,
    });
  } catch (error) {
    console.log(error);
    res.status(500).json({
      error: error.message,
    });
  }
};