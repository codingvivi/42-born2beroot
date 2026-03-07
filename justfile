set shell := ["nu", "-c"]

root := justfile_directory()
ext-path := root / ext

vm-path := root / "vm"
vm-file := vm-path / "roccy.vdi"

iso-file := vm-path / "Rocky-10.1-x86_64-dvd1.iso"


dist      := root / "dist"
vm-dist   := dist / "rocky.vdi"
turnin    := dist / "turnin"
sig-file  := turnin / "Signature.txt"

reset  := '\033[0m'
bold   := '\033[1m'
blue   := '\033[34m'
green  := '\033[92m'
yellow := '\033[33m'

_header name:
    @printf "\n{{bold}}{{blue}}=== {{name}} ===\n{{reset}}"

_step desc:
    @printf "{{yellow}}-> {{desc}}...{{reset}}\n"

_done name="":
    @if "{{name}}" != "" { print "{{bold}}{{green}}=== done: {{name}} ===\n{{reset}}" } else { print "{{bold}}{{green}}=== done ===\n{{reset}}" }



vm-name := "42-rocky"

snapshot:
    VBoxManage snapshot {{vm-name}} take (git rev-parse --short HEAD)

build-sig:
    mkdir -v {{turnin}}
    cd {{turnin}}
    shasum "../vm/rocky.vdi" | {{sig-file}}

build-readme:
    rsync -v --mkpath README.md {{turnin}}/README.md

build-dist:
    just _header "dist"
    rm -rfv {{dist}}
    mkdir -v {{turnin}}
    rsync -av --mkpath --include-from='.dist-include' --exclude='*' . {{turnin}}/
    rsync --timestamp{{vm-file}} {{vm-dist}}
    just _done

fetch-iso:
    aria2c -x 16 -s 16 -d {{vm-path}} ext/vm/ https://download.rockylinux.org/pub/rocky/10/isos/x86_64/Rocky-10.1-x86_64-dvd1.iso 


check:
    cd {{dist}} && shasum -c {{sig-file}}

sync-notes-to:
    rsync -av {{root}}/todo.org ~/Documents/org/42_cc_01_born2beroot.org

sync-notes-from:
    rsync -av ~/Documents/org/42_cc_01_born2beroot.org {{root}}/todo.org
