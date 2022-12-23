#!/bin/bash -eux

pkg update pkg:/package/pkg || true
pkg update --accept         || true
