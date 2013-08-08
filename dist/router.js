(function() {
  var FREQUENCY, PASSWORD, SERVER, USER, async, create_heartbeat_attachment, create_notice_attachment, create_system_resources_attachment, moment, os, request, send_report, _;

  request = require("request");

  _ = require('underscore');

  moment = require("moment");

  os = require('os');

  async = require('async');

  SERVER = process.env.M1_SERVER || '127.0.0.1:3000';

  USER = process.env.M1_USER || "";

  PASSWORD = process.env.M1_PASS || "";

  FREQUENCY = process.env.FREQUENCY || 60000;

  console.log("" + USER + "@" + SERVER + " FREQ " + FREQUENCY);

  create_heartbeat_attachment = function() {
    return {
      type: 'Heartbeat',
      level: 1,
      value: {
        alive_at: moment().format()
      }
    };
  };

  create_notice_attachment = function(message) {
    console.log(message);
    return {
      type: 'Notice',
      level: 0,
      value: {
        message: message
      }
    };
  };

  create_system_resources_attachment = function() {
    var cpuload;
    cpuload = os.loadavg();
    return {
      type: 'SystemResource',
      level: 1,
      value: {
        memory: {
          freemem: os.freemem(),
          totalmem: os.totalmem()
        },
        cpu: {
          one_minute: cpuload[0],
          five_minutes: cpuload[1],
          fifteen_minutes: cpuload[2]
        }
      }
    };
  };

  send_report = function(attachments, date) {
    var attachment, options, report, _i, _len;
    if (date == null) {
      date = moment().format();
    }
    console.log(attachments);
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
    console.log("sending report: " + report);
    options = {
      url: SERVER,
      auth: {
        user: USER,
        pass: PASSWORD
      },
      method: 'POST',
      json: {
        report: report
      }
    };
    return request(options, function(e, r, b) {
      return console.log([e, b]);
    });
  };

  send_report(create_notice_attachment('Starting the Heartbeat'));

  setInterval(function() {
    console.log('boom boom');
    return async.parallel([
      function(callback) {
        return callback(null, create_heartbeat_attachment());
      }, function(callback) {
        return callback(null, create_system_resources_attachment());
      }
    ], function(error, attachments) {
      return send_report(attachments);
    });
  }, FREQUENCY);

}).call(this);
