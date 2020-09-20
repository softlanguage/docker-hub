#FROM debian:buster-slim
#FROM python:3.7-slim-buster
FROM python:3.7-buster

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

# Generate locale C.UTF-8 for postgres and general locale data
ENV LANG C.UTF-8

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN apt-get update \
        && apt-get install -y --no-install-recommends \
            curl \
            #ca-certificates \
            #dirmngr \
            fonts-noto-cjk \
            #gnupg \
            #libssl-dev \
            node-less \
            npm \
            python3-num2words \
            python3-pip \
            python3-dev \
            libblas-dev \
            libldap2-dev \
            libsasl2-dev \
            #gcc \
            python3-phonenumbers \
            python3-pyldap \
            python3-qrcode \
            python3-renderpm \
            python3-setuptools \
            python3-slugify \
            python3-vobject \
            python3-watchdog \
            python3-xlrd \
            python3-xlwt \
            # xz-utils \
        && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.stretch_amd64.deb \
        && echo '7e35a63f9db14f93ec7feeb0fce76b30c08f2057 wkhtmltox.deb' | sha1sum -c - \
        && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
        && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# Install rtlcss (on Debian buster)
RUN npm install -g rtlcss

# --- begin of softlang -----
RUN pip3 install wheel \
    && pip3 install setuptools --upgrade
    
ENV OD_ROOT /opt/odoo
ENV OD_HOME ${OD_ROOT}/home
RUN mkdir -p ${OD_ROOT}/app \
    && mkdir -p ${OD_ROOT}/data

# requriements
ADD ./requirements.txt ${OD_ROOT}
RUN pip3 install -r ${OD_ROOT}/requirements.txt

#RUN useradd -m -d $OD_HOME -s /bin/bash odoo
RUN useradd -rm -d $OD_HOME -s /bin/bash -g root -u 8069 odoo

# chang own
RUN mkdir -p ${OD_HOME}/venv \
    && chown -R odoo ${OD_ROOT}

VOLUME ["${OD_ROOT}/app", "${OD_ROOT}/data", "${OD_HOME}"]

WORKDIR ${OD_ROOT}/home

# Expose Odoo services
EXPOSE 8069 8071 8072

# Set default user when running the container
USER odoo

# virtual env
#ENV VIRTUAL_ENV ${HOME}/venv
#RUN python3 -m venv ${HOME}/venv
#ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# CMD ["python3", "odoo-bin", "-c", "odoo.conf"]
CMD ["bash", "./start-odoo.sh"]
