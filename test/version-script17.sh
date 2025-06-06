#!/bin/bash
. $(dirname $0)/common.inc

cat <<EOF | $CC -fPIC -c -o $t/a.o -xc -
void foo() {}
void bar();
int main() { bar(); }
EOF

cat <<EOF | $CC -B. -shared -fPIC -o $t/b.so -xc -
void foo() {}
void bar() {}
EOF

$CC -B. -o $t/exe1 $t/a.o $t/b.so
nm -g $t/exe1 | grep foo

cat <<'EOF' > $t/c.ver
{ local: *; global: xyz; };
EOF

$CC -B. -o $t/exe2 $t/a.o $t/b.so -Wl,--version-script=$t/c.ver -Wl,--undefined-version
nm -g $t/exe2 | not grep foo

cat <<'EOF' > $t/d.ver
{ local: *; };
EOF

$CC -B. -o $t/exe3 $t/a.o $t/b.so -Wl,--version-script=$t/d.ver
nm -g $t/exe3 | not grep foo
