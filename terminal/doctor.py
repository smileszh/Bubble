#!/usr/bin/env python
#
# Licensed under the Biostar Handbook license.
#
from __future__ import print_function, unicode_literals

import os, time
import re
import subprocess
import sys
from os.path import expanduser
from sys import platform

PY3 = True if (sys.version_info > (3, 0)) else False


def exists():
    return True


def regexp_check(pattern, text):
    return re.search(pattern, text, re.MULTILINE)


def more_recent(pattern, text):
    version = text.strip()
    return version >= pattern


# A list of tools to check.
TOOLS = [
    'bwa', 'datamash', 'fastqc -h', 'hisat2', 
    'featureCounts', 'efetch', 'esearch', 'samtools', 'fastq-dump', 'bowtie2', 'bcftools',
    'seqtk', 'seqkit', 'bio', 'fastq-dump -X 1 -Z SRR1553591',
]

def bash_check():
    bashrc = expanduser("~/.bashrc")
    bashprofile = expanduser("~/.bash_profile")

def path_check():

    # The PATH variable
    paths = os.environ.get('PATH').split(':')
    bindir = expanduser("~/bin")

    #
    # We need ~/bin to be in the PATH
    #
    if bindir not in paths:
        print("#")
        print("# Warning: the ~/bin folder is not in your PATH!")
        print("#")


def tool_check(tools):

    print("# Checking symptoms ...")

    # Give the user time to read the message.
    time.sleep(1)

    errlist = []

    for cmd in tools:
        args = cmd.split()

        print("# {:13s}".format(cmd), end="")
        sys.stdout.flush()

        res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)

        code = res.returncode

        if code not in (0, 1, 255):
            print(" --> ERROR")
            errlist.append(cmd)
        else:
            print(" ... OK")

    return errlist


FIXME = """
#
# Please see the installation at: https://www.biostarhandbook.com/
#
# If you are feeling adventurous, you can try the following:
#
# Uninstalls everything.
curl http://data.biostarhandbook.com/uninstall.sh | bash

# Installs everything.
curl http://data.biostarhandbook.com/install.sh | bash

"""


def fixme():
    print(FIXME)


def health_check():

    errors = tool_check(tools=TOOLS)

    if errors:
        words = ", ".join(errors)
        print("#")
        print("# Found some problems")
        print("#")
        print("# Unable to run: {}".format(words))
        print("#")
        print("# Check the Biostar Handbook for installation help.")
        print("#")
    else:
        print("# You are doing well, Majesty!")

    path_check()

if __name__ == '__main__':
    if '--fixme' in sys.argv:
        fixme()
    else:
        print("# Doctor! Doctor! Give me the news.")
        health_check()