// Core modules
// NPM modules
const mongoose = require('mongoose');
// Custom modules


class Mongo {
    constructor() {
        // if (!process.env["MONGO_URL"]) {
        //     console.log("Invalid connection uri:", __filename);
        // }

        this.connectionStr = "mongodb://mapping-cosmos:grQxkIQIG9sHxCxEqHcK9XpLuRnLxmb3lPLrr0q5AdJj3dFJugxV3gkV2Jy0n8WwOYDs3dzYhSCA5o5B1QD4Jg%3D%3D@mapping-cosmos.documents.azure.com:10255/coordinates?ssl=true&replicaSet=globaldb&retrywrites=false";
    }

    connect() {
        return new Promise((resolve, reject) => {
            mongoose.connect(this.connectionStr, { useUnifiedTopology: true, useNewUrlParser: true, useCreateIndex: true })
                .then(result => resolve(result))
                .catch(err => reject(err))
        });
    }
}


module.exports = Mongo;