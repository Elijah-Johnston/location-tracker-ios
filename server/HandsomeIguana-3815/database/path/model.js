const mongoose = require("mongoose");
const PathSchema = require("./schema");

// Build the model from the schema.
const PathModel = mongoose.model("path", PathSchema);

module.exports = PathModel;