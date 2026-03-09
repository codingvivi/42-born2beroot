*This project has been created as part of the 42 curriculum by lrain.*

# Born2beRoot

## Description

This is my go at the born2beroot project
at 42.
It tasked me with setting up either
Debian
or Rocky,
as a GUIless server,
the latter of which I ended up picking.
Besides setting up the machine,
a firewall
and ssh,
the project required user creation
and setting password policy,
all per some pretty specific instructions.

## Instructions

### Evaluation

This project uses [VirtualBox](https://www.virtualbox.org/).

To evaluate my project (or one using my folder structure):

- Create a parent folder,
  or just use the root of this cloned repository as one.
- Inside the parent folder,
  create a folder for the vm files:
  ```sh
  mkdir -p vm 
  ```
- Get the vm files from me,
  or place them into the `vm/` folder.
  The `.vdi` goes directly into its root,
  as does the data folder Virtualbox creates
- Clone the submission repository from the 42 server into a subfolder of your choice:
  ```sh
  cd ../
  git clone <42-server-repo-url> <subfolder-name>
  ```
- From the subfolder root, verify the disk signature:
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

- create the signature
- copy it and the readme into an isolated folder,
  suitable to be used as a folder to push the project submission from
- check if the checksum in it is valid
- create a `tar.gz` of the submission files and move them to the `dist/` folder
- create the for the evaluation allowed snapshot of the current vm’s state named after the current git tag
- sync my notes (since techincally they are part of this repo’s `source code` which is included in github releases)

If the build completes successfully,
the tar and the rest of the tracked repo files can be published to github via

```sh
   just publish      
```

## Project description

### Project specifics

### Comparisons

#### Debian vs Rocky Linux

| | Debian | Rocky Linux |
| --- | --- | --- |
| Base | Independent | RHEL-compatible |
| Package manager | apt / aptitude | dnf |
| MAC system | AppArmor | SELinux |
| Firewall frontend | UFW | firewalld |
| Default init | systemd | systemd |
| Learning curve | Lower | Higher |
| Learning auditing| Easier | Harder |
| Community size | Very large | Smaller but growing |

Debian is more beginner-friendly and better documented for general use.
Rocky Linux is closer to what you find in enterprise and cloud environments,
and it enforces stricter security defaults out of the box.

#### AppArmor vs SELinux

| | AppArmor | SELinux |
| --- | --- | --- |
| Model | Path-based | Label-based |
| Default on | Debian, Ubuntu | RHEL, Rocky Linux |
| Configuration | Profiles per application | Policies with context labels |
| Complexity | Lower | Higher |
| Granularity | Per-path | Per-object (file, process, port) |
| Enforcement modes | enforce / complain | enforcing / permissive / disabled |

Both are mandatory access control (MAC) systems
that restrict what processes can do,
even if they run as root.
AppArmor is simpler to configure:
profiles define what paths a program may access.
SELinux is more granular and harder to configure,
attaching security labels to every object on the system
and enforcing policy based on those labels rather than file paths.
This makes SELinux more powerful but also harder to debug when something is denied.

#### UFW vs firewalld

| | UFW | firewalld |
| --- | --- | --- |
| Default on | Debian, Ubuntu | RHEL, Rocky Linux, OpenSUSE |
| Backend | iptables / nftables | nftables (iptables legacy available) |
| Configuration model | Static host-based rules | Dynamic zone-based trust levels |
| Runtime changes | Requires reload | Applied live without reload |
| Config separation | Single approach | Runtime vs permanent |
| D-Bus integration | No | Yes |
| Complexity | Lower | Higher |
| Best suited for | Single machines | Enterprise / multi-zone networks |

Both are frontends for managing the kernel's packet filtering rules.
UFW is designed as a host-based firewall frontend:
it defaults to denying incoming and allowing outgoing traffic,
and rules are added with simple commands like `ufw allow ssh/tcp`.
firewalld uses a zone-based model,
where each zone defines a level of trust for a network connection.
Interfaces and sources are assigned to zones,
and firewalld can switch zones automatically via Network Manager.
Unlike UFW, firewalld separates runtime rules from permanent ones —
runtime changes take effect immediately but are lost on reload,
while permanent changes require an explicit `--permanent` flag
and only apply after a reload.
A `firewall-cmd --reload` preserves existing connections,
whereas `--complete-reload` resets all state.

#### VirtualBox vs UTM

| | VirtualBox | UTM |
| --- | --- | --- |
| Developer | Oracle | open source, by Turing Software |
| Platform | Windows, macOS, Linux | macOS only |
| Architecture support | x86 / x86-64 | x86-64, ARM (Apple Silicon native) |
| Virtualisation type | Type 2 (hosted) | Type 2; uses Apple Hypervisor / QEMU |
| Apple Silicon support | Limited (experimental) | Full native support |
| GUI | Cross-platform | macOS-native |
| Snapshots | Yes | Yes |
| Price | Free (for personal use) | Free |

VirtualBox is the standard choice for this project and runs on all major platforms.
It uses software-based x86 virtualisation,
which works well on Intel/AMD hardware
but has "experimental" 3d acceleration support on Apple silicone.
UTM is a macOS-native frontend for QEMU and Apple's Hypervisor framework.
On Apple Silicon Macs it can run ARM VMs with near-native performance,
and emulate x86 via QEMU at the cost of speed.

### Project specifics

#### OS

I picked Rocky for the simple reason
that at the point of choosing,
I already had done 2 minimal/server installs
of RPM based distributions,
so I was hoping knowledge would be at least somewhat transferable.

Furthermore,
I am a fan of OpenSUSE
and knowledge of setting up a SEL & firewalld server came in in handy
a bit after starting the project
when during my free time I set up a personal file server
using OpenSUSE Leap
for my personal side buisness.

#### Installation

Installation produced no noteworthy anomalies.
I picked resources based on Redhat's own minimum recommendations
and common conventions for installing machines like this
(text-based interface,
no hybernation).

After installation,
SSH required to enable port forwarding
on VirtualBox' end.

#### Post installation setup

The setup of the machine also went without hitches.
I took the liberty of installing

- `policycoreutils-python-utils`,
  for `semanage`, which allowed me to change rules at runtime
  instead of having to write
  and compile my own policy
- `git`,
  for pulling the scripts I wrote on my personal machine
  into the vm

## Resources

### AI Usage

Claude Sonnet 4.6 was used,
