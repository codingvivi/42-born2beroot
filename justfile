root := justfile_directory()

vm-path := root / "vm"
vm-name := "42-rocky"
vm-file := vm-path / vm-name / vm-name + ".vdi"

build     := root / "build"
dist      := root / "dist"
vm-dist   := build / "rocky.vdi"
turnin    := root / "turnin"
sig-file  := "signature.txt"

reset  := '\e[0m'
bold   := '\e[1m'
blue   := '\e[34m'
green  := '\e[92m'
yellow := '\e[33m'

default:
    @just --list

_header name:
    @printf "\n{{bold}}{{blue}}=== {{name}} ===\n{{reset}}"

_step desc:
    @printf "{{yellow}}-> {{desc}}...{{reset}}\n"

_done name="":
    @if "{{name}}" != "" { print "{{bold}}{{green}}=== done: {{name}} ===\n{{reset}}" } else { print "{{bold}}{{green}}=== done ===\n{{reset}}" }


snapshot:
    VBoxManage snapshot {{vm-name}} take `git describe --exact-match --tags HEAD`

build-sig:
    #!/usr/bin/env nu
    mkdir -v {{build}}
    cd {{build}}; shasum ../vm/42-rocky/42-rocky.vdi | save -f {{sig-file}}

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
    cd {{turnin}}; just check {{sig-file}}
    tar -czf {{root}}/turnin.tar.gz -C {{root}} turnin
    mv {{root}}/turnin.tar.gz {{dist}}/
    just snapshot
    just sync-notes-from
    #just _done

publish:
    just build-dist
    gh release create `git describe --exact-match --tags HEAD` {{dist}}/turnin.tar.gz                                                                                                          
    
check file:
     shasum -c {{file}}

sync-notes-to:
    rsync -av {{root}}/todo.org ~/Documents/org/42_cc_01_born2beroot.org

sync-notes-from:
    rsync -av ~/Documents/org/42_cc_01_born2beroot.org {{root}}/todo.org

test:
    cd {{root}}/tests/born2beroot-tester-rocky && sudo bash grade_me.sh -u lrain -m /root/.local/bin/monitoring.sh
    cd {{root}}/tests/vrockychecc && sudo bash tester.sh lrain luks/74eea0d3-8300-4a53-9df7-a66301776844

clean:
    rm -rf {{build}} {{turnin}}

fclean:
    just clean
    rm -rf {{dist}}
