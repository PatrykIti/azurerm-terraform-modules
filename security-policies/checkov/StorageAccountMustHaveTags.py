from checkov.terraform.checks.resource.base_resource_value_check import BaseResourceValueCheck
from checkov.common.models.enums import CheckCategories, CheckResult


class StorageAccountMustHaveTags(BaseResourceValueCheck):
    def __init__(self):
        """
        Custom check to ensure all storage accounts have required tags for compliance
        """
        name = "Ensure Storage Account has required compliance tags"
        id = "CKV_AZURE_CUSTOM_1"
        supported_resources = ["azurerm_storage_account"]
        categories = [CheckCategories.GENERAL_SECURITY]
        super().__init__(name=name, id=id, categories=categories, supported_resources=supported_resources)

    def scan_resource_conf(self, conf):
        """
        Looks for required tags in storage account configuration
        :param conf: azurerm_storage_account configuration
        :return: CheckResult
        """
        # Required tags for compliance
        required_tags = ["Environment", "Owner", "CostCenter", "DataClassification"]
        
        if "tags" in conf:
            tags = conf["tags"][0] if isinstance(conf["tags"], list) else conf["tags"]
            
            # Check if all required tags are present
            missing_tags = []
            for required_tag in required_tags:
                if required_tag not in tags:
                    missing_tags.append(required_tag)
            
            if not missing_tags:
                return CheckResult.PASSED
            else:
                self.details.append(f"Missing required tags: {', '.join(missing_tags)}")
                return CheckResult.FAILED
        
        self.details.append("No tags defined for storage account")
        return CheckResult.FAILED


check = StorageAccountMustHaveTags()