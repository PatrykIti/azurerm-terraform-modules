output "serviceendpoint_ids" {
  description = "Map of service endpoint IDs grouped by type."
  value = try({
    argocd                      = { for key, endpoint in azuredevops_serviceendpoint_argocd.argocd : key => endpoint.id }
    artifactory                 = { for key, endpoint in azuredevops_serviceendpoint_artifactory.artifactory : key => endpoint.id }
    aws                         = { for key, endpoint in azuredevops_serviceendpoint_aws.aws : key => endpoint.id }
    azure_service_bus           = { for key, endpoint in azuredevops_serviceendpoint_azure_service_bus.azure_service_bus : key => endpoint.id }
    azurecr                     = { for key, endpoint in azuredevops_serviceendpoint_azurecr.azurecr : key => endpoint.id }
    azurerm                     = { for key, endpoint in azuredevops_serviceendpoint_azurerm.azurerm : key => endpoint.id }
    bitbucket                   = { for key, endpoint in azuredevops_serviceendpoint_bitbucket.bitbucket : key => endpoint.id }
    black_duck                  = { for key, endpoint in azuredevops_serviceendpoint_black_duck.black_duck : key => endpoint.id }
    checkmarx_one               = { for key, endpoint in azuredevops_serviceendpoint_checkmarx_one.checkmarx_one : key => endpoint.id }
    checkmarx_sast              = { for key, endpoint in azuredevops_serviceendpoint_checkmarx_sast.checkmarx_sast : key => endpoint.id }
    checkmarx_sca               = { for key, endpoint in azuredevops_serviceendpoint_checkmarx_sca.checkmarx_sca : key => endpoint.id }
    dockerregistry              = { for key, endpoint in azuredevops_serviceendpoint_dockerregistry.dockerregistry : key => endpoint.id }
    dynamics_lifecycle_services = { for key, endpoint in azuredevops_serviceendpoint_dynamics_lifecycle_services.dynamics_lifecycle_services : key => endpoint.id }
    externaltfs                 = { for key, endpoint in azuredevops_serviceendpoint_externaltfs.externaltfs : key => endpoint.id }
    gcp_terraform               = { for key, endpoint in azuredevops_serviceendpoint_gcp_terraform.gcp_terraform : key => endpoint.id }
    generic                     = { for key, endpoint in azuredevops_serviceendpoint_generic.generic : key => endpoint.id }
    generic_git                 = { for key, endpoint in azuredevops_serviceendpoint_generic_git.generic_git : key => endpoint.id }
    generic_v2                  = { for key, endpoint in azuredevops_serviceendpoint_generic_v2.generic_v2 : key => endpoint.id }
    github                      = { for key, endpoint in azuredevops_serviceendpoint_github.github : key => endpoint.id }
    github_enterprise           = { for key, endpoint in azuredevops_serviceendpoint_github_enterprise.github_enterprise : key => endpoint.id }
    gitlab                      = { for key, endpoint in azuredevops_serviceendpoint_gitlab.gitlab : key => endpoint.id }
    incomingwebhook             = { for key, endpoint in azuredevops_serviceendpoint_incomingwebhook.incomingwebhook : key => endpoint.id }
    jenkins                     = { for key, endpoint in azuredevops_serviceendpoint_jenkins.jenkins : key => endpoint.id }
    jfrog_artifactory_v2        = { for key, endpoint in azuredevops_serviceendpoint_jfrog_artifactory_v2.jfrog_artifactory_v2 : key => endpoint.id }
    jfrog_distribution_v2       = { for key, endpoint in azuredevops_serviceendpoint_jfrog_distribution_v2.jfrog_distribution_v2 : key => endpoint.id }
    jfrog_platform_v2           = { for key, endpoint in azuredevops_serviceendpoint_jfrog_platform_v2.jfrog_platform_v2 : key => endpoint.id }
    jfrog_xray_v2               = { for key, endpoint in azuredevops_serviceendpoint_jfrog_xray_v2.jfrog_xray_v2 : key => endpoint.id }
    kubernetes                  = { for key, endpoint in azuredevops_serviceendpoint_kubernetes.kubernetes : key => endpoint.id }
    maven                       = { for key, endpoint in azuredevops_serviceendpoint_maven.maven : key => endpoint.id }
    nexus                       = { for key, endpoint in azuredevops_serviceendpoint_nexus.nexus : key => endpoint.id }
    npm                         = { for key, endpoint in azuredevops_serviceendpoint_npm.npm : key => endpoint.id }
    nuget                       = { for key, endpoint in azuredevops_serviceendpoint_nuget.nuget : key => endpoint.id }
    octopusdeploy               = { for key, endpoint in azuredevops_serviceendpoint_octopusdeploy.octopusdeploy : key => endpoint.id }
    openshift                   = { for key, endpoint in azuredevops_serviceendpoint_openshift.openshift : key => endpoint.id }
    runpipeline                 = { for key, endpoint in azuredevops_serviceendpoint_runpipeline.runpipeline : key => endpoint.id }
    servicefabric               = { for key, endpoint in azuredevops_serviceendpoint_servicefabric.servicefabric : key => endpoint.id }
    snyk                        = { for key, endpoint in azuredevops_serviceendpoint_snyk.snyk : key => endpoint.id }
    sonarcloud                  = { for key, endpoint in azuredevops_serviceendpoint_sonarcloud.sonarcloud : key => endpoint.id }
    sonarqube                   = { for key, endpoint in azuredevops_serviceendpoint_sonarqube.sonarqube : key => endpoint.id }
    ssh                         = { for key, endpoint in azuredevops_serviceendpoint_ssh.ssh : key => endpoint.id }
    visualstudiomarketplace     = { for key, endpoint in azuredevops_serviceendpoint_visualstudiomarketplace.visualstudiomarketplace : key => endpoint.id }
    permissions                 = { for key, permission in azuredevops_serviceendpoint_permissions.permissions : key => permission.id }
  }, {})
}

