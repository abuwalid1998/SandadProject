package services

import (
	"bytes"
	"os/exec"
	"strings"

	"pal-dfi-monitor/models"
)

func ListContainers() ([]models.ContainerInfo, error) {
	cmd := exec.Command(
		"docker",
		"ps",
		"-a",
		"--format",
		"{{.Names}}|{{.Status}}",
	)

	var out bytes.Buffer
	cmd.Stdout = &out

	err := cmd.Run()
	if err != nil {
		return nil, err
	}

	lines := strings.Split(out.String(), "\n")

	var result []models.ContainerInfo

	for _, line := range lines {
		if strings.TrimSpace(line) == "" {
			continue
		}

		parts := strings.Split(line, "|")

		if len(parts) < 2 {
			continue
		}

		result = append(result, models.ContainerInfo{
			Name:    parts[0],
			Status:  parts[1],
			CPU:     "N/A",
			Memory:  "N/A",
			Restart: 0,
		})
	}

	return result, nil
}
