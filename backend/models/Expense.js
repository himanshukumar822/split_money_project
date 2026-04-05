const mongoose= require("mongoose");
const expenseSchema=new mongoose.Schema({
    groupId:{
        type:mongoose.Schema.Types.ObjectId,
        ref: "Group",
        required:true
    },
    description:{
        type:String,
        required:true
    },
    amount:{
        type:Number,
        required:true
    },
    paidBy: String,
    splitBetween: [String],
    
    isSettlement: {
     type: Boolean,
      default: false
      }

    
},{timestamps:true});
module.exports=mongoose.model("Expense",expenseSchema);