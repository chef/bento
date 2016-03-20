#!/usr/bin/python

from __future__ import print_function
import sys, os
from distutils.version import StrictVersion
from argparse import ArgumentParser
from wsgiref.simple_server import make_server
import re
from json import loads, dumps

def load_jsons():
  images = {}
  for dirpath, dnames, fnames in os.walk("./builds"):
    for f in fnames:
      if f.endswith(".json"):
        blob = loads(open(os.path.join(dirpath, f)).read())
        if not blob['name'] in images:
          images[blob['name']] = {}
        if not blob['version'] in images[blob['name']]:
          images[blob['name']][blob['version']] = {}
        for p in blob['providers']:
          images[blob['name']][blob['version']][p['name']] = blob
  return images

def full_location_url(environ):
  from urllib import quote
  url = environ['wsgi.url_scheme']+'://'

  if environ.get('HTTP_HOST'):
    url += environ['HTTP_HOST']
  else:
    url += environ['SERVER_NAME']

    if environ['wsgi.url_scheme'] == 'https':
      if environ['SERVER_PORT'] != '443':
         url += ':' + environ['SERVER_PORT']
    else:
      if environ['SERVER_PORT'] != '80':
         url += ':' + environ['SERVER_PORT']

  url += quote(environ.get('SCRIPT_NAME', ''))
  return url

def build_json(images, name, server):
  ret = {}
  ret['description'] = None
  ret['short_description'] = None
  ret['name'] = 'bento/'+name
  ret['versions'] = []
  versions = images[name].keys()
  versions.sort(key=StrictVersion)
  for version in versions:
    v = {}
    v['version'] = version
    v['status'] = 'active'
    v['description_html'] = None
    v['description_markdown'] = None
    v['providers'] = []
    for provider in images[name][version].keys():
      p = {}
      p['name'] = provider
      p['url'] = "%s/bento/boxes/%s/versions/%s/providers/%s.box"%(server,name,version,provider)
      v['providers'].append(p)
    ret['versions'].append(v)
  return dumps(ret)

def application(env, start_response):
  content_type = 'text/html'
  do_json = False
  if 'HTTP_ACCEPT' in env and env['HTTP_ACCEPT'] == 'application/json':
    content_type = 'application/json'
    do_json = True
  images = load_jsons()

  path_re = re.compile('/bento/([a-z]+-[0-9\.]+)')
  match = path_re.match(env['PATH_INFO'])
  if match and match.group(1) in images:
    if do_json:
      start_response('200 OK', [('Content-Type', content_type)])
      return build_json(images, match.group(1), full_location_url(env))

  path_re = re.compile('/bento/boxes/([a-z]+-[0-9\.]+)/versions/([^/]+)/providers/([^/]+).box')
  match = path_re.match(env['PATH_INFO'])
  if match:
    name = match.group(1)
    version = match.group(2)
    provider = match.group(3)
    if not do_json and name in images and version in images[name] and provider in images[name][version]:
      start_response('200 OK', [('Content-Type', 'application/octet-stream')])
      box_name = images[name][version][provider]['providers'][0]['file']
      fd = open('builds/'+box_name, "r")
      block_size = 1024*1024
      if 'wsgi.file_wrapper' in env:
        return env['wsgi.file_wrapper'](fd, block_size)
      else:
        return iter(lambda: fd.read(block_size), '')

  start_response('200 OK', [('Content-Type', 'text/html')])
  return "Hello World!"

def main():
  parser = ArgumentParser(description='Fake Vagrant Server')
  parser.add_argument('-p', '--port', metavar='PORT', type=int,
                      default=8080, dest='port',
                      help="port to listen on")
  parser.add_argument('-a', '--address', metavar='ADDRESS',
                      default='localhost', dest='address',
                      help="address to listen on")
  args = parser.parse_args()
  server = make_server(args.address, args.port, application)
  server.serve_forever()

if __name__ == '__main__':
    main()
