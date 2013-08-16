(function() {
  var M1_PASSWORD, M1_SERVER, M1_USER, PUSH_FREQUENCY, SERVER_NAME, SERVER_PASSWORD, SERVER_PORT, SERVER_URL, SERVER_USER, async, create_heartbeat_attachment, create_notice_attachment, create_report, create_system_resources_attachment, express, generate_attachments, moment, os, pull_report, push_report, request, _;

  request = require("request");

  _ = require('underscore');

  moment = require("moment");

  os = require('os');

  async = require('async');

  express = require('express');

  M1_SERVER = process.env.M1_SERVER || '127.0.0.1:3000';

  M1_USER = process.env.M1_USER || "";

  M1_PASSWORD = process.env.M1_PASS || "";

  PUSH_FREQUENCY = process.env.PUSH_FREQUENCY || 60000;

  SERVER_NAME = process.env.SERVER_NAME || 'nullserver';

  SERVER_URL = process.env.SERVER_URL || 'http://localhost';

  SERVER_PORT = process.env.SERVER_PORT || process.env.PORT || 5000;

  SERVER_PASSWORD = process.env.SERVER_PASSWORD;

  SERVER_USER = process.env.SERVER_USER;

  console.log("PUSH " + M1_USER + "@" + M1_SERVER + " FOR " + SERVER_NAME + " FREQ " + PUSH_FREQUENCY);

  console.log("PULL " + SERVER_USER + "@" + SERVER_URL + ":" + SERVER_PORT + " CALLED " + SERVER_NAME);

  create_heartbeat_attachment = function() {
    return {
      type: 'Heartbeat',
      level: 1,
      alive_at: moment().format(),
      next_beat: moment().add('milliseconds', PUSH_FREQUENCY).format()
    };
  };

  create_notice_attachment = function(message) {
    console.log(message);
    return {
      type: 'Notice',
      level: 0,
      message: message
    };
  };

  create_system_resources_attachment = function() {
    var cpuload;
    cpuload = os.loadavg();
    return {
      type: 'SystemResource',
      level: 1,
      memory: {
        freemem: os.freemem(),
        totalmem: os.totalmem()
      },
      cpu: {
        one_minute: cpuload[0],
        five_minutes: cpuload[1],
        fifteen_minutes: cpuload[2]
      }
    };
  };

  generate_attachments = function(cb) {
    return async.parallel([
      function(callback) {
        return callback(null, create_heartbeat_attachment());
      }, function(callback) {
        return callback(null, create_system_resources_attachment());
      }
    ], cb);
  };

  create_report = function(attachments, date) {
    var attachment, report, _i, _len;
    if (date == null) {
      date = moment().format();
    }
    if (!_.isArray(attachments)) {
      attachments = [attachments];
    }
    for (_i = 0, _len = attachments.length; _i < _len; _i++) {
      attachment = attachments[_i];
      _.defaults(attachment, {
        level: 1,
        generated_at: date
      });
    }
    report = {
      sent_at: date,
      attachments: attachments
    };
    return {
      report: report,
      server: {
        name: SERVER_NAME,
        url: "" + SERVER_URL + ":" + SERVER_PORT
      }
    };
  };

  push_report = function(report) {
    var options;
    console.log("pushing report:", report);
    options = {
      url: "" + M1_SERVER + "/servers/" + SERVER_NAME + "/reports.json",
      auth: {
        user: M1_USER,
        pass: M1_PASSWORD
      },
      method: 'POST',
      json: report
    };
    return request(options, function(e, r, b) {
      return console.log([e, b]);
    });
  };

  pull_report = express();

  pull_report.use(express.basicAuth(SERVER_USER, SERVER_PASSWORD));

  pull_report.get('/', function(req, res) {
    return generate_attachments(function(error, attachments) {
      return res.json(create_report(attachments));
    });
  });

  pull_report.listen(SERVER_PORT);

  push_report(create_report(create_notice_attachment('Starting the Heartbeat')));

  setInterval(function() {
    console.log('boom boom');
    return generate_attachments(function(error, attachments) {
      return push_report(create_report(attachments));
    });
  }, PUSH_FREQUENCY);

}).call(this);
