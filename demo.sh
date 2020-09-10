#!/bin/sh

reset=$(tput sgr0)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)

name="vamp"
cloud="local"
environment="demo"
version="1.2.0"
demo=""

if [ -f "./.env.sh" ]; then
    source ./.env.sh
fi

function parse_command_line() {
    flag_help=0
    flag_create=0
    flag_update=0
    flag_deploy=0
    flag_run=0
    flag_undeploy=0
    flag_destroy=0
    flag_skip_cluster=0

    for key in "$@"
    do
    case ${key} in
        help)
        flag_help=1
        ;;
        create)
        flag_create=1
        ;;
        update)
        flag_update=1
        ;;
        destroy)
        flag_destroy=1
        ;;
        deploy)
        flag_deploy=1
        ;;
        run)
        flag_run=1
        ;;
        undeploy)
        flag_undeploy=1
        ;;
        -n=*|--name=*)
        name="${key#*=}"
        shift
        ;;
        -d=*|--demo=*)
        demo="${key#*=}"
        shift
        ;;
        -c=*|--cloud=*)
        cloud="${key#*=}"
        shift
        ;;
        -e=*|--environment=*)
        environment="${key#*=}"
        shift
        ;;
        -v=*|--version=*)
        version="${key#*=}"
        shift
        ;;
        --skip-cluster)
        flag_skip_cluster=1
        ;;
        *)
        ;;
    esac
    done
}

function print_help() {
    echo "${green}Usage of $0:${reset}"
    echo "${yellow}  help                  ${green}Help.${reset}"
    echo "${yellow}  create                ${green}Creates a fresh environment.${reset}"
    echo "${yellow}  update                ${green}Updates an environment.${reset}"
    echo "${yellow}  destroy               ${green}Destroys an environment.${reset}"
    echo "${yellow}  deploy                ${green}Deploys a demo into the environment.${reset}"
    echo "${yellow}  run                   ${green}Runs a demo.${reset}"
    echo "${yellow}  undeploy              ${green}Removes a demo from the environment.${reset}"
    echo "${yellow}  -n=*|--name=*         ${green}Specifying the name. Defaults to '$name'.${reset}"
    echo "${yellow}  -c=*|--cloud=*        ${green}Specifying which cloud provider to user (local, gcloud). Defaults to '$cloud'.${reset}"
    echo "${yellow}  -e=*|--environment=*  ${green}Specifying the name of the environment. Defaults to '$environment'.${reset}"
    echo "${yellow}  -v=*|--version=*      ${green}Specifying the version of Vamp which will be deployed. Defaults to '$version'.${reset}"
    echo "${yellow}  -d=*|--demo=*         ${green}Specifying the demo to deploy into the environment.${reset}"
    echo "${yellow}  --skip-cluster        ${green}Skips the creation of cluster resources.${reset}"
}

function create {
    if [ $cloud != "local" ]; then
        set -e
        source ./scripts/create-cluster-$cloud.sh $name
        source ./scripts/import-cluster-$cloud.sh $name
        set +e
    fi

    ./scripts/deploy-vamp.sh $cloud $version

    echo "export cloud=$cloud && export name=$name" >> ./.env.sh && chmod +x ./.env.sh
    
    if [ $cloud != "local" ]; then
        echo "Vamp URL: http://$name.demo-ee.vamp.cloud:8080"
    else
        echo "Run: kubectl proxy"
        echo "Vamp URL: http://localhost:8001/api/v1/namespaces/default/services/vamp:/proxy/#"
    fi
    echo "Your demo environment is ready!"
}

function update {
    echo "Updating environment '$name' on cloud '$cloud'"
    if [ $cloud != "local" ]; then
        set -e
        source ./scripts/import-cluster-$cloud.sh $name
        set +e
    fi
    ./scripts/update-vamp.sh $cloud $version
}

function deploy {
    echo "Deploying demo '$demo'"
    if [ $demo != "" ]; then
        ./demos/$demo/deploy.sh $name $cloud
    fi
    echo "Deployed demo '$demo'"
    rm -rf ./temp
}

function run {
    echo "Run demo '$demo'"
    if [ $demo != "" ]; then
        ./demos/$demo/run.sh $name $cloud
    fi
    echo "Stopping demo '$demo'"
    rm -rf ./temp
}

function undeploy {
    echo "Removing demo '$demo'"
    if [ $demo != "" ]; then
        ./demos/$demo/undeploy.sh $name $cloud
    fi
    echo "Removed demo '$demo'"
    rm -rf ./temp
}

function destroy {
    echo "Destroying environment '$name' on cloud '$cloud'"
    if [ $cloud != "local" ]; then
        ./scripts/destroy-cluster-$cloud.sh $name
    else
        ./scripts/delete-vamp.sh $cloud
    fi
    rm ./.env.sh
}

parse_command_line $@

if [ ${flag_help} -eq 1 ] || [[ $# -eq 0 ]]; then
    print_help
fi

if [ ${flag_create} -eq 1 ]; then
    create
fi

if [ ${flag_update} -eq 1 ]; then
    update
fi

if [ ${flag_deploy} -eq 1 ]; then
    deploy
fi

if [ ${flag_run} -eq 1 ]; then
    run
fi

if [ ${flag_undeploy} -eq 1 ]; then
    undeploy
fi

if [ ${flag_destroy} -eq 1 ]; then
    destroy
fi
