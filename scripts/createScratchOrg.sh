#!/bin/bash
source `dirname $0`/config.sh

execute() {
  $@ || exit
}

echo "set default devhub user"
sf config set target-dev-hub=$DEV_HUB_ALIAS

echo "deleting old scratch org"
sf org delete scratch -p --target-org $SCRATCH_ORG_ALIAS

echo "Creating scratch ORG"
execute sf org create scratch --alias $SCRATCH_ORG_ALIAS --set-default --definition-file ./config/project-scratch-def.json --duration-days 29 -w 30

echo "Deploying changes to scratch org"
execute sf project deploy start

echo "Make sure Org user is english"
sf data update record -s User -w "Name='User User'" -v "Languagelocalekey=en_US"

echo "Assigning permissions"
execute sf org assign permset --name ProcessityUser

echo "Running apex tests"
execute sf apex run test --test-level RunLocalTests -w 30

echo "Scratch org is ready!"
sf org open