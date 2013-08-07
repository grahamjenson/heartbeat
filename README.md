This is a spike into using node.js, grunt.js as a development platform for creating visualisations.

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
export M1_SERVER=http://many1.herokuapp.com/servers/1
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
sudo cat config/heartbeat.conf  |
  sed 's/VAR_M1_SERVER/http:\/\/many1.herokuapp.com\/servers\/1/g' |
  sed 's/VAR_M1_USER/user/g' |
  sed 's/VAR_M1_PASS/pass/g' |
  sed 's/VAR_FREQUENCY/60000/g' |
  sed 's/USER_TO_RUN_AS/user/g' | 
  sed 's/LOCATION_OF_HEARTBEAT/\/home\/deploy\/apps\/hearetbeat/g' > /etc/init/heartbeat.conf
```

Test with:

```
start hearbeat
```

Monit setup

```
sudo cp config/hearbeat.monit /etc/monit/conf.d/
sudo monit restart
```


Test with:

```
ps -Af | grep heartbeat
killall hearbeat #maybe
```