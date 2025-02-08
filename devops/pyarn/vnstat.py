"""
# 0 */2 * * * smtppass=pwd sh -e /mnt/nas1/pyops/devops/network/vnstat.sh
set -e
cwd=$(realpath $(dirname $0))
echo "cwd = $cwd"
# throttle=2G
python3 $cwd/vnstat.py --rx=2048 --tx=2048
    -t=bug.fyi@foxmail.com  -u'sys-message@mail.crm.pub' -P="$smtppass"
    -s'sdInc Network traffic is over the threshold' 2>&1 | tee -a /tmp/cron_vnstat_anomaly.log

    
python vnstat.py -i eth0 --rx=10 --tx 10

# interface=eth0, get data of the last 5hours
vnstat -i eth0 --json h 5 |jq .interfaces[0].traffic.hour
"""

import io
import json
import shlex
import subprocess
import argparse
from datetime import datetime
import smtplib
from email.message import EmailMessage
import logging

fmt_timestamp = "%D %H:%M:%S"
start_at = datetime.now().strftime(fmt_timestamp)
log_buffer = io.StringIO()

# Configure the root logger
logging.basicConfig(
    level=logging.INFO,
    # format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    # datefmt='%Y-%m-%d %H:%M:%S'
    format="%(asctime)s - %(message)s",
    datefmt="%H:%M:%S",
    handlers=[
        logging.StreamHandler(log_buffer),
        logging.StreamHandler(),
    ],
)

# Create the parser
parser = argparse.ArgumentParser(description="vnstat monitor CLI tool.", add_help=False)
# Add arguments
parser.add_argument("-i", "--ifnet", default="eth0", type=str, help="interface name")
parser.add_argument("--rx", type=int, default=1024, help="throttle of RX, unit=MB")
parser.add_argument("--tx", type=int, default=1024, help="throttle of TX, unit=MB")
# smtp
parser.add_argument("-h", "--host", default="smtpdm.aliyun.com")
parser.add_argument("-p", "--port", type=int, default=465)
parser.add_argument("-u", "--user", default="")
parser.add_argument("-P", "--password", default="")
parser.add_argument("-t", "--to", default="")
parser.add_argument("-s", "--subject", default="Network traffic is over the threshold")

# Parse the arguments
parsed_args = parser.parse_args()
ssmtp_host = parsed_args.host
ssmtp_port = parsed_args.port
ssmtp_user = parsed_args.user
ssmtp_password = parsed_args.password
ssmtp_to = parsed_args.to
ssmtp_subject = parsed_args.subject


# define throttle
threshold_rx = parsed_args.rx
threshold_tx = parsed_args.tx
# latest 5 days
vnstat_cmd = f"vnstat -i {parsed_args.ifnet} --json d 3"

logging.info(f"check network traffic {start_at}")
logging.info(
    f"interface={parsed_args.ifnet}, Throttles: rx={parsed_args.rx}MB,tx={parsed_args.tx}MB"
)

def send_email(recipient_email, subject, body):
    message = EmailMessage()
    message["From"] = ssmtp_user
    message["To"] = recipient_email
    message["Subject"] = subject
    message.set_content(body)
    if recipient_email == "" or ssmtp_user == "":
        logging.info(f"dry-run SMTP\nSubject: {subject}\nBody: {body}")
    else:
        with smtplib.SMTP_SSL(ssmtp_host, ssmtp_port) as smtp:
            # smtp.starttls(); smtp=smtplib.SMTP('host',587)
            smtp.login(ssmtp_user, ssmtp_password)
            smtp.send_message(message)


def exec_subproc(command):
    if isinstance(command, str):
        args = shlex.split(command)
    elif isinstance(command, list):
        args = command

    logging.info(f">> cmd: {args}")
    try:
        result = subprocess.check_output(
            args,
            cwd="/tmp",
            shell=False,
        ).decode("utf-8")
        return result
    except Exception as e:
        return "$$Error: " + str(e)


def detect_network_anomaly():
    jdata = exec_subproc(vnstat_cmd)
    vndata = json.loads(jdata)
    rows = vndata["interfaces"][0]["traffic"]["day"]

    #import pprint
    #pprint.pprint(rows)
    #pprint.pprint(parsed_args)
    for x1 in rows:
        d1 = x1["date"]
        day = f'{d1["year"]}-{d1["month"]:02d}-{d1["day"]:02d}'
        rx = x1["rx"] / 1024 / 1024
        tx = x1["tx"] / 1024 / 1024
        logging.info(f"{day} rx ={rx: .2f} MB\ttx ={tx: .2f} MB")

    if rx > threshold_rx or tx > threshold_tx:
        logging.info(
            f"latest network traffic is anomalous: f'{rx: .2f} MB, {tx: .2f} MB'"
        )
        send_email(
            ssmtp_to,
            f"[Anomaly {start_at}] - {ssmtp_subject}",
            log_buffer.getvalue(),
        )


if __name__ == "__main__":
    detect_network_anomaly()
    print(flush=True)

