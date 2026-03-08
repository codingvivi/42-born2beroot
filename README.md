*This project has been created as part of the 42 curriculum by lrain.*

# Born2beRoot

## Description

Born2beRoot is a system administration project from the 42 curriculum. The goal is to set up a secure Linux server inside a virtual machine, following strict configuration rules with no graphical interface. The project covers partitioning with encrypted LVM, SSH hardening, firewall configuration, password policies, sudo restrictions, and a monitoring script that broadcasts system information to all terminals every 10 minutes.

## Instructions

### Evaluation
To evaluate my project (or one using my folder structure):
+ Create a parent folder, or just use the root of this cloned repository as one.
+ Inside the parent folder, create a folder for the vm files:
   ```sh
   mkdir -p vm 
   ```
+ Get the vm files from me, or place them into the `vm/` folder. The `.vdi` goes directly into it's root, as does the data folder Virtualbox creates
+ Clone the submission repository from the 42 server into a subfolder of your choice:
   ```sh
   cd ../
   git clone <42-server-repo-url> <subfolder-name>
   ```
+ From the subfolder root, verify the disk signature:
   ```sh
   cd <subfolder-name>
   shasum -c Signature.txt
   ```

### Building a submittable release

Mirroring my build environment requires:
- [`just`](https://github.com/casey/just)
- [`nushell`](https://www.nushell.sh/)
- [`gh`](https://cli.github.com/)

For an overview of all my `just` recipes simply run
```sh
   just
```

Creating a version to be submitted consists creating a git tag first
```sh
   git tag <tag> -m "description"
```
and then running
```sh
just build-dist
```
This will
+ create the signature
+ copy it and the readme into an isolated folder, suitable to be used as a folder to push the project submission from
+ check if the checksum in it is valid
+ create a `tar.gz` of the submission files and move them to the `dist/` folder
+ create the for the evaluation allowed snapshot of the current vm's state named after the current git tag
+ sync my notes (since techincally they are part of this repo's `source code` which is included in github releases)

If the build completes successfully,
the tar and the rest of the tracked repo files can be published to github
via
```sh
   just publish      
```

### Requirements

- [VirtualBox](https://www.virtualbox.org/) )

### Setup
## Comparisons

### Debian vs Rocky Linux

| | Debian | Rocky Linux |
|---|---|---|
| Base | Independent | RHEL-compatible |
| Package manager | apt / aptitude | dnf |
| MAC system | AppArmor | SELinux |
| Firewall frontend | UFW | firewalld |
| Default init | systemd | systemd |
| Target use | General purpose / servers | Enterprise servers |
| Learning curve | Lower | Higher |
| Community size | Very large | Smaller but growing |

Debian is more beginner-friendly and better documented for general use. Rocky Linux is closer to what you find in enterprise and cloud environments, and it enforces stricter security defaults out of the box.

### AppArmor vs SELinux
### UFW vs firewalld

### VirtualBox vs UTM

## Resources

### AI Usage


