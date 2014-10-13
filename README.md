#FLASK BANG
===========

The holy web hand grenade.

__Requires:__ A Debian-based filesystem, Nginx


FLASK-BANG, which is pronounced by yelling, is an easy way to deploy a production flask server.  It utilizes uWSGI and its own python environment _for safety_


####Making the flask skeleton:
`python flask-bang.py` will create a skeleton for your app __in your current working directory__.  Inside your module, `views.py` takes care of your routing.  Make sure to update setup.py for any extra pypi modules you use.

####Starting the Server:
`start_server.sh` will link your .conf file to nginx's sites-enabled; it will restart the nginx proxy; and it will start your uWSGI server.

####Logging:
Try `start_server.sh > log.txt 2>&1 &`.  That will log the output of your uWSGI server in log.txt.

####Moving the Skeleton:
If you moved your site's directory and your having trouble starting the server, the `imts.py` tool should put you back on the right path.
