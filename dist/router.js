(function() {
  var app, create_heartbeat, d, express, id, moment, request, send_report, _;

  express = require("express");

  request = require("request");

  _ = require('underscore');

  moment = require("moment");

  app = express();

  app.use(express.logger());

  create_heartbeat = function() {};

  send_report = function(attachments, date) {
    var attachment, options, report, _i, _len;
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
    options = {
      url: process.env.M1_SERVER,
      auth: {
        user: process.env.M1_USER,
        pass: process.env.M1_PASS
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

  d = moment().format();

  console.log("Init the heartbeat");

  id = setInterval(function() {
    var attachments, hb_attachment;
    attachments = [];
    console.log('boom boom');
    d = moment().format();
    hb_attachment = {
      type: 'Heartbeat',
      level: 1,
      value: {
        alive_at: d
      }
    };
    attachments.push(hb_attachment);
    return send_report(attachments, d);
  }, 20000);

  console.log('here 2 ' + id);

}).call(this);
