################################################
#                    Grahams Node
#             This file is the initial router
# src    <-- All src files
# dist   <-- f(src), all calculated files
# vendor <-- all supplied files (calculated on different grunt task as the change less often)
# 
# src/assets <-- all public files (still usable on server)
# 
#
################################################

express = require("express")
request = require("request")
_ = require('underscore')
moment = require("moment")

app = express()
app.use(express.logger())

create_heartbeat = -> #TODO
send_report = (attachments, date = moment().format() ) ->
  attachments = [attachments] if not _.isArray(attachments)
  
  for attachment in attachments
    _.defaults(attachment, {level: 1, generated_at: date})

  report = { 
    sent_at: date
    attachments: attachments
  }

  options = 
    {
      url: process.env.M1_SERVER
      auth: { user: process.env.M1_USER, pass: process.env.M1_PASS }
      method: 'POST'
      json: report: report
    }

  request(options, (e,r,b) -> console.log [e,b])


#init report
d = moment().format()

console.log "Init the heartbeat"
#send_report({type: 'Notice', level: 0, value: {}})

#emergency report
#If a report is immediatly required, then there should be a callback given to all the middleware to be able to send one
#for service in services
#  service.emergency_report_callback((a) -> send_report(a,Date.now))

#main loop
id = setInterval(
  ->
    attachments = []
    #This should detect the other services and then check if they have an attachement for the report

    #detect services
    #for service in services
    #  attachments.push serivce.attachments if service.has_attachment?

    console.log('boom boom')
    d = moment().format()
    hb_attachment = {type: 'Heartbeat', level: 1, value: {alive_at: d}}
    attachments.push hb_attachment
    send_report(attachments , d)
  , 20000
)

console.log('here 2 ' + id)

