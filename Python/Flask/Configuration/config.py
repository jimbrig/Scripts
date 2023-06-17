import os
import secrets

from dotenv import load_dotenv

load_dotenv()

basedir = os.path.abspath(os.path.dirname(__file__))

def as_bool(value):
    if value:
        return value.lower() in ["true", "yes", "on", "t", "1"]
    return False


def generate_secret_key():
    return secrets.token_urlsafe(16)


class Config:
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or \
        'sqlite:///' + os.path.join(basedir, 'app.db')
    SQLALCHEMY_TRACK_MODIFICATIONS = as_bool(os.environ.get('SQLALCHEMY_TRACK_MODIFICATIONS')) # noqa

    SECRET_KEY = os.environ.get('SECRET_KEY', generate_secret_key())
    DISABLE_AUTH = as_bool(os.environ.get('DISABLE_AUTH'))
    PASSWORD_RESET_URL = os.environ.get('PASSWORD_RESET_URL') or \
        'http://localhost:5000/reset-password'
    USE_CORS = as_bool(os.environ.get('USE_CORS') or 'yes')
    CORS_SUPPORTS_CREDENTIALS = True

    API_TITLE = os.environ.get('API_TITLE') or 'Flask-GridJS'
    API_VERSION = os.environ.get('API_VERSION') or '1.0.0'
    API_UI = os.environ.get('API_UI') or 'swagger'
    API_TAGS = os.environ.get('API_TAGS') or [{'name': 'users', 'description': 'Users operations'}] # noqa


