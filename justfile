proj-root := justfile_directory()

src-path := proj-root / "src"
monitor-script := "monitoring.sh"
install-path := "/usr/local/sbin/"

vm-root:= proj-root / "vm"
vm-name := "42-rocky-v2"
vm-data := vm-root / vm-name 
vm-file := vm-name + ".vdi"

build     := proj-root / "build"
dist      := proj-root / "dist"
vm-dist   := build / "rocky.vdi"
turnin    := proj-root / "turnin"

sig-file  := "signature.txt"

backup-dir := "/home/musicvivireal/Temp/born2beroot-backups"

reset  := '\e[0m'
bold   := '\e[1m'
blue   := '\e[34m'
green  := '\e[92m'
yellow := '\e[33m'

_default:
    @just --list

_header name:
    @printf "\n{{bold}}{{blue}}=== {{name}} ===\n{{reset}}"

_step desc:
    @printf "{{yellow}}-> {{desc}}...{{reset}}\n"

_done name="":
    @if "{{name}}" != "" { print "{{bold}}{{green}}=== done: {{name}} ===\n{{reset}}" } else { print "{{bold}}{{green}}=== done ===\n{{reset}}" }


# run both testers
[group('test')]
test-all:
    just test-fork
    just test-own

# third-party tester  I forked
[group('test')]
test-fork:
    cd {{proj-root}}/tests/born2beroot-tester-rocky && sudo bash ./grade_me.sh -u lrain -m {{install-path}}/{{monitor-script}}

# my ownt tester (should have less false positives imo)
[group('test')]
test-own:
    cd {{proj-root}}/tests/vrockychecc && sudo bash tester.sh  --login lrain --sudo-log /var/log/sudo/sudo.log --pwquality /etc/security/pwquality.conf.d/99-custom.conf --cronfile /etc/cron.d/monitoring


# copy monitoring.sh to /usr/local/sbin/
[group('install')]
install-monitoring:
    mkdir -pv {{install-path}}
    cp -v {{src-path}}/{{monitor-script}} {{install-path}}/{{monitor-script}}
    chmod -v +x {{install-path}}/{{monitor-script}}


# full build pipeline: sign, package, verify, backup
[group('build')]
build-dist:
    #!/usr/bin/env nu
    just build-all
    #copy files to be turned in
    rsync -av --mkpath {{build}}/ {{turnin}}/
    # check if shasum is ok
    just check {{turnin}}/{{sig-file}}
    # compress release
    tar -czf {{proj-root}}/turnin.tar.gz -C {{proj-root}} turnin
    # move files to dist
    mkdir {{dist}}
    mv {{proj-root}}/turnin.tar.gz {{dist}}/
    just backup
    just sync-notes-from
    #just _done

# build sig + readme
[group('build')]
build-all:
    just build-sig
    just build-readme

# generate sha1 signature from vdi
[group('build')]
build-sig:
    #!/usr/bin/env nu
    cd {{vm-root}}; sha1sum {{vm-file}} | save -f {{sig-file}}
    mkdir -v {{build}}
    mv -v {{vm-root}}/{{sig-file}} {{build}}/{{sig-file}}

# copy readme into build/
[group('build')]
build-readme:
    rsync -v --mkpath README.md {{build}}/README.md


# build-dist then publish to github releases
[group('publish')]
publish:
    just build-dist
    gh release create `git describe --exact-match --tags HEAD` {{dist}}/turnin.tar.gz


# verify signature against vdi
[group('verification')]
check sig:
    #!/usr/bin/env nu
    cp {{sig}} {{vm-root}}/{{sig-file}}
    cd {{vm-root}}; sha1sum -c {{sig-file}}
    rm {{vm-root}}/{{sig-file}}

# re-extract turnin.tar.gz and verify
[group('verification')]
recheck:
    rm -rf {{proj-root}}/turnin/
    tar xvf {{dist}}/turnin.tar.gz -C {{proj-root}}
    just check {{proj-root}}/turnin/signature.txt


# backup entire vm/ folder to ~/Temp/born2beroot-backups (VM must be powered off)
[group('vm')]
backup:
    #!/usr/bin/env bash
    mkdir -p {{backup-dir}}
    dest="{{backup-dir}}/vm-$(date +%Y%m%d-%H%M%S)"
    echo "Backing up {{vm-root}} -> $dest"
    cp -vr "{{vm-root}}" "$dest"
    echo "Done: $dest"

# take a named VirtualBox snapshot
[group('vm')]
snapshot name:
    VBoxManage snapshot {{vm-name}} take {{name}}


# push todo.org to Documents
[group('notes')]
sync-notes-to:
    rsync -av {{proj-root}}/todo.org ~/Documents/org/42_cc_01_born2beroot.org

# pull todo.org from Documents
[group('notes')]
sync-notes-from:
    rsync -av ~/Documents/org/42_cc_01_born2beroot.org {{proj-root}}/todo.org


# remove build/ and turnin/
[group('cleanup')]
clean:
    rm -rf {{build}} {{turnin}}

# clean + remove dist/
[group('cleanup')]
fclean:
    just clean
    rm -rf {{dist}}