output "serviceendpoint_names" {
  description = "Map of service endpoint names grouped by type."
  value = try({
    argocd                      = { for key, endpoint in azuredevops_serviceendpoint_argocd.argocd : key => endpoint.service_endpoint_name }
    artifactory                 = { for key, endpoint in azuredevops_serviceendpoint_artifactory.artifactory : key => endpoint.service_endpoint_name }
    aws                         = { for key, endpoint in azuredevops_serviceendpoint_aws.aws : key => endpoint.service_endpoint_name }
    azure_service_bus           = { for key, endpoint in azuredevops_serviceendpoint_azure_service_bus.azure_service_bus : key => endpoint.service_endpoint_name }
    azurecr                     = { for key, endpoint in azuredevops_serviceendpoint_azurecr.azurecr : key => endpoint.service_endpoint_name }
    azurerm                     = { for key, endpoint in azuredevops_serviceendpoint_azurerm.azurerm : key => endpoint.service_endpoint_name }
    bitbucket                   = { for key, endpoint in azuredevops_serviceendpoint_bitbucket.bitbucket : key => endpoint.service_endpoint_name }
    black_duck                  = { for key, endpoint in azuredevops_serviceendpoint_black_duck.black_duck : key => endpoint.service_endpoint_name }
    checkmarx_one               = { for key, endpoint in azuredevops_serviceendpoint_checkmarx_one.checkmarx_one : key => endpoint.service_endpoint_name }
    checkmarx_sast              = { for key, endpoint in azuredevops_serviceendpoint_checkmarx_sast.checkmarx_sast : key => endpoint.service_endpoint_name }
    checkmarx_sca               = { for key, endpoint in azuredevops_serviceendpoint_checkmarx_sca.checkmarx_sca : key => endpoint.service_endpoint_name }
    dockerregistry              = { for key, endpoint in azuredevops_serviceendpoint_dockerregistry.dockerregistry : key => endpoint.service_endpoint_name }
    dynamics_lifecycle_services = { for key, endpoint in azuredevops_serviceendpoint_dynamics_lifecycle_services.dynamics_lifecycle_services : key => endpoint.service_endpoint_name }
    externaltfs                 = { for key, endpoint in azuredevops_serviceendpoint_externaltfs.externaltfs : key => endpoint.service_endpoint_name }
    gcp_terraform               = { for key, endpoint in azuredevops_serviceendpoint_gcp_terraform.gcp_terraform : key => endpoint.service_endpoint_name }
    generic                     = { for key, endpoint in azuredevops_serviceendpoint_generic.generic : key => endpoint.service_endpoint_name }
    generic_git                 = { for key, endpoint in azuredevops_serviceendpoint_generic_git.generic_git : key => endpoint.service_endpoint_name }
    generic_v2                  = { for key, endpoint in azuredevops_serviceendpoint_generic_v2.generic_v2 : key => endpoint.name }
    github                      = { for key, endpoint in azuredevops_serviceendpoint_github.github : key => endpoint.service_endpoint_name }
    github_enterprise           = { for key, endpoint in azuredevops_serviceendpoint_github_enterprise.github_enterprise : key => endpoint.service_endpoint_name }
    gitlab                      = { for key, endpoint in azuredevops_serviceendpoint_gitlab.gitlab : key => endpoint.service_endpoint_name }
    incomingwebhook             = { for key, endpoint in azuredevops_serviceendpoint_incomingwebhook.incomingwebhook : key => endpoint.service_endpoint_name }
    jenkins                     = { for key, endpoint in azuredevops_serviceendpoint_jenkins.jenkins : key => endpoint.service_endpoint_name }
    jfrog_artifactory_v2        = { for key, endpoint in azuredevops_serviceendpoint_jfrog_artifactory_v2.jfrog_artifactory_v2 : key => endpoint.service_endpoint_name }
    jfrog_distribution_v2       = { for key, endpoint in azuredevops_serviceendpoint_jfrog_distribution_v2.jfrog_distribution_v2 : key => endpoint.service_endpoint_name }
    jfrog_platform_v2           = { for key, endpoint in azuredevops_serviceendpoint_jfrog_platform_v2.jfrog_platform_v2 : key => endpoint.service_endpoint_name }
    jfrog_xray_v2               = { for key, endpoint in azuredevops_serviceendpoint_jfrog_xray_v2.jfrog_xray_v2 : key => endpoint.service_endpoint_name }
    kubernetes                  = { for key, endpoint in azuredevops_serviceendpoint_kubernetes.kubernetes : key => endpoint.service_endpoint_name }
    maven                       = { for key, endpoint in azuredevops_serviceendpoint_maven.maven : key => endpoint.service_endpoint_name }
    nexus                       = { for key, endpoint in azuredevops_serviceendpoint_nexus.nexus : key => endpoint.service_endpoint_name }
    npm                         = { for key, endpoint in azuredevops_serviceendpoint_npm.npm : key => endpoint.service_endpoint_name }
    nuget                       = { for key, endpoint in azuredevops_serviceendpoint_nuget.nuget : key => endpoint.service_endpoint_name }
    octopusdeploy               = { for key, endpoint in azuredevops_serviceendpoint_octopusdeploy.octopusdeploy : key => endpoint.service_endpoint_name }
    openshift                   = { for key, endpoint in azuredevops_serviceendpoint_openshift.openshift : key => endpoint.service_endpoint_name }
    runpipeline                 = { for key, endpoint in azuredevops_serviceendpoint_runpipeline.runpipeline : key => endpoint.service_endpoint_name }
    servicefabric               = { for key, endpoint in azuredevops_serviceendpoint_servicefabric.servicefabric : key => endpoint.service_endpoint_name }
    snyk                        = { for key, endpoint in azuredevops_serviceendpoint_snyk.snyk : key => endpoint.service_endpoint_name }
    sonarcloud                  = { for key, endpoint in azuredevops_serviceendpoint_sonarcloud.sonarcloud : key => endpoint.service_endpoint_name }
    sonarqube                   = { for key, endpoint in azuredevops_serviceendpoint_sonarqube.sonarqube : key => endpoint.service_endpoint_name }
    ssh                         = { for key, endpoint in azuredevops_serviceendpoint_ssh.ssh : key => endpoint.service_endpoint_name }
    visualstudiomarketplace     = { for key, endpoint in azuredevops_serviceendpoint_visualstudiomarketplace.visualstudiomarketplace : key => endpoint.service_endpoint_name }
  }, {})
}
