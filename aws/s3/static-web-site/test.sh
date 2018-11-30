#!/usr/bin/env bash

echo "Index"
curl -v  $(terraform output url)

echo "Error"
curl -v  $(terraform output url)/no-existant-file
