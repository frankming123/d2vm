FROM {{ .Image }}

USER root

RUN dnf update -y && \
    dnf install -y kernel systemd NetworkManager e2fsprogs sudo passwd openssh-server openssh-clients \
    lvm2 tree bash-completion iputils iproute hostname && \
    dnf clean all && rm -rf /var/cache/dnf

RUN systemctl enable NetworkManager && \
    systemctl unmask systemd-remount-fs.service && \
    systemctl unmask getty.target && \
    systemd-machine-id-setup && \
    echo "blacklist pcspkr" > /etc/modprobe.d/blacklist-pcspkr.conf && \
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
