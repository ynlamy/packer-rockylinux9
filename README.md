# packer-rockylinux9

Creating a virtual machine template under [Rocky Linux 9](https://rockylinux.org/) from ISO file with [Packer](https://www.packer.io/) using [VMware Workstation](https://www.vmware.com/). 

This was created by Yoann LAMY under the terms of the [GNU General Public License v3](http://www.gnu.org/licenses/gpl.html).

### Usage

This virtual machine template must be builded using Packer.

- ``cd packer-rockylinux9``
- ``packer init vmware-iso-rockylinux9.pkr.hcl``
- ``packer build vmware-iso-rockylinux9.pkr.hcl``
 
