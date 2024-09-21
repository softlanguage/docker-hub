# python3.10
FROM docker.io/python:3.10-slim-bullseye
ARG uhome=/siri
WORKDIR $uhome/app
RUN useradd -d $uhome -s /bin/sh -u 5001 siri && chown -R siri:siri $uhome
USER siri
# COPY --from=build /app/requirements.txt requirements.txt
# may need http_proxy by squid
# mirrors.cloud.aliyuncs.com
arg pip_host='mirrors.cloud.aliyuncs.com' 
arg pip_index="https://${pip_host}/pypi/simple/"
COPY requirements.txt .
RUN pip install -r requirements.txt -i $pip_index --trusted-host $pip_host
COPY . .
RUN pwd && ls -lah

#CMD python -m http.server --bind 0.0.0.0 --directory . 5000
CMD ["python", "app.py"]
