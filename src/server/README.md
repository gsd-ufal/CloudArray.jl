# Preparing a CloudArray Server

Recommended System: Ubuntu 14.04 LTS

* 1. Run the install script:

```
$ sudo ./install.sh
```

* 2. Add a docker user

```
$ useradd dockeru -s /bin/bash -m -g docker
```

* 3. Build CloudArray image

```
$ docker build -t cloudarray .
```
