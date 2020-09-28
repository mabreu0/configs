export myvm="Ubunt"

# SSHD #
VBoxManage modifyvm "Ubunt" --natpf1 "$myvm-SSH,tcp,,2022,,22"

# MYSQL #
VBoxManage modifyvm "Ubunt" --natpf1 "$myvm-MYSQL,tcp,,23306,,3306"

# APACHE #
VBoxManage modifyvm "Ubunt" --natpf1 "$myvm-APACHE,tcp,,2080,,80"

# REACT #
VBoxManage modifyvm "Ubunt" --natpf1 "$myvm-REACT,tcp,,23000,,3000"

# ORACLE #
VBoxManage modifyvm "Ubunt" --natpf1 "$myvm-ORACLE,tcp,,21551,,1551"

# TOMCAT #
VBoxManage modifyvm "Ubunt" --natpf1 "$myvm-TOMCAT,tcp,,28080,,8080"
