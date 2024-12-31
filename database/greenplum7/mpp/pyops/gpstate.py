# -*- coding: utf-8 -*-
#!/usr/bin/env python
#!python3
# [WARNING]

import subprocess
import io
import datetime
import smtplib
from email.message import EmailMessage
import logging

fmt_timestamp = "%D %H:%M:%S"
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


def send_email():
    body = f"""
Host: WBXZ-GP6-dw01
Warn: gpstate has warning
How to fix:
> gprecoverseg -r # rebalance if has enough disk spaces
> gprecoverseg -F # full recovery by rebuild

------ log ----
{log_buffer.getvalue()}
"""
    # Set: host, port, mail_from and password
    mail_from = "sys-alert@email.of.domain"

    message = EmailMessage()
    message["From"] = mail_from
    message["To"] = "bug.fyi@foxmail.com"
    message["Subject"] = "[WARNING] Greenplum6 gpstate"
    message.set_content(body)
    with smtplib.SMTP_SSL("127.0.0.1", 465) as smtp:
        # smtp.starttls(); smtp=smtplib.SMTP('host',587)
        smtp.login(mail_from, "passwd")
        smtp.send_message(message)


def exec_job_command():
    print("\n-- execute check --\n", flush=True)
    start_at = datetime.datetime.now().strftime(fmt_timestamp)

    hasError = False

    try:
        script = """
source /home/gpadmin/.bashrc;
gpstate
"""
        cmds = ["sh", "-e", "-c", script]
        proc = subprocess.Popen(
            cmds,
            shell=False,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,  # set stderr to stdout, then to PIPE by stdout
            # universal_newlines=True,  # Cross-Platform, bufsize=1, sentinel=""
            bufsize=4096,  # 1 if universal_newlines=True
        )
        for line in iter(proc.stdout.readline, b""):
            output = line.decode("utf-8")
            logging.info(output)
            if "WARNING" in output or "ERROR" in output:
                hasError = True
    except Exception as e:
        # the fetch will handle the error message
        logging.error(e)
        hasError = True
    finally:
        proc.kill()
        return_code = proc.wait(5)
        logging.info(f"Kill code={return_code}")
        if return_code != 0:
            hasError = True

    if hasError:
        print("\n-- send mail --\n", flush=True)
        send_email()


if __name__ == "__main__":
    exec_job_command()
