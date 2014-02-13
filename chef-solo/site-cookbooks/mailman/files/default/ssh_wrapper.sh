#!/bin/env bash
/usr/bin/env ssh -o "StrictHostKeyChecking=no" -i "/root/.ssh/deploy_id_rsa" $1 $2
