proj-root := justfile_directory()

src-path := proj-root / "src"
monitor-script := "monitoring.sh"
install-path := "/root/.local/bin/"

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


# backup entire vm/ folder to ~/Temp/born2beroot-backups (VM must be powered off)
backup:
    #!/usr/bin/env bash
    mkdir -p {{backup-dir}}
    dest="{{backup-dir}}/vm-$(date +%Y%m%d-%H%M%S)"
    echo "Backing up {{vm-root}} -> $dest"
    cp -vr "{{vm-root}}" "$dest"
    echo "Done: $dest"

snapshot:
    VBoxManage snapshot {{vm-name}} take `git describe --exact-match --tags HEAD`

# build signature
build-sig:
    #!/usr/bin/env nu
    cd {{vm-data}}; sha1sum {{vm-file}} | save -f {{sig-file}}
    mkdir -v {{build}}
    mv {{vm-data}}/{{sig-file}} {{build}}/{{sig-file}}
    
build-readme:
    rsync -v --mkpath README.md {{build}}/README.md

build-all:
    just build-sig
    just build-readme


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

publish:
    just build-dist
    gh release create `git describe --exact-match --tags HEAD` {{dist}}/turnin.tar.gz                                                                                                          
    

check sig:
    #!/usr/bin/env nu
    cp {{sig}} {{vm-data}}/{{sig-file}}
    cd {{vm-data}}; sha1sum -c {{sig-file}}
    rm {{vm-data}}/{{sig-file}}

recheck :
    rm -rf {{proj-root}}/turnin/
    tar xvf {{dist}}/turnin.tar.gz -C {{proj-root}}
    just check {{proj-root}}/turnin/signature.txt

sync-notes-to:
    rsync -av {{proj-root}}/todo.org ~/Documents/org/42_cc_01_born2beroot.org

sync-notes-from:
    rsync -av ~/Documents/org/42_cc_01_born2beroot.org {{proj-root}}/todo.org

test:
    cd {{proj-root}}/tests/born2beroot-tester-rocky && sudo bash grade_me.sh -u lrain -m /root/.local/bin/monitoring.sh
    cd {{proj-root}}/tests/vrockychecc && sudo bash tester.sh lrain luks/74eea0d3-8300-4a53-9df7-a66301776844

install-monitoring:
    mkdir -pv {{install-path}}
    cp -v {{src-path}}/{{monitor-script}} {{install-path}}/{{monitor-script}}
    chmod -v +x {{install-path}}/{{monitor-script}}

clean:
    rm -rf {{build}} {{turnin}}

fclean:
    just clean
    rm -rf {{dist}}
