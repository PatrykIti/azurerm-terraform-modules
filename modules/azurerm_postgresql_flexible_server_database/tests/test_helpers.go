package test

import (
	"strconv"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

// OutputBool reads a Terraform output and parses it as a boolean.
func OutputBool(t testing.TB, terraformOptions *terraform.Options, name string) bool {
	value := terraform.Output(t, terraformOptions, name)
	parsed, err := strconv.ParseBool(strings.TrimSpace(value))
	require.NoError(t, err, "Failed to parse output %q as bool", name)
	return parsed
}
