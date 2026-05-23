package models

type ContainerInfo struct {
	Name    string `json:"name"`
	Status  string `json:"status"`
	CPU     string `json:"cpu"`
	Memory  string `json:"memory"`
	Restart int    `json:"restart"`
}
