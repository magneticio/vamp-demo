#!/bin/sh

reset=$(tput sgr0)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)

name="vamp"
cloud="local"
environment="demo"
version="1.1.1"

function parse_command_line() {
    flag_help=0
    flag_create=0
    flag_update=0
    flag_destroy=0

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
        -n=*|--name=*)
        name="${key#*=}"
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
    echo "${yellow}  -n=*|--name=*         ${green}Specifying the name. Defaults to '$name'.${reset}"
    echo "${yellow}  -c=*|--cloud=*        ${green}Specifying which cloud provider to user (local, gcloud). Defaults to '$cloud'.${reset}"
    echo "${yellow}  -e=*|--environment=*  ${green}Specifying the name of the environment. Defaults to '$environment'.${reset}"
    echo "${yellow}  -v=*|--version=*      ${green}Specifying the version of Vamp which will be deployed. Defaults to '$version'.${reset}"
}

function create {
    if [ $cloud != "local" ]; then
        set -e
        source ./scripts/create-cluster-$cloud.sh $name
        source ./scripts/import-cluster-$cloud.sh $name
        set +e
    fi

    ./scripts/deploy-vamp.sh $cloud $name $environment $version

    echo "Your demo environment is ready!"
    if [ $cloud != "local" ]; then
        echo "Vamp URL: http://$name.demo.vamp.cloud"
    else
        echo "Run: kubectl proxy"
        echo "Vamp URL: http://localhost:8001/api/v1/namespaces/default/services/vamp:/proxy/#"
    fi
}

function update {
    echo "Updating environment '$name' on cloud '$cloud'"
    if [ $cloud != "local" ]; then
        set -e
        source ./scripts/import-cluster-$cloud.sh $name
        set +e
    fi
    ./scripts/update-vamp.sh $cloud $name $environment $version
}

function destroy {
    echo "Destroying environment '$name' on cloud '$cloud'"
    if [ $cloud != "local" ]; then
        ./scripts/destroy-cluster.sh $cloud
    else
        ./scripts/delete-vamp.sh $cloud
    fi
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

if [ ${flag_destroy} -eq 1 ]; then
    destroy
fi
