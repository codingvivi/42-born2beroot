*This project has been created as part of the 42 curriculum by lrain.*

# Born2beRoot

![](./ivebeenwaitingforthis.png)

*finally, being a minimal install, cli-everything sicko pays off*

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

### Running the test battery

The test battery includes two tests,
one fork of a Debian tester I edited
and one test I wrote from scratch when I was doublechecking my VM.

Both testers must be run **on the VM**.
Clone the repo onto the VM, then:

```sh
git submodule update --init --recursive
bash install-just.sh
./external/just test
```

`install-just.sh` installs `just` into `external/` without requiring root or a package manager.
`just test` runs both testers — the third-party `grade_me.sh` and the Rocky-specific `tester.sh`.

### Building a submittable release

Mirroring my build environment requires:

- [`just`](https://github.com/casey/just)
- [`nushell`](https://www.nushell.sh/)
- [`gh`](https://cli.github.com/)

For an overview of all my `just` recipes simply run

```sh
   just
```

Creating a version to be submitted consists of creating a git tag first

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
- create the evaluation-allowed snapshot of the current vm’s state named after the current git tag
- sync my notes (since technically they are part of this repo’s `source code` which is included in github releases)

If the build completes successfully,
the tar and the rest of the tracked repo files can be published to github via

```sh
   just publish
```

To clean up build artifacts:

```sh
just clean    # removes build/ and turnin/
just fclean   # also removes dist/
```

## Project description

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
| Auditing| Easier | Harder |
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
but has "experimental" 3d acceleration support on Apple silicon.
UTM is a macOS-native frontend for QEMU and Apple's Hypervisor framework.
On Apple Silicon Macs it can run ARM VMs with near-native performance,
and emulate x86 via QEMU at the cost of speed.

### Project specifics

#### OS

Having already
done 2 minimal/server installs
of RPM based distributions,
at the time of starting the project
I picked Rocky
hoping the knowledge would be at least somewhat transferable.

Furthermore,
I am a fan of OpenSUSE
and knowledge of setting up a SELinux & firewalld server came in handy
a bit after starting the project
when during my free time,
I set up a personal file server
using OpenSUSE Leap
for my personal side business.

#### Installation

Installation produced no noteworthy anomalies.
I picked resources based on Redhat's own minimum recommendations
and common conventions for installing machines like this
(text-based interface,
no hibernation).

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

Even though not explicitly asked for
I disabled password login as soon as I copied my ssh key onto the machine,
since this is standard practice.

## Resources

### References

[1] "5.4.4. Creating Thinly-Provisioned Logical Volumes | Logical Volume Manager Administration | Red Hat Enterprise Linux | 6 | Red Hat Documentation." Accessed: Feb. 21, 2026. [Online]. Available: https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/6/html/logical_volume_manager_administration/thinly_provisioned_volume_creation

[2] "5.6. Controlling Traffic | Security Guide | Red Hat Enterprise Linux | 7 | Red Hat Documentation." Accessed: Feb. 24, 2026. [Online]. Available: https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/7/html/security_guide/sec-controlling_traffic#sec-Controlling_Ports_using_CLI

[3] "7.8. Creating Audit Reports | Security Guide | Red Hat Enterprise Linux | 7 | Red Hat Documentation." Accessed: Mar. 10, 2026. [Online]. Available: https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/7/html/security_guide/sec-creating_audit_reports

[4] A. Kili, "10 Useful Sudoers Configurations for Setting 'sudo' in Linux." Accessed: Feb. 24, 2026. [Online]. Available: https://www.tecmint.com/sudoers-configurations-for-setting-sudo-in-linux/

[5] "12-D.14: UFW & firewalld," Engineering LibreTexts. Accessed: Mar. 09, 2026. [Online]. Available: https://eng.libretexts.org/Bookshelves/Computer_Science/Operating_Systems/Linux\_-_The_Penguin_Marches_On_(McClanahan)/12%3A_Linux_Systems_Security/4.14%3A_UFW_and_firewalld

[6] zrajm, "Answer to 'What is the difference between adduser and useradd?,'" Ask Ubuntu. Accessed: Feb. 24, 2026. [Online]. Available: https://askubuntu.com/a/381646

[7] l0b0, "Answer to 'What is the preferred Bash shebang ("#!")?,'" Stack Overflow. Accessed: Mar. 07, 2026. [Online]. Available: https://stackoverflow.com/a/10383546

[8] K. Thompson, "Answer to 'What is the preferred Bash shebang ("#!")?,'" Stack Overflow. Accessed: Mar. 07, 2026. [Online]. Available: https://stackoverflow.com/a/52860837

[9] wholerabbit, "Answer to 'What is the preferred Bash shebang ("#!")?,'" Stack Overflow. Accessed: Mar. 07, 2026. [Online]. Available: https://stackoverflow.com/a/10376235

[10] "AppArmor," AppArmor. Accessed: Mar. 07, 2026. [Online]. Available: https://apparmor.net/

[11] "Chapter 13. Getting started with swap | Managing storage devices | Red Hat Enterprise Linux | 8 | Red Hat Documentation." Accessed: Feb. 22, 2026. [Online]. Available: https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/8/html/managing_storage_devices/getting-started-with-swap_managing-storage-devices

[12] "Classic SysAdmin: Linux 101: 5 Commands for Checking Memory Usage in Linux - Linux Foundation." Accessed: Mar. 07, 2026. [Online]. Available: https://www.linuxfoundation.org/blog/blog/classic-sysadmin-linux-101-5-commands-for-checking-memory-usage-in-linux

[13] "Compiling SELinux Policy." Accessed: Mar. 09, 2026. [Online]. Available: https://ftp.iij.ad.jp/pub/linux/centos-vault/4.0beta/docs/html/rhel-selg-en-4/rhlcommon-chapter-0018.html

[14] "Computer data storage," Wikipedia. Mar. 02, 2026. Accessed: Mar. 08, 2026. [Online]. Available: https://en.wikipedia.org/w/index.php?title=Computer_data_storage&oldid=1341277385#Primary

[15] "Datagram Congestion Control Protocol," Wikipedia. Aug. 26, 2025. Accessed: Feb. 24, 2026. [Online]. Available: https://en.wikipedia.org/w/index.php?title=Datagram_Congestion_Control_Protocol&oldid=1307879922

[16] S. Smollen, "Debugging Bash Scripts with $PS4," Spencer Smolen. Accessed: Mar. 07, 2026. [Online]. Available: https://spencersmolen.com/debugging-bash/

[17] "Difference Between TCP, UDP and SCTP Protocols," GeeksforGeeks. Accessed: Feb. 24, 2026. [Online]. Available: https://www.geeksforgeeks.org/computer-networks/tcp-vs-udp-vs-sctp/

[18] "End-to-end principle," Wikipedia. Feb. 23, 2026. Accessed: Feb. 24, 2026. [Online]. Available: https://en.wikipedia.org/w/index.php?title=End-to-end_principle&oldid=1340005850

[19] R. L. Team, "FIPS Validation Update - June 2022," Rocky Linux. Accessed: Feb. 21, 2026. [Online]. Available: https://rockylinux.org/news/certifications-fips-2022-06-11

[20] "How to configure a hostname on a Linux system," Red Hat Blog. Accessed: Feb. 24, 2026. [Online]. Available: https://www.redhat.com/en/blog/configure-hostname-linux

[21] "How to List Users in Linux (9 Methods with Examples)." Accessed: Feb. 24, 2026. [Online]. Available: https://www.strongdm.com/blog/how-to-list-users-linux

[22] "How to read and correct SELinux denial messages," Red Hat Blog. Accessed: Mar. 10, 2026. [Online]. Available: https://www.redhat.com/en/blog/selinux-denial2

[23] Casey, "How to recover root password - Rocky Linux Help & Support," Rocky Linux Forum. Accessed: Mar. 07, 2026. [Online]. Available: https://forums.rockylinux.org/t/how-to-recover-root-password/3433/8

[24] I. Walker, "How to recover root password - Rocky Linux Help & Support," Rocky Linux Forum. Accessed: Mar. 07, 2026. [Online]. Available: https://forums.rockylinux.org/t/how-to-recover-root-password/3433/2

[25] "Instance (computer science)," Wikipedia. Feb. 09, 2026. Accessed: Mar. 08, 2026. [Online]. Available: https://en.wikipedia.org/w/index.php?title=Instance\_(computer_science)&oldid=1337521647

[26] "Linux Security Modules," Wikipedia. Mar. 04, 2026. Accessed: Mar. 07, 2026. [Online]. Available: https://en.wikipedia.org/w/index.php?title=Linux_Security_Modules&oldid=1341653422

[27] "Mandatory access control," Wikipedia. Jan. 23, 2026. Accessed: Mar. 07, 2026. [Online]. Available: https://en.wikipedia.org/w/index.php?title=Mandatory_access_control&oldid=1334399622

[28] "Minimum hardware requirements - Documentation." Accessed: Feb. 22, 2026. [Online]. Available: https://docs.rockylinux.org/10/de/guides/minimum_hardware_requirements/

[29] C. Beaudet and Wayne Maw, "Overview of SELinux and AppArmor," in SUSECON 2021 - BOV-1067, Nov. 10, 2021. Accessed: Mar. 07, 2026. [Online]. Available: https://www.youtube.com/watch?v=9dqHOrM4KHo

[30] "PAM authentication modules - Documentation." Accessed: Feb. 24, 2026. [Online]. Available: https://docs.rockylinux.org/10/guides/security/pam/

[31] D. F. Frisenna, "Passphrases are easier to remember, but are they secure enough?," SySS Tech Blog. Accessed: Feb. 22, 2026. [Online]. Available: https://blog.syss.com/posts/passphrases/

[32] "Persistence (computer science)," Wikipedia. Oct. 17, 2025. Accessed: Mar. 08, 2026. [Online]. Available: https://en.wikipedia.org/w/index.php?title=Persistence\_(computer_science)&oldid=1317234327

[33] "Processor (computing)," Wikipedia. Feb. 27, 2026. Accessed: Mar. 08, 2026. [Online]. Available: https://en.wikipedia.org/w/index.php?title=Processor\_(computing)&oldid=1340750781

[34] "Processor register," Wikipedia. Feb. 06, 2026. Accessed: Mar. 08, 2026. [Online]. Available: https://en.wikipedia.org/w/index.php?title=Processor_register&oldid=1336997801

[35] "Quick start to write a custom SELinux policy," Red Hat Customer Portal. Accessed: Mar. 09, 2026. [Online]. Available: https://access.redhat.com/articles/6999267

[36] "Rocky Linux 10 : Set Password Rules : Server World." Accessed: Feb. 24, 2026. [Online]. Available: https://www.server-world.info/en/note?os=Rocky_Linux_10&p=pam&f=1

[37] "Rocky Linux 10 (Red Quartz) – Minimum Hardware Requirements - Documentation." Accessed: Feb. 22, 2026. [Online]. Available: https://docs.rockylinux.org/10/guides/minimum_hardware_requirements/

[38] "Secure environment," Wikipedia. Oct. 03, 2025. Accessed: Mar. 07, 2026. [Online]. Available: https://en.wikipedia.org/w/index.php?title=Secure_environment&oldid=1314911000

[39] "Shebang (Unix)," Wikipedia. Feb. 11, 2026. Accessed: Mar. 07, 2026. [Online]. Available: https://en.wikipedia.org/w/index.php?title=Shebang\_(Unix)&oldid=1337789593#Portability

[40] "Signature.txt | Born2BeRoot Guide." Accessed: Mar. 05, 2026. [Online]. Available: https://noreply.gitbook.io/born2beroot/virtual-machine-setup/signature.txt

[41] "SwapFaq - Community Help Wiki." Accessed: Feb. 22, 2026. [Online]. Available: https://help.ubuntu.com/community/SwapFaq

[42] "Technologies for container isolation: A comparison of AppArmor and SELinux." Accessed: Mar. 07, 2026. [Online]. Available: https://www.redhat.com/en/blog/apparmor-selinux-isolation

[43] "Tested: VirtualBox now supports Windows on M-series Macs, but it's not for beginners," Macworld. Accessed: Mar. 09, 2026. [Online]. Available: https://www.macworld.com/article/2949071/virtualbox-review.html

[44] "Thread (computing)," Wikipedia. Jan. 16, 2026. Accessed: Mar. 08, 2026. [Online]. Available: https://en.wikipedia.org/w/index.php?title=Thread\_(computing)&oldid=1333190122

[45] "Time-of-check to time-of-use," Wikipedia. Mar. 05, 2026. Accessed: Mar. 07, 2026. [Online]. Available: https://en.wikipedia.org/w/index.php?title=Time-of-check_to_time-of-use&oldid=1341785370

[46] "User Management - Documentation." Accessed: Feb. 24, 2026. [Online]. Available: https://docs.rockylinux.org/10/books/admin_guide/06-users/

[47] "Volatile memory," Wikipedia. Feb. 15, 2026. Accessed: Mar. 08, 2026. [Online]. Available: https://en.wikipedia.org/w/index.php?title=Volatile_memory&oldid=1338446607

[48] J. Thijssen, "Why putting SSH on another port than 22 is bad idea," A Day In The Life Of... Accessed: Mar. 10, 2026. [Online]. Available: https://adayinthelifeof.nl//2012/03/12/why-putting-ssh-on-another-port-than-22-is-bad-idea/

### AI Usage

Claude Sonnet 4.6 was used,
for grunt work like

- refactoring parts of the bash in the tests
- pasting README outlines
- reformatting text styling
