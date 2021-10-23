import sys
import os
import logging
import time
import argparse
import errno
from xvfbwrapper import Xvfb
import subprocess

pcbnew_dir = os.path.dirname(os.path.abspath(__file__))
repo_root = os.path.dirname(pcbnew_dir)

sys.path.append(repo_root)


def mkdir_p(path):
    try:
        os.makedirs(path)
    except OSError as exc:  # Python >2.5
        if exc.errno == errno.EEXIST and os.path.isdir(path):
            pass
        else:
            raise

def wait_for_file_created_by_process(pid, file, timeout=5):
    process = psutil.Process(pid)

    DELAY = 0.01
    for i in range(int(timeout/DELAY)):
        open_files = process.open_files()
        logger.debug(open_files)
        if os.path.isfile(file):
            file_open = False
            for open_file in open_files:
                if open_file.path == file:
                    file_open = True
            
            if file_open:
                logger.debug('Waiting for process to close file')
            else:
                return
        else:
            logger.debug('Waiting for process to create file')
        time.sleep(DELAY)

    raise RuntimeError('Timed out waiting for creation of %s' % file)


logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

from contextlib import contextmanager

from xvfbwrapper import Xvfb

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

def clipboard_store(string):
    p = subprocess.Popen(['xclip', '-selection', 'clipboard'], stdin=subprocess.PIPE)
    outs, errs = p.communicate(input=string)
    if (errs):
        logger.error('Failed to store string in clipboard')
        logger.error(errs)

def clipboard_retrieve():
    p = subprocess.Popen(['xclip', '-o', '-selection', 'clipboard'], stdout=subprocess.PIPE)
    output = '';
    for line in p.stdout:
        output += line.decode()
    return output;

def wait_for_window(name, window_regex, timeout=10, focus=True):
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
    raise RuntimeError('Timed out waiting for %s window' % name)


def export_dsn(pcb_file, output_dir, record=True):
  mkdir_p(output_dir)


  recording_file = os.path.join(output_dir, 'run_drc_screencast.ogv')
  drc_output_file = os.path.join(os.path.abspath(output_dir), 'drc_result.rpt')

  xvfb_kwargs = {
    'width': 1024,
    'height': 768,
    'colordepth': 24,
  }

  with recorded_xvfb(recording_file, **xvfb_kwargs) if record else Xvfb(**xvfb_kwargs):
    with PopenContext(['pcbnew', pcb_file], close_fds=True) as pcbnew_proc:
      logger.info('Focus main pcbnew window')
      time.sleep(5)

      xdotool(['mousemove',
                '100',
                '200'
          ])

      time.sleep(1)

      xdotool(['click',
                '1'
      ])

      time.sleep(1)

      xdotool(['mousemove',
                '12',
                '12'
          ])

      time.sleep(1)

      xdotool(['click',
                '1'
      ])

      time.sleep(1)

      xdotool(['key',
                'Down',
                'Down',
                'Down',
                'Down',
                'Down',
                'Down',
                'Down',
                'Down',
                'Down'
            ])


      time.sleep(1)

      xdotool(['key','Right','Enter' ])
      
      time.sleep(1) 
      
      xdotool(['mousemove','300','60'])

      time.sleep(1)

      xdotool(['click','1'])
      xdotool(['click','1'])

      time.sleep(3)

      xdotool(['mousemove',
                '12',
                '12'
          ])

      time.sleep(3)

      xdotool(['click',
                '1'
      ])

      time.sleep(1)
      xdotool(['key',
                'Down',
                'Down',
                'Down',
                'Down',
                'Enter'
            ])
      time.sleep(5)
      pcbnew_proc.terminate()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='KiCad automated DRC runner')

    parser.add_argument('kicad_pcb_file', help='KiCad layout file')
    parser.add_argument('output_dir', help='Output directory')
    parser.add_argument('--ignore_unconnected', '-i', help='Ignore unconnected paths',
        action='store_true'
    )
    parser.add_argument('--record', help='Record the UI automation',
        action='store_true'
    )

    args = parser.parse_args()

    export_dsn(args.kicad_pcb_file, args.output_dir, args.record)