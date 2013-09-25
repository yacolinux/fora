fora is licensed under the GPL3 license.
You can find it here: http://gplv3.fsf.org/


Installation
============

Step 1: Install pre-requisites
------------------------------
Run ./install-dependencies.sh
WARNING: The install script upgrades node to a very new version.

```
usage: ./install-dependencies.sh options
options:
  --all               Same as --node --coffee --nginx --nginx_conf --host local.foraproject.org --mongodb --gm --node_modules
  --node              Compile and install node
  --coffee            Compile and install coffee-script, with support for the yield keyword
  --nginx             Install nginx
  --nginx_conf        Copies a sample nginx config file to /etc/nginx/sites-available, and creates a symlink in sites-enabled
  --host hostname     Adds an entry into /etc/hosts. eg: --host test.myforaproj.com
  --mongodb           Install MongoDb
  --gm                Install Graphics Magick
  --node_modules      Install Node Modules
  --help              Print the help screen
Examples:
  ./install-dependencies.sh --all
  ./install-dependencies.sh --node --coffee --gm --node_modules
```

Otherwise, do these manually:
- install nodejs, v0.11.5 or greater
- install nginx (apt-get)
- install a modified version of coffeescript to support the yield keyword, from https://github.com/jeswin/coffee-script
- install mongodb (apt-get)
- setup nginx configuration, see fora.nginx.config for a sample
- install graphicsmagick (apt-get)
- install these modules with npm:
    sudo npm install -g less    
    
    cd server
    npm install express
    npm install mongodb
    npm install validator
    npm install sanitizer
    npm install hbs
    npm install fs-extra
    npm install gm
    npm install node-minify
    npm install oauth
    npm install forever
    npm install marked
    npm install optimist
    npm install forever


Step 2: Configuration
---------------------
- Copy src/conf/settings.config.sample to settings.config and edit it.
- Copy src/conf/fora.config.sample to fora.config and edit it.
- In ~/.bashrc export NODE_ENV as 'development' or 'production'. eg: export NODE_ENV=production


Running Fora
------------
To debug
```
cd server
./run.sh --debug
```

For production
```
cd server
./run.sh
```

Go to http://hostname in browser.  
Note: If you used --all, hostname will be local.foraproject.org

