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
    paidBy:{
        type:mongoose.Schema.Types.ObjectId,
        ref:"User",
        required:true
    },
    splitBetween:[{
        type:mongoose.Schema.Types.ObjectId,
        ref:"User"
    }]


    
},{timestamps:true});
module.exports=mongoose.model("Expense",expenseSchema);