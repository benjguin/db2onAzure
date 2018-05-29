# this file is intended to be sourced
for db2srv in "${db2servers[@]}"
do
    echo "waiting for $db2srv to reboot"
    stay="true"
    tries=0
    while [ "$stay" == "true" ]
    do
        ssh $db2srv whoami
        x=`ssh $db2srv whoami | grep rhel | wc -l`
        if [ "$x" == "1" ]
        then
            stay="false"
        else
            if [ $tries -gt 10 ]
            then
                echo "Servers did not reboot correctly"
                exit 1
            fi
            echo "waiting for 30 seconds ..."
            sleep 30s
            ((tries=tries+1))
        fi
    done
done
