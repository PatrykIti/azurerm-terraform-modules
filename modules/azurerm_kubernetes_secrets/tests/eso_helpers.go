package test

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

const defaultESOCRDURL = "https://raw.githubusercontent.com/external-secrets/external-secrets/main/deploy/crds/bundle.yaml"

func ensureESOCRDs(t testing.TB, terraformOptions *terraform.Options) {
	kubeconfigPath := writeTempKubeconfig(t, terraformOptions)
	defer os.Remove(kubeconfigPath)

	if esoCRDsPresent(kubeconfigPath) {
		return
	}

	if !commandExists("kubectl") {
		t.Skip("kubectl not found; install ESO CRDs manually or add kubectl to PATH")
	}

	crdURL := os.Getenv("ESO_CRD_URL")
	if crdURL == "" {
		crdURL = defaultESOCRDURL
	}

	err := runCommandCheck(kubeconfigPath, "kubectl", "apply", "--server-side", "--field-manager=terratest-eso", "-f", crdURL)
	if err != nil {
		if strings.Contains(err.Error(), "unknown flag: --server-side") {
			t.Skip("kubectl is too old for server-side apply; upgrade kubectl to install ESO CRDs automatically")
		}
		require.NoError(t, err)
	}
	waitForCRD(t, kubeconfigPath, "secretstores.external-secrets.io")
	waitForCRD(t, kubeconfigPath, "externalsecrets.external-secrets.io")
}

func writeTempKubeconfig(t testing.TB, terraformOptions *terraform.Options) string {
	kubeconfig := terraform.Output(t, terraformOptions, "kube_config_raw")
	require.NotEmpty(t, kubeconfig, "kube_config_raw output is empty")

	file, err := os.CreateTemp("", "kubeconfig-*")
	require.NoError(t, err)
	require.NoError(t, os.WriteFile(file.Name(), []byte(kubeconfig), 0600))
	require.NoError(t, file.Close())

	return file.Name()
}

func esoCRDsPresent(kubeconfigPath string) bool {
	if !commandExists("kubectl") {
		return false
	}
	if err := runCommandCheck(kubeconfigPath, "kubectl", "get", "crd", "secretstores.external-secrets.io"); err != nil {
		return false
	}
	if err := runCommandCheck(kubeconfigPath, "kubectl", "get", "crd", "externalsecrets.external-secrets.io"); err != nil {
		return false
	}
	return true
}

func waitForCRD(t testing.TB, kubeconfigPath, crd string) {
	runCommand(t, kubeconfigPath, "kubectl", "wait", "--for=condition=Established", "--timeout=120s", "crd/"+crd)
}

func commandExists(name string) bool {
	_, err := exec.LookPath(name)
	return err == nil
}

func runCommand(t testing.TB, kubeconfigPath string, name string, args ...string) {
	cmd := exec.Command(name, args...)
	cmd.Env = append(os.Environ(), "KUBECONFIG="+kubeconfigPath)
	output, err := cmd.CombinedOutput()
	require.NoError(t, err, "command failed: %s %s\n%s", name, strings.Join(args, " "), strings.TrimSpace(string(output)))
}

func runCommandCheck(kubeconfigPath string, name string, args ...string) error {
	cmd := exec.Command(name, args...)
	cmd.Env = append(os.Environ(), "KUBECONFIG="+kubeconfigPath)
	output, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("%s %s: %w: %s", name, strings.Join(args, " "), err, strings.TrimSpace(string(output)))
	}
	return nil
}
