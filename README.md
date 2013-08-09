#Heartbeat
Heartbeat is an daemon that monitors the health of a server and sends data in reports, which can have many attachemtns.
It has been primarily developed to be intergrated with the Many1 application.

Currently this application has the ability to send
1. Alive updates
2. System Resource Use (memory & cpu)

Later it is planned to have 
1. Database resources (time to exwecute per query)
2. Rails app resources (time to respond, time to render...)
3. Error (Airbrake-esq error reporting) 

##Future Development
Inversion of Control, where plugins that provide attachments register their services.
This way a heartbeat daemon can be set up with externally customizable plugins, e.g. attach a postgres monitor without having to cheage heartbeat code.


#Documentation
##Developing Heartbeat

```brew install node```

```npm install```

```foreman start -f Procfile.dev```


##Deploying Heartbeat

###Setting up node

taken from [here](http://howtonode.org/how-to-install-nodejs)

```
sudo apt-get install g++ curl libssl-dev apache2-utils

git clone git://github.com/ry/node.git
cd node
./configure
make
sudo make instal

```

###Setting up hearbeat

Taken form [here](http://howtonode.org/deploying-node-upstart-monit)

```
git clone git@github.com:grahamjenson/heartbeat.git
```


####Environment Variables

M1_SERVER= The many1 server to contact with server url i.e. http://many1.herokuapp.com/servers/1
M1_USER= Http auth Password for the many1 server, this will eventually be refactored as an API key 
M1_PASS= HTTP auth password for many1 server
FREQUENCY= Frequency to heartbeat in milliseconds, e.g. 60000 is a minute

e.g.
```
export M1_SERVER=http://many1.herokuapp.com/servers/1/report.json
export M1_USER=bob
export M1_PASS=blabla
export FREQUENCY=60000
```


Test with

```
node dist/router.js
```

###Upstart
Upstart conf (upstart should be installed)

Have to replace:

1. VAR_M1_SERVER (described above)
2. VAR_M1_USER (described above)
3. VAR_M1_PASS (described above)
4. VAR_FREQUENCY (described above)
5. USER_TO_RUN_AS the user the node process is run as 
6. LOCATION_OF_HEARTBEAT 

with correct variables then put in /etc/init/heartbeat.conf, e.g.


```
cat config/heartbeat.conf  |
  sed 's/VAR_M1_SERVER/http:\/\/many1.herokuapp.com\/servers\/1\/report.json/g' |
  sed 's/VAR_M1_USER/user/g' |
  sed 's/VAR_M1_PASS/pass/g' |
  sed 's/VAR_FREQUENCY/120000/g' |
  sed 's/USER_TO_RUN_AS/user/g' | 
  sed 's/LOCATION_OF_HEARTBEAT/\/home\/user\/apps\/heartbeat/g' | sudo tee /etc/init/heartbeat.conf
```

Test with:

```
sudo start heartbeat
sudo tail -f /var/log/heartbeat.sys.log
#wait see what happens
sudo stop heartbeat
```

Monit setup

```
sudo cp config/heartbeat.monit /etc/monit/conf.d/
sudo monit reload
```


Test with:

```
ps -Af | grep heartbeat
killall hearbeat #maybe
```