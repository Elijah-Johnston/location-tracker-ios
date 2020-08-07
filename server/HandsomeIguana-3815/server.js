// @ts-check
var util = require('./util');
const express = require('express');
const http = require('http');
const url = require('url');
var cookieParser = require('cookie-parser');
const request = require('request');
const bodyParser = require("body-parser")
const db = require("./db");

async function main() {
  // Azure App Service will set process.env.port for you, but we use 3000 in development.
  const PORT = process.env.PORT || 3000;
  // Create the express routes
  let app = express();
  app.use(express.static('public'));
  app.use(cookieParser());
  app.use(
    bodyParser.urlencoded({
      extended: true
    })
  );
  app.use(bodyParser.json());

  app.get('/', async (req, res) => {
    if (req.query && req.query.loginsession) {
      res.cookie('loginsession', req.query.loginsession, { maxAge: 3600000, httpOnly: true, })
      res.redirect(url.parse(req.url).pathname);
    }
    else {
      let indexContent = await util.loadEnvironmentVariables({ host: process.env['HTTP_HOST'] });
      res.end(indexContent);
    }
  });

  app.get('/trial', async (req, res) => {
    if (req.query && req.query.loginsession) {
      res.cookie('loginsession', req.query.loginsession, { maxAge: 3600000, httpOnly: true, })
      res.redirect(url.parse(req.url).pathname);
    }
    else {
      let indexContent = await util.loadEnvironmentVariablesTrial({ host: process.env['HTTP_HOST'] });
      res.end(indexContent);
    }
  });

  app.get('/api/metadata', async (req, res) => {
    if (req.cookies.loginsession) {
      let tryappserviceendpoint = (process.env['APPSETTING_TRYAPPSERVICE_URL'] || 'https://tryappservice.azure.com') + '/api/vscoderesource';
      const options = {
        url: tryappserviceendpoint,
        headers: {
          cookie: 'loginsession=' + req.cookies.loginsession
        }
      };

      const x = request(options);
      x.pipe(res);
    }
    else {
      res.end(404);
    }
  });


  const PathModel = require("./database/path/model");
  app.post('/api/path', async (req, res) => { 
    console.log(req.body)
    let path = new PathModel(req.body);
    path.save()
    .then((path) => {
      res.send({message: "Path saved."})
    })
    .catch((err) => {
      console.log(err)
      res.send({error: err})
    })
  });

  new db()
    .connect()
    .then(_ => console.log("Successfully connected to DB.\n", __filename))
    .catch(err => console.log("Couldn't connect to DB.\n", __filename));
  // Create the HTTP server.
  let server = http.createServer(app);
  server.listen(PORT, function () {
    console.log(`Listening on port ${PORT}`);
  });
}

main();
