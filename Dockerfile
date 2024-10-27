# 使用 Python 3.9 的 Alpine 3.13 版本作為基礎映像
FROM python:3.9-alpine3.13

# 設置維護者信息
LABEL maintainer="EDLLin"

# 設置環境變量，確保 Python 輸出不會被緩衝
ENV PYTHONBUFFERED 1

# 複製 requirements.txt 到臨時目錄
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt

# 複製應用程式代碼到容器中的 /app 目錄
COPY ./app /app

# 設置工作目錄為 /app
WORKDIR /app

# 暴露容器的 8000 端口
EXPOSE 8000

ARG DEV=false
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

ENV PATH="/py/bin: $PATH"

USER django-user