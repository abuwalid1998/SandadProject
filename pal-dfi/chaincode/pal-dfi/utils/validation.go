package utils

import (
	"fmt"
	"strings"
)

func RequireNonEmpty(fieldName, value string) error {
	if strings.TrimSpace(value) == "" {
		return fmt.Errorf("%s is required", fieldName)
	}
	return nil
}

func RequireAllowedValue(fieldName, value string, allowed []string) error {
	for _, v := range allowed {
		if value == v {
			return nil
		}
	}
	return fmt.Errorf("%s has invalid value: %s", fieldName, value)
}
