#!/bin/bash

peer chaincode invoke \
-o localhost:7050 \
--tls \
--cafile $ORDERER_CA \
-C palidentitychannel \
-n paldfi \
-c '{"Args":["RegisterIssuer","PMA","Palestine Monetary Authority","PMAMSP","REGULATOR"]}'