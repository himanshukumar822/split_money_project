const User = require("../models/user");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
`   `
exports.signup = async (req, res) => {
  try {
      
    const { name, email, password } = req.body;

        const existingUser = await User.findOne({ email });
      
    if (existingUser) {
      return res.status(400).json({
        message: "User already exists"
      });
    }
const hashedPassword = await bcrypt.hash(password, 10);
    const user = new User({
      name,
      email,
      password:hashedPassword
    });

    await user.save();

    res.status(201).json({
      message: "User created successfully",
        user: {
    _id: user._id,
    name: user.name,
    email: user.email
  }
    });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.login = async (req, res) => {
  try {

    const { email, password } = req.body;

    // find user
    const user = await User.findOne({ email });

    if (!user) {
      return res.status(400).json({
        message: "Invalid email or password"
      });
    }

    // compare password
    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return res.status(400).json({
        message: "Invalid email or password"
      });
    }

    // create JWT token
    const token = jwt.sign(
      { id: user._id },
      process.env.JWT_SECRET,
      { expiresIn: "1d" }
    );

    res.json({
      message: "Login successful",
      token,
        user: {
    _id: user._id,
    name: user.name,
    email: user.email
  }
    });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};