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
done
###deprecated
# generate salt
#salt=$(openssl rand -hex 6)
# generate hash
#algorithm=sha1
#hash=$(echo ${passphrase}${salt}|openssl dgst -${algorithm} | awk -v alg="${algorithm}" -v salt="${salt}" '{print alg ":" salt ":" $NF}')
converted=$(echo ${passphrase} | iconv -t utf-8)
pkgexists=$(python3 -c 'import pkgutil; print(1 if pkgutil.find_loader("IPython") else 0)')
if [ $pkgexists != 1 ]
then
    pip3 install ipython
fi
hash=$(python3 -c "from IPython.lib.security import passwd; print(passwd(passphrase='${converted}', algorithm='sha1'))")
echo "hash : ${hash}"
mkdir -p ~/.jupyter
cat <<EOF > ~/.jupyter/jupyter_notebook_config.json
{
  "NotebookApp": {
    "password": "$hash"
  }
}
EOF

docker run -d -p 8888:8888 -v ~/.jupyter:/home/jovyan/.jupyter \
-v ~/jupyter:/home/jovyan/work \
--restart always \
--name jupyter jupyter/tensorflow-notebook

