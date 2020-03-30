import logging
import os
import sys

filehandler = logging.FileHandler(filename=f'{os.getenv("DEPLOYMENT_ROOT")}/ci.log')
filehandler.setLevel(os.getenv("CILOGLEVEL", "INFO"))

consolehandler = logging.StreamHandler(stream=sys.stderr)
consolehandler.setLevel("INFO")
