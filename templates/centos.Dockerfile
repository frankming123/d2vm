FROM {{ .Image }}

USER root

{{ if .MirrorRepo }}
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl={{ .MirrorRepo }}|g' /etc/yum.repos.d/CentOS-*
{{ end }}

RUN yum update -y && yum install -y kernel systemd NetworkManager e2fsprogs sudo && \
    yum clean all && rm -rf /var/cache/yum /var/lib/yum

RUN systemctl enable NetworkManager && \
    systemctl unmask systemd-remount-fs.service && \
    systemctl unmask getty.target && \
    cd /boot && \
    ln -s $(find . -name 'vmlinuz-*') vmlinuz && \
    ln -s $(find . -name 'initramfs-*.img') initrd.img

{{ if .Luks }}
RUN yum install -y cryptsetup && \
    dracut --no-hostonly --regenerate-all --force --install="/usr/sbin/cryptsetup"
{{ else }}
RUN dracut --no-hostonly --regenerate-all --force
{{ end }}

{{ if .Password }}RUN echo "root:{{ .Password }}" | chpasswd {{ end }}
