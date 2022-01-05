#!/bin/sh

release_ctl eval --mfa "Sntx.Tasks.Release.migrate/1" --argv -- "$@"
