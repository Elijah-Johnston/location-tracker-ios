// Core modules
// NPM module
const mongoose = require("mongoose");
const Schema = mongoose.Schema;

// Design the schema.
let PathSchema = new Schema(
    {
        name: {
            type: String,
            required: true
        },
        route: {
            type: [[Number]],
            validate: v => Array.isArray(v) && v.length > 0,
        },
        waypoints: {
            type: [[Number]]
        }
    }, 
    {
        collection: "path"
    }
);

module.exports = PathSchema;