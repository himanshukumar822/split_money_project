const Group = require("../models/Group");

exports.createGroup = async (req, res) => {
  try {

    const { name, members, createdBy } = req.body;

    const group = new Group({
      name,
      members,
      createdBy
    });

    await group.save();

    res.status(201).json({
      message: "Group created successfully",
      group
    });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getUserGroups = async (req, res) => {
  try {

    const { userId } = req.params;

    const groups = await Group.find({
      members: userId
    });

    res.json({
      groups
    });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.addMember = async (req, res) => {
  try {

    const { groupId } = req.params;
    const { userId } = req.body;

    const group = await Group.findById(groupId);

    if (!group) {
      return res.status(404).json({
        message: "Group not found"
      });
    }

    // avoid duplicate members
    if (group.members.includes(userId)) {
      return res.status(400).json({
        message: "User already in group"
      });
    }

    group.members.push(userId);

    await group.save();

    res.json({
      message: "Member added successfully",
      group
    });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};