<p align="center">
  <img src="https://github.com/Noovolari/leapp/blob/master/.github/images/README-1.png#gh-dark-mode-only" alt="Leapp" height="150" />
    <img src="https://github.com/Noovolari/leapp/blob/master/.github/images/README-1-dark.png#gh-light-mode-only" alt="Leapp" height="150" />
</p>

# Leapp SSM ECS COMMAND EXECUTION

## Introduction
This plugin simplify the process of executing command against your conatiners deployed in AWS ECS cluster through SSM

## How it works
The plugin makes use of AWS Systems Manager (SSM) Session Manager to establish a connection with the running container and runs commands in a running container.
Executing the plugin, a terminal is open, asking interactively for some inputs:

1. Cluster ECS
1. Service
1. Task
1. Container
1. Command to execute

The plugin is a python script.

## Prerequisites

1. Python 3.X.X installed.
1. Module Boto3 installed in python

