package utils

import (
	"crypto/sha256"
	"encoding/hex"
)

func DeterministicID(parts ...string) string {
	h := sha256.New()

	for _, p := range parts {
		h.Write([]byte(p))
	}

	return hex.EncodeToString(h.Sum(nil))[:24]
}
