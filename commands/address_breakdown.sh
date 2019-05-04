#!/bin/bash

find $HOME/mail/$1 -maxdepth 1 -type d | sed "1 d"
