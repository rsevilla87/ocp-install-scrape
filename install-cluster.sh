#!/bin/bash -u

reps=$1
install_config=bck/install-config.yaml
logfile=install-summary-$(date +%s).log
scrape=./scrape
installer=./openshift-install

echo "Dumping installation summary to ${logfile}"
for i in $(seq ${reps}); do 
  echo "#${i} Installing cluster"
  cp bck/install-config.yaml install-config.yaml
  ${installer} create cluster
  ${scrape} -log .openshift_install.log >> ${logfile}
  echo "#${i} Destroying cluster"
  ${installer} destroy cluster
  rm .openshift_install.log
done
