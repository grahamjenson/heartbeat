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
express = require('express')

############# END OF IMPORTS ##########################


######### CONFIG ####################

#PUSH CONFIGS
M1_SERVER = process.env.M1_SERVER || '127.0.0.1:3000'
M1_USER = process.env.M1_USER || ""
M1_PASSWORD = process.env.M1_PASS || ""

#PULL CONFIGS
SERVER_NAME = process.env.SERVER_NAME || 'nullserver'
SERVER_URL = process.env.SERVER_URL || 'http://localhost'
SERVER_PORT = process.env.SERVER_PORT || process.env.PORT || 5000
SERVER_PASSWORD = process.env.SERVER_PASSWORD
SERVER_USER = process.env.SERVER_USER

console.log("PUSH #{M1_USER}@#{M1_SERVER} FOR #{SERVER_NAME}")
console.log("PULL #{SERVER_USER}@#{SERVER_URL}:#{SERVER_PORT} CALLED #{SERVER_NAME}")
######### END OF CONFIG ############


######### CREATE ATTACHMENT FUNCTIONS ########

create_heartbeat_attachment = -> {type: 'Heartbeat', level: 1, alive_at: moment().format()}

create_notice_attachment = (message) ->  
  console.log(message)
  {type: 'Notice', level: 0, message: message}

create_system_resources_attachment = ->
  cpuload = os.loadavg()
  {
    type: 'SystemResource', 
    level: 1, 
    memory: 
      freemem: os.freemem(), 
      totalmem: os.totalmem()
    cpu: 
      one_minute: cpuload[0]
      five_minutes: cpuload[1]
      fifteen_minutes: cpuload[2]
  }

#ensure the website is up by doing a get on localhost and ensuring 200

####### END OF ATTACHMENT FUNCTION METHODS ######


####### MAIN REPORT FUNCTIONS ########

generate_attachments = (cb) ->
  #This should detect the other services and then check if they have an attachement for the report

  #detect services
  #for service in services
  #  attachments.push serivce.attachments if service.has_attachment?
  #Asynchonously get attachments, then send report
  async.parallel([
    (callback) -> callback(null, create_heartbeat_attachment())
    (callback) -> callback(null, create_system_resources_attachment())
  ],
  cb
  )

create_report = (attachments, date = moment().format() ) ->

  attachments = [attachments] if not _.isArray(attachments)
  
  for attachment in attachments
    _.defaults(attachment, {level: 1, generated_at: date})

  report = { 
    sent_at: date
    attachments: attachments
  }
  return {
    report: report
    server:
      name: SERVER_NAME
      url: "#{SERVER_URL}:#{SERVER_PORT}"
  }

push_report = (report) ->
  console.log "pushing report:", report
  options = 
    {
      url: "#{M1_SERVER}/servers/#{SERVER_NAME}/reports.json"
      auth: { user: M1_USER, pass: M1_PASSWORD }
      method: 'POST'
      json: report
    }
  request(options, (e,r,b) -> console.log [e,b])


pull_report = express()
pull_report.use(express.basicAuth(SERVER_USER, SERVER_PASSWORD))
pull_report.get('/', (req, res) ->
  generate_attachments((error, attachments) ->
      res.json(create_report(attachments))
  )
)

pull_report.listen(SERVER_PORT)

####### END OF MAIN REPORT FUNCTIONS ##########

####INIT THE SERVER
push_report(create_report(create_notice_attachment('Starting the Heartbeat')))

#####END INIT THE SERVER

#emergency report
#If a report is immediatly required, then there should be a callback given to all the middleware to be able to send one
#for service in services
#  service.emergency_report_callback((a) -> push_report(a,Date.now))

