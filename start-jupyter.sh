#!/usr/bin/env bash

echo "input password"

passphrase="passphrase"
passconfirm="passconfirm"
until [ $passphrase = $passconfirm ]
do
    read -sp "Password :" passphrase
    echo
    read -sp "Confirm password :" passconfirm
    echo
    if [ $passphrase != $passconfirm ]
    then
        echo "Password mismatch"
    fi
#passphrase="hello, world"
done
# generate salt
salt=$(openssl rand -hex 6)

# generate hash
algorithm=sha1
hash="$(echo ${passphrase} | iconv -t utf-8)${salt}" | openssl dgst -${algorithm} | awk -v alg="${algorithm}" -v salt="${salt}" '{print alg ":" salt ":" $NF}'

mkdir -p ~/jupyter
cat <<EOF > ~/jupyter_notebook_config.json
{
  "NotebookApp": {
    "password": "$hash"
  }
}
EOF

docker run -d -p 8888:8888 -v ~/jupyter:/home/jovyan/.jupyter \
-v ~/work:/home/jovyan/work \
-e GRANT_SUDO=yes \
--user root \
--restart always \
--name jupyter jupyter/tensorflow-notebook

