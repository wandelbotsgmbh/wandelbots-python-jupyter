# https://medium.com/@albertazzir/blazing-fast-python-docker-builds-with-poetry-a78a66f5aed0
FROM python:3.11-bookworm AS builder

RUN pip install --upgrade pip \
    && pip install poetry==1.8.3

ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_CACHE_DIR=/tmp/poetry_cache

WORKDIR /app

COPY pyproject.toml poetry.lock ./

RUN --mount=type=cache,target=$POETRY_CACHE_DIR poetry install --without dev --no-root

FROM python:3.11-slim-bookworm AS runtime

ENV VIRTUAL_ENV=/app/.venv \
    PATH="/app/.venv/bin:$PATH"
ENV DATA_DIR=/app/data

COPY --from=builder ${VIRTUAL_ENV} ${VIRTUAL_ENV}
WORKDIR /app

RUN apt-get update && apt-get install -y nginx gettext-base

COPY static/app_icon.png static/app_icon.png
COPY nginx.conf.template /etc/nginx/conf.d/default.conf.template
COPY examples/ examples/
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh && mkdir $DATA_DIR

# Start Jupyter Notebook
ENTRYPOINT ["/app/entrypoint.sh"]