package test

import (
	"testing"
	"fmt"
	"time"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestNetworkSecurityGroupPerformance tests NSG with many rules
func TestNetworkSecurityGroupPerformance(t *testing.T) {
	t.Parallel()

	// Skip in CI/CD unless explicitly enabled
	if testing.Short() {
		t.Skip("Skipping performance test in short mode")
	}

	testCases := []struct {
		name          string
		ruleCount     int
		expectedTime  time.Duration
	}{
		{
			name:         "10Rules",
			ruleCount:    10,
			expectedTime: 5 * time.Minute,
		},
		{
			name:         "50Rules",
			ruleCount:    50,
			expectedTime: 10 * time.Minute,
		},
		{
			name:         "100Rules",
			ruleCount:    100,
			expectedTime: 15 * time.Minute,
		},
	}

	for _, tc := range testCases {
		tc := tc // Capture range variable
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()

			// Generate resources
			uniqueID := random.UniqueId()
			resourceGroupName := fmt.Sprintf("rg-perf-%s-%s", tc.name, uniqueID)
			location := GetAzureRegion(t)

			// Generate security rules
			securityRules := generateManySecurityRules(tc.ruleCount)

			// Configure Terraform
			terraformOptions := &terraform.Options{
				TerraformDir: "../../",
				Vars: map[string]interface{}{
					"name":                resourceGroupName,
					"resource_group_name": resourceGroupName,
					"location":           location,
					"security_rules":     securityRules,
					"tags":               GetDefaultTags(tc.name),
				},
			}

			defer terraform.Destroy(t, terraformOptions)

			// Measure deployment time
			start := time.Now()
			
			// Run terraform
			terraform.InitAndApply(t, terraformOptions)
			
			duration := time.Since(start)
			t.Logf("Deployment with %d rules took: %v", tc.ruleCount, duration)

			// Verify deployment succeeded
			nsgID := terraform.Output(t, terraformOptions, "id")
			assert.NotEmpty(t, nsgID)

			// Check if deployment was within expected time
			assert.LessOrEqual(t, duration, tc.expectedTime, 
				"Deployment should complete within %v but took %v", tc.expectedTime, duration)

			// Verify rule count
			securityRuleIDs := terraform.OutputMap(t, terraformOptions, "security_rule_ids")
			assert.Equal(t, tc.ruleCount, len(securityRuleIDs), 
				"Should have created %d rules", tc.ruleCount)
		})
	}
}

// TestNetworkSecurityGroupConcurrentDeployment tests concurrent NSG deployments
func TestNetworkSecurityGroupConcurrentDeployment(t *testing.T) {
	t.Parallel()

	// Skip in CI/CD unless explicitly enabled
	if testing.Short() {
		t.Skip("Skipping concurrent deployment test in short mode")
	}

	concurrentDeployments := 3
	results := make(chan bool, concurrentDeployments)

	for i := 0; i < concurrentDeployments; i++ {
		go func(index int) {
			// Generate unique resources
			uniqueID := random.UniqueId()
			resourceGroupName := fmt.Sprintf("rg-concurrent-%d-%s", index, uniqueID)
			location := GetAzureRegion(t)

			// Configure Terraform
			terraformOptions := &terraform.Options{
				TerraformDir: fmt.Sprintf("../../examples/basic"),
				Vars: map[string]interface{}{
					"resource_group_name": resourceGroupName,
					"location":           location,
					"name_suffix":        uniqueID,
				},
			}

			defer terraform.Destroy(t, terraformOptions)

			// Deploy
			err := terraform.InitAndApplyE(t, terraformOptions)
			results <- (err == nil)
		}(i)
	}

	// Wait for all deployments
	successCount := 0
	for i := 0; i < concurrentDeployments; i++ {
		if <-results {
			successCount++
		}
	}

	// All deployments should succeed
	assert.Equal(t, concurrentDeployments, successCount, 
		"All concurrent deployments should succeed")
}

// generateManySecurityRules creates many security rules for testing
func generateManySecurityRules(count int) map[string]interface{} {
	rules := make(map[string]interface{})
	
	// Common ports to cycle through
	ports := []string{"22", "80", "443", "3389", "1433", "3306", "5432", "6379", "27017", "9200"}
	protocols := []string{"Tcp", "Udp", "*"}
	
	for i := 0; i < count; i++ {
		ruleName := fmt.Sprintf("rule_%d", i)
		priority := 100 + i
		
		// Vary the rule configuration
		port := ports[i%len(ports)]
		protocol := protocols[i%len(protocols)]
		direction := "Inbound"
		if i%3 == 0 {
			direction = "Outbound"
		}
		
		rules[ruleName] = map[string]interface{}{
			"priority":                   priority,
			"direction":                  direction,
			"access":                     "Allow",
			"protocol":                   protocol,
			"source_port_range":          "*",
			"destination_port_range":     port,
			"source_address_prefix":      fmt.Sprintf("10.%d.0.0/16", i%256),
			"destination_address_prefix": "*",
			"description":                fmt.Sprintf("Test rule %d", i),
		}
	}
	
	return rules
}