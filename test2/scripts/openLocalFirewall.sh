firewall-cmd --zone=trusted --add-source=192.168.100.0/24
echo "192.168.100.68  controller100.k8s.local" >> /etc/hosts
echo "192.168.100.158 worker100.k8s.local" >> /etc/hosts
