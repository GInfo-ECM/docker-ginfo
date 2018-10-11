#!/bin/bash

rm -f /etc/ppp/chap-secrets
echo "$USERNAME    *           $PASSWORD    *" >> /etc/ppp/chap-secrets

pptpd --fg