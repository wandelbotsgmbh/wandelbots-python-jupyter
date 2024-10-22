# https://medium.com/@albertazzir/blazing-fast-python-docker-builds-with-poetry-a78a66f5aed0
FROM python:3.9-buster as builder

RUN pip install --upgrade pip \
    && pip install poetry==1.8.3

ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_CACHE_DIR=/tmp/poetry_cache

WORKDIR /app

COPY pyproject.toml poetry.lock ./

RUN --mount=type=cache,target=$POETRY_CACHE_DIR poetry install --without dev --no-root

FROM python:3.9-slim-buster as runtime

ENV VIRTUAL_ENV=/app/.venv \
    PATH="/app/.venv/bin:$PATH"

COPY --from=builder ${VIRTUAL_ENV} ${VIRTUAL_ENV}
WORKDIR /app
COPY . .

RUN apt-get update
RUN apt-get install -y nginx gettext-base


COPY static/app_icon.png /app/app_icon.png

COPY nginx.conf.template /etc/nginx/conf.d/default.conf.template

# Start Jupyter Notebook
# ENTRYPOINT ["sh", "-c", "export FLASK_APP=flask_app.py && flask run --host=0.0.0.0 --port=3000 & jupyter lab --ip=0.0.0.0 --port=3001 --no-browser --allow-root --NotebookApp.base_url=$BASE_PATH --NotebookApp.token='' --NotebookApp.password='' --NotebookApp.extra_static_paths=/app/static --NotebookApp.default_url='/lab/tree/examples/notebook.ipynb' & sleep infinity"]
# ENTRYPOINT ["sh", "-c", "jupyter lab --ip=0.0.0.0 --port=3000 --no-browser --allow-root --NotebookApp.base_url=$BASE_PATH --NotebookApp.token='' --NotebookApp.password='' --NotebookApp.extra_static_paths=/app/static --NotebookApp.default_url='/lab/tree/examples/notebook.ipynb' & sleep infinity"]
ENTRYPOINT ["sh", "-c", "envsubst '${BASE_PATH}' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf && nginx & jupyter lab --ip=0.0.0.0 --port=3000 --no-browser --allow-root --NotebookApp.base_url=$BASE_PATH --NotebookApp.token='' --NotebookApp.password='' --NotebookApp.extra_static_paths=/app/static --NotebookApp.default_url='/lab/tree/examples/notebook.ipynb' & sleep infinity"]