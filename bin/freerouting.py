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


def wait_for_window_class(name, window_regex, timeout=30, focus=True):
    DELAY = 0.5
    logger.info('Waiting for %s window...', name)
    xdotool_command = ['search', '--onlyvisible', '--class', window_regex]
    if focus:
        xdotool_command.append('windowfocus')

    for i in range(int(timeout/DELAY)):
        try:
            window_id = xdotool(xdotool_command).strip()
            logger.info('Found %s window', name)
            logger.debug('Window id: %s', window_id)
            return window_id
        except subprocess.CalledProcessError:
            pass
        time.sleep(DELAY)


def wait_for_window_gone(name, window_regex, timeout=60, focus=True):
    DELAY = 0.5
    logger.info('Waiting for %s window to be gone...', name)
    xdotool_command = ['search', '--onlyvisible', '--name', window_regex]
    if focus:
        xdotool_command.append('windowfocus')

    for i in range(int(timeout/DELAY)):
        try:
            window_id = xdotool(xdotool_command).strip()
            logger.info('Found %s window', name)
            logger.debug('Window id: %s', window_id)
            pass
        except subprocess.CalledProcessError:
            return
        time.sleep(DELAY)


def wait_for_window(name, window_regex, timeout=30, focus=True):
    DELAY = 0.5
    logger.info('Waiting for %s window...', name)
    xdotool_command = ['search', '--onlyvisible', '--name', window_regex]
    if focus:
        xdotool_command.append('windowfocus')

    for i in range(int(timeout/DELAY)):
        try:
            window_id = xdotool(xdotool_command).strip()
            logger.info('Found %s window', name)
            logger.debug('Window id: %s', window_id)
            return window_id
        except subprocess.CalledProcessError:
            pass
        time.sleep(DELAY)


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


def export_bom(target):
    schematic_file = os.path.join(electronics_root, 'output/pcbs/' + target + '.kicad_pcb')
    output_dir = electronics_root

    screencast_output_file = os.path.join(output_dir, 'freerouting.ogv')

    with recorded_xvfb(screencast_output_file, width=1920, height=1080, colordepth=24):
        with PopenContext([ "java", "-jar", "freerouting.jar",
            "-de", "output/pcbs/" + target + ".dsn", 
            "-dr", "output/pcbs/" + target + ".rules", 
            "-do", "output/pcbs/" + target + ".ses", 
            "-mp", "1000"
            ], close_fds=True) as freerouting_proc:
            wait_for_window('freerouting', 'Board Layout', timeout=300)
            time.sleep(3)
            xdotool(['mousemove', '760', '60'])
            xdotool(['click', '1'])
            wait_for_window_gone('freerouting','Board Layout', timeout=300)
            freerouting_proc.terminate()

if __name__ == '__main__':
    export_bom(sys.argv[1])

