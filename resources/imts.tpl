#!/usr/bin/env python

import os
from os import path
import subprocess


def fix(vals):
    ##FIX THE ENVIRONMENT:
    
    if path.exists(vals['py_env']):
        print 'environment directory exists. okay.'
        subprocess.call(["rm","-r", vals['py_env']])
    else:
        print 'where is the env directory? thats fucked up.'

    print 'doesnt matter tho, we\'re making another one anyway.'
    os.mkdir(vals['py_env'])
    
    subprocess.call(["virtualenv", vals['py_env']])


    ##ACTIVATE THE ENVIRONMENT

    try:
        activate_this = path.join(vals['py_env'],'bin/activate_this.py')
        size = os.path.getsize(activate_this)
        execfile(activate_this, dict(__file__=activate_this))
    except:
        print 'activiated the venv... it broke... i got nothing'
        exit()


    ##SETUP THE PACKAGE
    
    if vals['setup_IorD'] == 'i':
        print 'okay... this might take a second.'
        subprocess.call(['python', path.join(vals['container_dir'],'setup.py'),'install'])
    if vals['setup_IorD'] == 'd':
        print 'okay... this might take a second.'
        subprocess.call(['python',path.join(vals['container_dir'],'setup.py'),'develop'])



    #######################
    ##CREATING .CONF FILE##
    #######################

    ngxtext='''
# {{name}}.conf

#upstream?

# configuration of the server
server {{{{
    # the port your site will be served on
    listen      {{port}};
    # the domain name it will serve for
    server_name {{host}}; # substitute your machine's IP address or FQDN
    charset     utf-8;

    # max upload size
    client_max_body_size 75M;   # adjust to taste

    location / {{{{ try_files $uri @{{name}}; }}}}
    location @{{name}}{{{{
      include uwsgi_params;
      uwsgi_pass unix://{{socket}};
    }}}}
}}}}

    '''.format(**vals)

    print ngxtext
    ngxfile = open(path.join(vals['container_dir'],vals['name']+'.conf'),'w')
    ngxfile.write(ngxtext)
    ngxfile.close()


    ######################
    ##CREATING .INI FILE##
    ######################

    wsgi_ini = """

[uwsgi]

# Environment related settings
# the base directory (full path)
chdir           = {{container_dir}}
# wsgi file
module          = {{name}}:app
# the virtualenv (full path)
home            = {{py_env}}

# process-related settings
# master
master          = true
# maximum number of worker processes
processes       = 10
# the socket (use the full path to be safe
socket          = {{socket}}
# ... with appropriate permissions - may be needed
chmod-socket    = 666
# clear environment on exit
vacuum          = true

    """.format(**vals)

    print wsgi_ini
    ini_file = open(path.join(vals['container_dir'],vals['name']+'.ini'),'w')
    ini_file.write(wsgi_ini)
    ini_file.close()



    ############################
    ##CREATING start_server.sh##
    ############################

    startserv='''

conf_file="{{name}}.conf"
nginx_dir="/etc/nginx/sites-enabled/"
script_dir="{{container_dir}}/"

py_env="{{py_env}}/"
py_activate="bin/activate"

ini_file="{{name}}.ini"
ini_dir="{{container_dir}}/"

echo "$nginx_dir$conf_file"

if [ -h "$nginx_dir$conf_file" ]
then
  echo "removing old link"
  sudo rm $nginx_dir$conf_file
fi

echo "linking nginx"
sudo ln -s $script_dir$conf_file $nginx_dir

sudo /etc/init.d/nginx restart
source $py_env$py_activate
uwsgi --ini $ini_dir$ini_file

    '''.format(**vals)


    print startserv
    sh_file = open(path.join(vals['container_dir'],'start_server.sh'),'w')
    sh_file.write(startserv)
    sh_file.close()


    print 'well that was a complete success.'

    print 'if you want to start the server, try sudo server_start.sh'

if __name__ == '__main__':
    vals = {{}}
    
    vals['host'] = '{host}'
    vals['name'] = '{name}'
    vals['socket'] = '{socket}'
    vals['container_dir'] = os.path.dirname(os.path.realpath(__file__)) 
    vals['module_dir'] = os.path.join(vals['container_dir'],vals['name'])
    vals['py_env'] = os.path.join(vals['container_dir'],'env') 
    vals['setup_IorD'] = None
    vals['port'] = None

    while vals['setup_IorD'] not in ['i','d']:
        vals['setup_IorD'] =  raw_input("Are we in development or should we install? (d/i): ")

    while vals['port'] not in range(10000):
        vals['port']= int(raw_input("Port site will be served on (1-10000): "))
    
    fix(vals)

