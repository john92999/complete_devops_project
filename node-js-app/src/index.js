const express = require("express");
const mongoose = require("mongoose");

const app = express();
app.use(express.json());

mongoose
  .connect(process.env.MONGO_URI)
  .then(() => console.log("MongoDB connected"))
  .catch((err) => console.error(err));

const Todo = mongoose.model("Todo", { text: String, done: Boolean });

app.get("/todos", async (req, res) => res.json(await Todo.find()));
app.post("/todos", async (req, res) => {
  const todo = new Todo({ text: req.body.text, done: false });
  await todo.save();
  res.json(todo);
});

app.listen(3000, () => console.log("Server on port 3000"));
