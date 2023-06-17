"""
Generates a string on startup that uniquely identifies this host
"""

import logging
import random
import uuid

from . import timetool

log = logging.getLogger(__name__)

identifier = None
host_uuid = None


def init():
    global identifier, host_uuid

    if identifier:
        raise Exception('hostidentifier.init called multiple times!')

    # In production we may have multiple instances of the application on the same server
    # so we need a way to identify each instance in the log file
    timestamp = int((timetool.unix_time() * 3000) % 2 ** 12)
    r = ''.join([random.choice('0123456789ABCDEF') for i in range(3)])
    identifier = '{:03X}-{}'.format(timestamp, r)

    print('This host is identified by {}'.format(identifier))

    host_uuid = uuid.uuid4()

    print('Host UUID: {}'.format(host_uuid))
