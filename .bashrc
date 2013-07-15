# telde won't work on my mac...
# change properly to meet your need if you want to copy
SOURCE_DIR="/Users/$USER/.bash_init.d"
 if [ -d "$SOURCE_DIR" ]; then
    if [ "$(ls -A $SOURCE_DIR)" ]; then
        for f in $(ls -A $SOURCE_DIR); do
            source $SOURCE_DIR/$f;
        done
    fi
 else
     echo "does not have the initial directory!";
 fi

