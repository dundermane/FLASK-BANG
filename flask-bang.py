#!/usr/bin/env python

import os
import subprocess

vals = {}

print "You need two names. Site name. and what you'll name your module (one,lowercase word)"
vals['site_name'] = raw_input("Site Name: ")
vals['name'] = raw_input("Module name: ")
vals['host'] = raw_input("host name? eg. example.com : ")
vals['port'] = 80
vals['socket'] = '/tmp/'+vals['name']+'uwsgi.sock'
vals['this_dir'] = os.path.dirname(os.path.realpath(__file__))
vals['container_dir'] = os.path.join(os.getcwd(),vals['name'])
vals['module_dir'] = os.path.join(vals['container_dir'],vals['name'])
vals['py_env'] = os.path.join(vals['container_dir'],'env')

vals['nginx_dir'] = '/etc/nginx/'
vals['nginx_uwsgi'] = os.path.join(vals['nginx_dir'],'uwsgi_params')
vals['nginx_sites'] = os.path.join(vals['nginx_dir'],'sites-enabled')
vals['setup_IorD'] = 'd'

##RENDER FILE FROM TEMPLATE

def fromTemplate( destination , template , input):
    tmp = open( template )
    tmptxt = tmp.read()
    tmptxt = tmptxt.format(**input)
    tmp.close()

    dest = open( destination , 'w')
    dest.write( tmptxt )
    dest.close()



##CREATE DIRECTORY SKELETON

os.mkdir(vals['container_dir'])
os.mkdir(vals['module_dir'])
os.mkdir(vals['py_env'])
os.mkdir(os.path.join(vals['module_dir'],'templates'))
os.mkdir(os.path.join(vals['module_dir'],'static'))
os.mkdir(os.path.join(vals['module_dir'],'static/js'))
os.mkdir(os.path.join(vals['module_dir'],'static/css'))


##CREATE README, SETUP.PY, IMTS.PY

fromTemplate(os.path.join(vals['container_dir'],'README.TXT'),
             os.path.join(vals['this_dir'],'resources/readme.tpl'),
             vals)

fromTemplate(os.path.join(vals['container_dir'],'setup.py'),
             os.path.join(vals['this_dir'],'resources/setup.tpl'),
             vals)

fromTemplate(os.path.join(vals['container_dir'],'imts.py'),
             os.path.join(vals['this_dir'],'resources/imts.tpl'), 
             vals)

##CREATE BASIC MODULE

fromTemplate(os.path.join(vals['module_dir'],'__init__.py'),
             os.path.join(vals['this_dir'],'resources/init.tpl'),
             vals)

fromTemplate(os.path.join(vals['module_dir'],'views.py'),
             os.path.join(vals['this_dir'],'resources/views.tpl'),
             vals)

##GRAB UWSGI_PARAMS

subprocess.call(['cp', 
            vals['nginx_uwsgi'], 
            vals['container_dir'] ])

##FINISH IT UP WITH IMTS.PY

subprocess.call(['python',
           os.path.join(vals['container_dir'],'imts.py')])

##DONT FORGET THE PERMISSIONS

subprocess.call(['chmod',
                '+x',
                os.path.join(vals['container_dir'],'imts.py')])

subprocess.call(['chmod',
                '+x',
                os.path.join(vals['container_dir'],'start_server.sh')])
