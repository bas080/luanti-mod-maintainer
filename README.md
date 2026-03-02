# Luanti Mod Maintainer

Clone the test suite repository if you haven’t already:

```bash
git clone https://github.com/luanti/luanti-mod-maintainer.git
````

Some scripts have dependencies.

```bash
cpanm --installdeps .
```

Then, from the root directory of the mod you want to test, run:

```bash
prove -v path/to/luanti-mod-maintainer/t/
```

This repo also comes with some autofix scripts.

```bash
prove -v path/to/luanti-mod-maintainer/fix/
```
