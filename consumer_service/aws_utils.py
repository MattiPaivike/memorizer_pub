import boto3
import os
from django_app.django_orm import initialize_django_postgres_database

def get_ssm_parameter(store_name: str = None):
    """
    Function to get SSM parameter from AWS
    if not SSM_PARAMETER environment variable is configured return False
    """
    if bool(int(os.getenv("LOCAL_EXECUTION", 0))) == False:
        ssm = boto3.client('ssm')
        parameter = ssm.get_parameter(Name=store_name, WithDecryption=True)
        result = parameter['Parameter']['Value']
        return result
    else:
        return True

def initialize_django_module() -> None:
    """
    The purpose of this function is to initialize Django submodule
    """
    if bool(int(os.getenv("LOCAL_EXECUTION", 0))) == False:
        os.environ["DB_HOST"] = get_ssm_parameter(os.getenv('DB_HOST_SSM_NAME'))
        os.environ["DB_PASS"] = get_ssm_parameter(os.getenv('DB_PASS_SSM_NAME'))
        os.environ["DB_USER"] = get_ssm_parameter(os.getenv('DB_USER_SSM_NAME'))
        os.environ["DB_NAME"] = get_ssm_parameter(os.getenv('DB_NAME_SSM_NAME'))

    initialize_django_postgres_database()
