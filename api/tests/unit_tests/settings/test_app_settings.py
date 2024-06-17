import pytest
from flask import Flask

from config import Config
from configs.app_configs import DifyConfigs


def test_dify_configs_undefined_entry():
    # load dotenv file with pydantic-settings
    settings = DifyConfigs()

    # entries not defined in app settings
    with pytest.raises(TypeError):
        # TypeError: 'AppSettings' object is not subscriptable
        assert settings['LOG_LEVEL'] == 'INFO'


def test_dify_configs():
    # load dotenv file with pydantic-settings
    settings = DifyConfigs()

    # constant values
    assert settings.COMMIT_SHA == ''

    # default values
    assert settings.EDITION == 'SELF_HOSTED'
    assert settings.API_COMPRESSION_ENABLED is False


def test_flask_configs():
    flask_app = Flask('app')
    flask_app.config.from_object(Config())
    flask_app.config.from_mapping(DifyConfigs().dict())
    config = flask_app.config

    # configs read from dotenv directly
    assert config['LOG_LEVEL'] == 'INFO'

    # configs read from pydantic-settings
    assert config['COMMIT_SHA'] == ''
    assert config['EDITION'] == 'SELF_HOSTED'
    assert config['API_COMPRESSION_ENABLED'] is False

    assert config['CONSOLE_API_URL'] == 'https://cloud.dify.ai'
    # fallback to alias choices value as CONSOLE_API_URL
    assert config['FILES_URL'] == 'https://cloud.dify.ai'
