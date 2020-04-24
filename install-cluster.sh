#!/bin/bash -u


reps=$1
install_config=bck/install-config.yaml
logfile=install-summary-$(date +%s).log
scrape=./scrape
installer=./openshift-install

echo "Dumping installation summary to ${logfile}"
for i in $(seq ${reps}); do 
  echo "#${i} Installing cluster"
  cp ${install_config} install-config.yaml
  ${installer} create cluster
  ${scrape} -log .openshift_install.log >> ${logfile}
  echo "#${i} Destroying cluster"
  ${installer} destroy cluster
  rm .openshift_install.log
done


INFRA=$(awk '/Infra.+/{sum += $3; l+=1}END{print sum/l}' ${logfile})
API=$(awk '/API.+/{sum += $4; l+=1}END{print sum/l}' ${logfile})
BOOT_COMPLETED=$(awk '/Bootstrap completed.+/{sum += $3; l+=1}END{print sum/l}' ${logfile})
BOOT_DESTROYED=$(awk '/Bootstrap destroyed.+/{sum += $3; l+=1}END{print sum/l}' ${logfile})
CLUSTER_UP=$(awk '/Cluster initialized.+/{sum += $3; l+=1}END{print sum/l}' ${logfile})

cat << EOF
Cluster deployment time summary
-------------------------------

Infrastructure created: ${INFRA}s
API Server available:   ${API}s
Bootstrap completed:    ${BOOT_COMPLETED}s
Bootstrap destroyed:    ${BOOT_DESTROYED}s
Cluster initialized:    ${CLUSTER_UP}s

Total:                  $(echo $INFRA + $API + $BOOT_COMPLETED + $BOOT_DESTROYED + $CLUSTER_UP | bc)s
EOF
