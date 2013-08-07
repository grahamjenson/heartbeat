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

###Upstart
Upstart conf (upstart should be installed)

Have to replace cat USER_TO_RUN_AS and LOCATION_OF_HEARTBEAT with correct variables then put in /etc/init/heartbeat.conf, e.g.

```
sudo cat config/heartbeat.conf | sed 's/USER_TO_RUN_AS/user/g' | sed 's/LOCATION_OF_HEARTBEAT/\/home\/deploy\/apps\/hearetbeat/g' > /etc/init/heartbeat.conf
```


Monit setup

```
sudo cp config/hearbeat.monit /etc/monit/conf.d/
```

