"""
This is a useful logger for debugging a specific problem, especially if you need to log
from multiple places (i.e. multiple instances of web app, celery workers) into the same
place, and your main log file is cluttered with junk!

This enables you to quickly and easily set up a log to the database, a file and stdout.
"""

import datetime
import logging

import sqlalchemy.exc
from sqlalchemy import BigInteger, Column, DateTime, String
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

from . import hostidentifier

_debug_log = None

FILENAME = None
DISABLE_FILE_LOGGING = False
BIND = None
DISABLE_DB_LOGGING = False
IDENTIFIER = None


class LogDatabaseHandler(logging.Handler):
    """
    Logger to log to database using SQLAlchemy model
    """
    def __init__(self, bind, table_name):
        super().__init__()

        Model = declarative_base(bind=bind)
        self.Session = sessionmaker(bind=bind)

        session = self.Session()

        class DebugLog(Model):
            __tablename__ = table_name
            id = Column(BigInteger, primary_key=True, nullable=False)
            timestamp = Column(DateTime, nullable=False)
            log_name = Column(String, nullable=False)
            level = Column(String, nullable=False)
            message = Column(String, nullable=False)

        self.Model = DebugLog

        # Create the table if it's missing
        try:
            self.Model.__table__.create()
        except sqlalchemy.exc.ProgrammingError:
            # Probably already exists so do nothing
            pass

        # Check that the table actually exists by trying to select from it
        try:
            session.query(self.Model).first()
        except Exception as e:
            raise Exception('Could not query from {}. Table creation probably failed!'.format(table_name), e)

    def emit(self, record):
        try:
            session = self.Session()

            log_record = self.Model(
                timestamp=datetime.datetime.fromtimestamp(record.created),
                log_name=record.name,
                level=record.levelname,
                message=record.msg
            )

            session.add(log_record)
            session.commit()
        except Exception:
            # Fall back on system logger
            log = logging.getLogger(__name__)
            log.exception('Error saving log message in database: {}'.format(record.msg))


def init_file_logging(filename):
    global FILENAME, _debug_log

    assert not _debug_log
    FILENAME = filename


def init_database_logging(engine_or_connection):
    global BIND, _debug_log

    assert not _debug_log
    BIND = engine_or_connection


def get_logger():
    global _debug_log, IDENTIFIER

    if _debug_log is None:
        _debug_log = logging.getLogger('dbg-{}'.format(hostidentifier.identifier))
        _debug_log.setLevel(logging.DEBUG)
        _debug_log.propagate = False

        date_format = '%Y-%m-%d %H:%M:%S'

        # Log to file
        if FILENAME is not None and not DISABLE_FILE_LOGGING:
            file_handler = logging.FileHandler(FILENAME)
            file_handler.setLevel(logging.DEBUG)
            _debug_log.addHandler(file_handler)

            _debug_log.info('')
            _debug_log.info('@' * 100)
            _debug_log.info('')
            _debug_log.info('-' * 100)
            _debug_log.info('Debug Log started {}'.format(datetime.datetime.utcnow()))
            _debug_log.info('-' * 100)

            file_handler.setFormatter(logging.Formatter('%(asctime)s %(message)s', date_format))

        # Log to DB
        if BIND is not None:
            db_handler = LogDatabaseHandler(BIND, '__debug_log')
            db_handler.setLevel(logging.INFO)
            _debug_log.addHandler(db_handler)

        # Log to stdout
        stream_handler = logging.StreamHandler()
        stream_handler.setFormatter(logging.Formatter('@@@ %(asctime)s %(message)s @@@', date_format))
        stream_handler.setLevel(logging.DEBUG)
        _debug_log.addHandler(stream_handler)

        # Done!
        _debug_log.info('Debug log configured with the following handlers: {}'.format(_debug_log.handlers))

    return _debug_log
