#!/bin/bash 
source ~/.bashrc

echo "[G1N1]" >> ~/.locator.ini
echo "HOST=${GOLDILOCKS_HOST1}" >> ~/.locator.ini
echo "PORT=22581" >> ~/.locator.ini
echo "" >> ~/.locator.ini

echo "[G2N1]" >> ~/.locator.ini
echo "HOST=${GOLDILOCKS_HOST2}" >> ~/.locator.ini
echo "PORT=22581" >> ~/.locator.ini
echo "" >> ~/.locator.ini

echo "[G3N1]" >> ~/.locator.ini
echo "HOST=${GOLDILOCKS_HOST3}" >> ~/.locator.ini
echo "PORT=22581" >> ~/.locator.ini
echo "" >> ~/.locator.ini

echo "[G4N1]" >> ~/.locator.ini
echo "HOST=${GOLDILOCKS_HOST4}" >> ~/.locator.ini
echo "PORT=22581" >> ~/.locator.ini
echo "" >> ~/.locator.ini

echo "[G1N2]" >> ~/.locator.ini
echo "HOST=${GOLDILOCKS_HOST5}" >> ~/.locator.ini
echo "PORT=22581" >> ~/.locator.ini
echo "" >> ~/.locator.ini

echo "[G2N2]" >> ~/.locator.ini
echo "HOST=${GOLDILOCKS_HOST6}" >> ~/.locator.ini
echo "PORT=22581" >> ~/.locator.ini
echo "" >> ~/.locator.ini

echo "[G3N2]" >> ~/.locator.ini
echo "HOST=${GOLDILOCKS_HOST7}" >> ~/.locator.ini
echo "PORT=22581" >> ~/.locator.ini
echo "" >> ~/.locator.ini

echo "[G4N2]" >> ~/.locator.ini
echo "HOST=${GOLDILOCKS_HOST8}" >> ~/.locator.ini
echo "PORT=22581" >> ~/.locator.ini
echo "" >> ~/.locator.ini


echo "[GOLDILOCKS]" >> ~/.odbc.ini
echo "HOST=${GOLDILOCKS_HOST1}" >> ~/.odbc.ini
echo "PORT=22581" >> ~/.odbc.ini
echo "LOCALITY_AWARE_TRANSACTION=1" >> ~/.odbc.ini
echo "LOCATOR_DSN = LOCATOR" >> ~/.odbc.ini
echo "" >> ~/.odbc.ini

echo "[LOCATOR]" >> ~/.odbc.ini
echo "FILE=/home/sunje/.locator.ini" >> ~/.odbc.ini

/home/sunje/goldilocks_standard_v1.2/Runner -t g -o i -s 1 -e 10000 

tail -f /dev/null
