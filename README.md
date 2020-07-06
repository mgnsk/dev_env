### Immutable development image

[![Build Status](https://travis-ci.com/mgnsk/dev_env.svg?branch=master)](https://travis-ci.com/mgnsk/dev_env)

This image serves the purpose of documenting my default environment.

Quick run on docker:
`$ docker run --rm -it mgnsk/dev-env /bin/bash`

All plugins and tools are version-locked.

#### Screenshot

Running on Termux:
![Android tablet with Termux running Vim](screenshot2.jpg)

`earlyoom` is started on each bash session.

Build and run:

`$ tusk build`

`$ tusk bash`
 
 To download/update image instead, run:

`$ tusk clean`

`$ tusk bash`
