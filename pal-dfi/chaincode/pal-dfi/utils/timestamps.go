package utils

import "time"

func NowUTC() string {
	return time.Now().UTC().Format(time.RFC3339)
}

func ParseRFC3339(ts string) (time.Time, error) {
	return time.Parse(time.RFC3339, ts)
}
