require("dotenv").config();
const express = require("express");
const connectDB = require("./config/db");
const groupRoutes = require("./routes/groupRoutes");
const authRoutes = require("./routes/authRoutes");
const expenseRoutes = require("./routes/expenseRoutes");
const balanceRoutes = require("./routes/balanceRoutes");
const app = express();

connectDB();


app.use(express.json());
app.use("/api/groups", groupRoutes);
app.use("/api/auth", authRoutes);
app.use("/api/expenses", expenseRoutes);
app.use("/api/balances", balanceRoutes);
app.get("/", (req, res) => {
  res.send("Split Money API Running");
});
app.use("/api/activity", require("./routes/activityRoutes"));

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});



