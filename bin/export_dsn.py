#!/usr/bin/env python

#   Copyright 2015-2016 Scott Bezek and the splitflap contributors
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

import logging
import os
import subprocess
import sys
import time

from contextlib import contextmanager
from xvfbwrapper import Xvfb

electronics_root = "."
repo_root = os.path.dirname(electronics_root)
sys.path.append(repo_root)

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

class PopenContext(subprocess.Popen):
    def __enter__(self):
        return self
    def __exit__(self, type, value, traceback):
        if self.stdout:
            self.stdout.close()
        if self.stderr:
            self.stderr.close()
        if self.stdin:
            self.stdin.close()
        if type:
            self.terminate()
        # Wait for the process to terminate, to avoid zombies.
        self.wait()

@contextmanager
def recorded_xvfb(video_filename, **xvfb_args):
    with Xvfb(**xvfb_args):
        with PopenContext([
                'recordmydesktop',
                '--no-sound',
                '--no-frame',
                '--on-the-fly-encoding',
                '-o', video_filename], close_fds=True) as screencast_proc: 
            yield
            screencast_proc.terminate()

def xdotool(command):
    return subprocess.check_output(['xdotool'] + command)

def eeschema_export_bom(output_directory):
    time.sleep(5)
    xdotool(['mousemove', '24', '24'])
    xdotool(['click', '1'])
    xdotool(['key', 'ctrl+s'])
    xdotool(['key', 'Down'])
    xdotool(['key', 'Down'])
    xdotool(['key', 'Down'])
    xdotool(['key', 'Down'])
    xdotool(['key', 'Down'])
    xdotool(['key', 'Down'])
    xdotool(['key', 'Down'])
    xdotool(['key', 'Down'])
    xdotool(['key', 'Down'])
    xdotool(['key', 'Down'])
    xdotool(['key', 'Right'])
    time.sleep(5)
    xdotool(['key', 'Return'])
    time.sleep(5)
    xdotool(['key', 'Return'])
    time.sleep(5)
    xdotool(['key', 'ctrl+q'])
    logger.info('Wait before shutdown')
    time.sleep(1)
    xdotool(['key', 'ctrl+q'])
    time.sleep(1)
    xdotool(['key', 'ctrl+q'])
    time.sleep(1)
    xdotool(['key', 'ctrl+q'])
    time.sleep(5)

def export_bom(target):
    schematic_file = os.path.join(electronics_root, 'output/pcbs/' + target + '.kicad_pcb')
    output_dir = electronics_root

    screencast_output_file = os.path.join(output_dir, 'dsn.ogv')

    with recorded_xvfb(screencast_output_file, width=800, height=600, colordepth=24):
        with PopenContext(['pcbnew', schematic_file], close_fds=True) as eeschema_proc:
            eeschema_export_bom(output_dir)
            eeschema_proc.terminate()

if __name__ == '__main__':
    export_bom(sys.argv[1])

