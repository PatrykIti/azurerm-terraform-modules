from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck
from checkov.common.models.enums import CheckCategories, CheckResult


class VirtualNetworkDDoSProtection(BaseResourceCheck):
    def __init__(self):
        """
        Custom check to ensure Virtual Network has DDoS protection plan configured
        for production environments
        """
        name = "Ensure Virtual Network has DDoS protection for production environments"
        id = "CKV_AZURE_CUSTOM_3"
        supported_resources = ["azurerm_virtual_network"]
        categories = [CheckCategories.NETWORKING]
        super().__init__(name=name, id=id, categories=categories, supported_resources=supported_resources)

    def scan_resource_conf(self, conf, entity_type=None):
        """
        Looks for DDoS protection configuration in production virtual networks
        :param conf: azurerm_virtual_network configuration
        :return: CheckResult
        """
        # Check if tags indicate production environment
        if "tags" in conf and isinstance(conf["tags"], list) and len(conf["tags"]) > 0:
            tags = conf["tags"][0]
            
            # Check if this is a production environment
            env_tag = tags.get("Environment", "").lower() if isinstance(tags, dict) else ""
            
            if env_tag in ["production", "prod", "prd"]:
                # For production, DDoS protection should be enabled
                if "ddos_protection_plan" in conf:
                    ddos_config = conf["ddos_protection_plan"][0] if isinstance(conf["ddos_protection_plan"], list) else conf["ddos_protection_plan"]
                    
                    if isinstance(ddos_config, dict):
                        # Check if DDoS protection is enabled
                        if ddos_config.get("enable", [False])[0] if isinstance(ddos_config.get("enable", False), list) else ddos_config.get("enable", False):
                            # Check if ID is provided
                            if "id" in ddos_config and ddos_config["id"]:
                                return CheckResult.PASSED
                            else:
                                self.details.append("DDoS protection is enabled but no DDoS protection plan ID is specified")
                                return CheckResult.FAILED
                        else:
                            self.details.append("DDoS protection is disabled for production environment")
                            return CheckResult.FAILED
                else:
                    self.details.append("No DDoS protection configuration found for production environment")
                    return CheckResult.FAILED
            else:
                # For non-production environments, DDoS protection is optional
                return CheckResult.PASSED
        
        # If no tags or environment tag, pass the check (assume non-production)
        return CheckResult.PASSED


check = VirtualNetworkDDoSProtection()