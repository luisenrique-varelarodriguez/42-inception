#!/bin/bash
set -e

exec redis-server --bind 0.0.0.0 --protected-mode no
