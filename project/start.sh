#!/bin/bash

python3 server.py Alford & python3 server.py Ball & python3 server.py Hamilton & python3 server.py Welsh &python3 server.py Holiday

fuser -k 8888/tcp
fuser -k 8889/tcp
fuser -k 8890/tcp
fuser -k 8891/tcp
fuser -k 8892/tcp
