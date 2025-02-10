"""
# ~/.bashrc 
alias my_vnstat='python vnstat_cli.py | less'
"""

import shlex
import subprocess
from datetime import datetime
import shutil

"""
Get the width of the terminal, and Print a line of hyphens based on the terminal width
import shutil
terminal_width = shutil.get_terminal_size().columns 
print('-' * terminal_width)
"""
terminal_width = shutil.get_terminal_size().columns - 1
fmt_timestamp = "%D %H:%M:%S"
start_at = datetime.now().strftime(fmt_timestamp)
print(f"Start at: {start_at}", flush=True)


def print_log(log):
    print(log, flush=True)


def exec_subproc(command):
    """
    run command by subprocess
    """
    if isinstance(command, str):
        args = shlex.split(command)
    elif isinstance(command, list):
        args = command

    print_log(f"\n\n{'.' * terminal_width}\n# {args}")
    try:
        result = subprocess.check_output(
            args,
            cwd="/tmp",
            shell=False,
        ).decode("utf-8")
        return result
    except Exception as e:
        return "$$Error: " + str(e)


if __name__ == "__main__":
    hosts = [
        "prd-proxy01",
        "prd-proxy02",
        "oss1.prd.zyb",
        "oss2.prd.zyb",
        "monitor.dev",
    ]

    # output traffic data of 2months and 2days
    cmd_vnstat = "vnstat -i eth0"

    # run command on each host
    for host in hosts:
        cmd_ssh = f"ssh {host} '{cmd_vnstat}'"
        log2 = exec_subproc(cmd_ssh)
        print_log(log2)

    # run command on localhost
    log1 = exec_subproc(cmd_vnstat)
    print_log(log1)

    # finish
    print_log("press q to exit")
