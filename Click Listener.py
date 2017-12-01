# Credit: https://github.com/andrensegura for finding pynput package and implementing it
# http://www.techbeamers.com/python-time-functions-usage-examples/ for Time implementation
# https://stackoverflow.com/questions/45973453/using-mouse-and-keyboard-listeners-together-in-python/ for specific mouse.Button parameters
# This program was originally written to help diagnose a bug in Nuclear Throne,
# but can easily be modified for other purposes.

from pynput import mouse
import time

def on_click(x, y, button, pressed):
    if button == mouse.Button.right:
        now = time.localtime(time.time())
        print()
        print('{0} at {1}'.format(
            'Pressed' if pressed else 'Released',
            (time.asctime(now))))
        print()
        if not pressed:
            # Stop listener
            print("------------------------------------")
            return False

while True:
    with mouse.Listener(
        on_click=on_click) as listener:
        listener.join()
