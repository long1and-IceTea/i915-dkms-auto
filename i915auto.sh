#!/bin/bash

# 更新系统
apt update
apt dist-upgrade -y

# 安装 Proxmox VE 内核头文件
apt-get install -y pve-headers-$(uname -r)

# 克隆 i915-sriov-dkms 存储库
git clone https://github.com/strongtz/i915-sriov-dkms.git
cd i915-sriov-dkms

# 修改 dkms.conf 文件
sed -i '1s/.*/PACKAGE_NAME="i915-sriov-dkms"/; 2s/.*/PACKAGE_VERSION="6.2"/' dkms.conf

# 复制文件到 /usr/src
cp -r /root/i915-sriov-dkms/ /usr/src/i915-sriov-dkms-6.2 
cd /usr/src/i915-sriov-dkms-6.2

# 安装 i915-sriov-dkms 模块
dkms install -m i915-sriov-dkms -v 6.2 --force

# 显示已安装的模块状态
dkms status

# 修改 GRUB 配置
sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on i915.enable_guc=3 i915.max_vfs=7"/' /etc/default/grub

# 将 vfio 模块添加到 /etc/modules
echo -e "vfio\nvfio_iommu_type1\nvfio_pci\nvfio_virqfd" | sudo tee -a /etc/modules

# 更新 GRUB 配置
update-grub

# 更新 initramfs
update-initramfs -u

# 安装 sysfsutils
apt install -y sysfsutils

# 配置 sriov_numvfs
read -p "请输入你需要几个vGPU： " numvfs
echo "devices/pci0000:00/0000:00:02.0/sriov_numvfs = $numvfs" | sudo tee /etc/sysfs.conf

echo "请重启"
