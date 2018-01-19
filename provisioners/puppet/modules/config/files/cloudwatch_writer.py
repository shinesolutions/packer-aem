"""
CollectdCloudWatchPlugin plugin
"""
import collectd
import traceback

from cloudwatch.modules.configuration.confighelper import ConfigHelper
from cloudwatch.modules.flusher import Flusher
from cloudwatch.modules.logger.logger import get_logger
from cloudwatch.modules.collectd_integration.dataset import get_dataset_resolver


_LOGGER = get_logger(__name__)

def aws_init():
    """
    Collectd callback entry used to initialize plugin
    """
    config = ConfigHelper()
    flusher = Flusher(config_helper=config,  dataset_resolver=get_dataset_resolver())
    collectd.register_write(aws_write, data = flusher)
    _LOGGER.info('Initialization finished successfully.')

def aws_write(vl, flusher):
    """
    Collectd callback entry used to write metric data
    """
    flusher.add_metric(vl)

collectd.register_init(aws_init)
