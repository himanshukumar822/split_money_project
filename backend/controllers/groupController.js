const Group = require("../models/Group");

const Activity = require("../models/activity");

const User = require("../models/User");

exports.getGroupById = async (req, res) => {
  try {
    const { groupId } = req.params;

    const group = await Group.findById(groupId)
      .populate("expenses")
      .populate("members", "name email");

    if (!group) {
      return res.status(404).json({
        message: "Group not found",
      });
    }

    res.json(group);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.createGroup = async (req, res) => {
  try {
    const {
      name,
      members,
      createdBy,
      groupType,
    } = req.body;

    const group = new Group({
      name,
      members,
      createdBy,
      groupType: groupType || "Home",
    });

    await group.save();

    // Get creator's name
    const creator = await User.findById(createdBy);

    await Activity.create({
      owner: createdBy,
      type: "GROUP_CREATED",
      message: `Group "${name}" created`,
      groupId: group._id,
    });

    res.status(201).json({
      message: "Group created successfully",
      group,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getUserGroups = async (req, res) => {
  try {
    const { userId } = req.params;

    const groups = await Group.find({
      members: userId,
      isArchived: { $ne: true },
    })
      .populate("expenses")
      .populate("members", "name email");

    res.json({
      groups,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Move group to Backup
exports.archiveGroup = async (req, res) => {
  try {
    const { groupId } = req.params;

    const group = await Group.findById(groupId);

    if (!group) {
      return res.status(404).json({
        message: "Group not found",
      });
    }

    group.isArchived = true;
    group.archivedAt = new Date();

    await group.save();

    res.json({
      message: "Group moved to Backup successfully",
      group,
    });
  } catch (error) {
    res.status(500).json({
      error: error.message,
    });
  }
};

// Get archived groups
exports.getArchivedGroups = async (req, res) => {
  try {
    const { userId } = req.params;

    const groups = await Group.find({
      members: userId,
      isArchived:  true ,
    })
      .populate("expenses")
      .populate("members", "name email")
      .sort({ archivedAt: -1 });

    res.json({
      groups,
    });
  } catch (error) {
    res.status(500).json({
      error: error.message,
    });
  }
};

// Restore group from Backup
exports.restoreGroup = async (req, res) => {
  try {
    const { groupId } = req.params;

    const group = await Group.findById(groupId);

    if (!group) {
      return res.status(404).json({
        message: "Group not found",
      });
    }

    group.isArchived = false;
    group.archivedAt = null;

    await group.save();

    res.json({
      message: "Group restored successfully",
      group,
    });
  } catch (error) {
    res.status(500).json({
      error: error.message,
    });
  }
};

exports.addMember = async (req, res) => {
  try {
    const { groupId } = req.params;
    const { userId } = req.body;

    const group = await Group.findById(groupId);

    if (!group) {
      return res.status(404).json({
        message: "Group not found",
      });
    }

    if (group.members.includes(userId)) {
      return res.status(400).json({
        message: "User already in group",
      });
    }

    group.members.push(userId);

    await group.save();

    res.json({
      message: "Member added successfully",
      group,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};