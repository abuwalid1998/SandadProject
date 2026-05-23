package fabric

import (
	"crypto/x509"
	"log"
	"os"

	"github.com/hyperledger/fabric-gateway/pkg/client"
	"github.com/hyperledger/fabric-gateway/pkg/identity"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
)

func ConnectGateway() (*client.Gateway, error) {
	certPEM, err := os.ReadFile("/app/fabric-config/certs/user-cert.pem")
	if err != nil {
		return nil, err
	}

	keyPEM, err := os.ReadFile("/app/fabric-config/certs/user-key.pem")
	if err != nil {
		return nil, err
	}

	tlsPEM, err := os.ReadFile("/app/fabric-config/certs/tls-cert.pem")
	if err != nil {
		return nil, err
	}

	id, err := identity.NewX509Identity("PMAMSP", certPEM)
	if err != nil {
		return nil, err
	}

	privateKey, err := identity.PrivateKeyFromPEM(keyPEM)
	if err != nil {
		return nil, err
	}

	sign, err := identity.NewPrivateKeySign(privateKey)
	if err != nil {
		return nil, err
	}

	certPool := x509.NewCertPool()
	certPool.AppendCertsFromPEM(tlsPEM)

	creds := credentials.NewClientTLSFromCert(certPool, "peer0.pma.ps")

	conn, err := grpc.Dial(
		"peer0.pma.ps:7051",
		grpc.WithTransportCredentials(creds),
	)
	if err != nil {
		return nil, err
	}

	gateway, err := client.Connect(
		id,
		client.WithSign(sign),
		client.WithClientConnection(conn),
	)
	if err != nil {
		return nil, err
	}

	log.Println("Connected to Fabric Gateway")

	return gateway, nil
}
