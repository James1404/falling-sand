build:
    @cargo build

run *ARGS='':
    cargo run -- {{ARGS}}

dbg:
    rust-gdb target/debug/falling-sand

commit MSG:
    @git add .
    @git commit -m "{{MSG}}"

status:
    @git status

push:
    @git push

update-flake:
    nix flake update

loc:
    @tokei

