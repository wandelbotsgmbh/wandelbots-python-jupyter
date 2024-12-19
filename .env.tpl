# provide the host where the nova api is running (e.g. your virtual dev instance)
NOVA_HOST="{{ .InstanceInformation.NovaApiHost }}"
CELL_ID="cell"
LOG_LEVEL=info

###
# SECRETS
#
# These should never be defined in the .env file, only in the gitignored .env.local or 
# in the environment variables of the deployment.
###
NOVA_ACCESS_TOKEN="{{ .InstanceInformation.AccessToken }}"