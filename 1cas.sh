#!/bin/bash



mkdir kasy22_ca/
cd kasy22_ca
mkdir certs crl newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial
pwd

#cp /etc/ssl/openssl.cnf ./
cp /home/student/kvpn/openssl.cnf .

mkdir ca1
cd ca1
mkdir certs crl newcerts private csr
chmod 700 private
touch index.txt
echo 2000 > serial
echo 2000 > crlnumber
pwd
ls
cp /home/student/kvpn/openssl.cnf.ca1 ./openssl.cnf
cd ..