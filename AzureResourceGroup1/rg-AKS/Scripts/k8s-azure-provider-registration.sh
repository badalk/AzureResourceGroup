
#!/bin/bash

set -e # stop on errors
set -x # print commands when they are executed

az provider register -n Microsoft.ContainerService
az provider register -n Microsoft.ContainerRegistry
