"""Update node with exhaustive info."""
from oslo_config import cfg
from ironic_inspector.common.i18n import _
from ironic_inspector.plugins import base

EX_DISCOVERY_OPTS = [
    cfg.StrOpt('ipmi_username',
               default=None,
               help=_('The username of baremetal node\'s ipmi.')),
    cfg.StrOpt('ipmi_password',
               default=None,
               help=_('The password of baremetal node\'s ipmi.')),
    cfg.StrOpt('deploy_kernel',
               default=None,
               help=_('The path of kernel for deploying node.')),
    cfg.StrOpt('deploy_ramdisk',
               default=None,
               help=_('The path of ramdisk for deploying node.')),
]


def list_opts():
    return [
        ('discovery', EX_DISCOVERY_OPTS)
    ]


CONF = cfg.CONF
CONF.register_opts(EX_DISCOVERY_OPTS, group='discovery')


class ExhaustiveDiscoveryHook(base.ProcessingHook):
    """Processing hook for saving node's exhaustive information."""

    def _update_lack_driver_info(self, introspection_data):
        lack_info = {}
        lack_info['/driver_info/ipmi_username'] = CONF.discovery.ipmi_username
        lack_info['/driver_info/ipmi_password'] = CONF.discovery.ipmi_password
        lack_info['/driver_info/deploy_kernel'] = CONF.discovery.deploy_kernel
        lack_info['/driver_info/deploy_ramdisk'] = CONF.discovery.deploy_ramdisk
        return lack_info

    def _update_lack_extra(self, introspection_data):
        lack_info = {}
        lack_info['/extra/serial_number'] = \
            introspection_data.get('inventory').get('system_vendor').get('serial_number')
        lack_info['/extra/vendor'] = \
            introspection_data.get('inventory').get('system_vendor').get('manufacturer')
        lack_info['/extra/product_name'] = \
            introspection_data.get('inventory').get('system_vendor').get('product_name')
        lack_info['/extra/nic_detailed'] = \
            introspection_data.get('inventory').get('interfaces')
        lack_info['/extra/cpu_detailed'] = introspection_data.get('inventory').get('cpu')
        lack_info['/extra/mem_detailed'] = introspection_data.get('inventory').get('memory')
        lack_info['/extra/disk_detailed'] = introspection_data.get('inventory').get('disks')
        lack_info['/extra/boot_detailed'] = introspection_data.get('inventory').get('boot')
        lack_info['/extra/physical_disks'] = introspection_data.get('inventory').get('pdisks')
        lack_info['/extra/virtual_drives'] = introspection_data.get('inventory').get('virtual_drives')
        lack_info['/extra/processors'] = introspection_data.get('inventory').get('processors')
        lack_info['/extra/memory_cards'] = introspection_data.get('inventory').get('memory_cards')
        lack_info['/extra/lldp_extra_info'] = introspection_data.get('inventory').get('lldp_extra_info')
        return lack_info

    def before_update(self, introspection_data, node_info, **kwargs):
        props = {}
        lack_driver_info = self._update_lack_driver_info(introspection_data)
        props.update(lack_driver_info)
        lack_extra = self._update_lack_extra(introspection_data)
        props.update(lack_extra)
        patches = [{'op': 'add', 'path': '%s' % k, 'value': v}
                   for k, v in props.items()]
        node_info.patch(patches)
