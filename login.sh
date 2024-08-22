#!/bin/bash
# ssh archeros server
ssh -i ./id_rsa_cloud  -p 8222 cloud@$1
