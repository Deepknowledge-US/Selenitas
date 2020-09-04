#!/bin/bash
gcc -O -I./lua -shared -fpic -o gpu.so gpu.c
