#!/bin/sh
envsubst '${BASE_PATH}' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf && \
    nginx & \
    # we need to copy them at runtime because an empty volume might be mounted at start
    cp -rn /app/examples $DATA_DIR/ && \
    cd $DATA_DIR && \
    jupyter lab \
        --ip=0.0.0.0 \
        --port=3001 \
        --no-browser \
        --allow-root \
        --ServerApp.base_url=$BASE_PATH \
        --ServerApp.password='' \
        --IdentityProvider.token='' \
        --LabApp.default_url='/lab/tree/examples/notebook.ipynb' & \
    sleep infinity