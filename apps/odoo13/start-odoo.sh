#!/bin/bash
set -e;

echo "---- ${HOSTNAME} ----"
echo ">>> OD_ROOT=${OD_ROOT}"
echo ">>> OD_HOME=${OD_HOME}"
cd /opt/odoo/app
echo ">>> now work at: ${PWD}"

echo ">>> start odoo..."
python3 odoo-bin -c odoo.conf

# --------- removed ---------
# keep container running
#tail -f /dev/null

#file_tag="${HOME}/.has_requirs4odoo.log"
#if [ ! -f "${file_tag}" ]; then
#    echo "pip3 install -r some-requires.txt" >> ${file_tag}
#    # virtual env
#    python3 -m venv ${HOME}/venv
#    PATH="$VIRTUAL_ENV/bin:$PATH"
#    echo ">>> VIRTUAL_ENV=${VIRTUAL_ENV}"
#    pip3 install -r requirements.txt
#fi
