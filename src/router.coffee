################################################
#                    Grahams Node
#             This file is the initial router
# src    <-- All src files
# dist   <-- f(src), all calculated files
# vendor <-- all supplied files (calculated on different grunt task as the change less often)
# 
# 
#
################################################

############# IMPORTS ##########################
request = require("request")
_ = require('underscore')
moment = require("moment")
os = require('os')
async = require('async')

############# END OF IMPORTS ##########################


######### CONFIG ####################

SERVER = process.env.M1_SERVER || '127.0.0.1:3000'
USER = process.env.M1_USER || ""
PASSWORD = process.env.M1_PASS || ""
FREQUENCY = process.env.FREQUENCY || 60000

console.log("#{USER}@#{SERVER} FREQ #{FREQUENCY}")
######### END OF CONFIG ############



######### CREATE ATTACHMENT FUNCTIONS ########

create_heartbeat_attachment = -> {type: 'Heartbeat', level: 1, value: {alive_at: moment().format()}}

create_notice_attachment = (message) ->  
  console.log(message)
  {type: 'Notice', level: 0, value: {message: message}}

create_system_resources_attachment = ->
  cpuload = os.loadavg()
  {
    type: 'SystemResource', 
    level: 1, 
    value: {
      memory: {
        freemem: os.freemem(), 
        totalmem: os.totalmem()
      }
      cpu: {
        one_minute: cpuload[0]
        five_minutes: cpuload[1]
        fifteen_minutes: cpuload[2]
      }
    }
  }

#ensure the website is up by doing a get on localhost and ensuring 200

####### END OF ATTACHMENT FUNCTION METHODS ######




####### MAIN REPORT FUNCTIONS ########
send_report = (attachments, date = moment().format() ) ->
  console.log(attachments)
  attachments = [attachments] if not _.isArray(attachments)
  
  for attachment in attachments
    _.defaults(attachment, {level: 1, generated_at: date})

  report = { 
    sent_at: date
    attachments: attachments
  }
  console.log("sending report: #{report}")
  options = 
    {
      url: SERVER
      auth: { user: USER, pass: PASSWORD }
      method: 'POST'
      json: report: report
    }

  request(options, (e,r,b) -> console.log [e,b])


####### END OF MAIN REPORT FUNCTIONS ##########



send_report(create_notice_attachment('Starting the Heartbeat'))

#emergency report
#If a report is immediatly required, then there should be a callback given to all the middleware to be able to send one
#for service in services
#  service.emergency_report_callback((a) -> send_report(a,Date.now))

#main loop
setInterval(
  ->
    #This should detect the other services and then check if they have an attachement for the report

    #detect services
    #for service in services
    #  attachments.push serivce.attachments if service.has_attachment?

    console.log('boom boom')
    #Asynchonously get attachments, then send report
    async.parallel([
      (callback) -> callback(null, create_heartbeat_attachment())
      (callback) -> callback(null, create_system_resources_attachment())
    ],
    (error, attachments) ->
      send_report(attachments)
    )

  , FREQUENCY
)


