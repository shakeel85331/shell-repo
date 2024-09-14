#!/bin/bash

echo "Checking if all the mandatory parameters are provided."
if [ $# -ne 1 ]; then
    echo "Mandatory params not provided"
    exit 1
fi
