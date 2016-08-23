#!/bin/sh

SCRIPTNAME=$(basename "$0")
EDITOR=${EDITOR:-nvim}
EDITORARGS="+3"

usage() {
    echo "usage: $SCRIPTNAME [OPTS] OPERATION [ARGS] [-h]"
    echo ""
    echo "operations:"
    echo "  new-post       Create a new post file and open \$EDITOR"
    echo "  upload         Upload built website to: user@server:loc"
    echo "  build          Invoke 'jekyll build'"
    echo "  serve          Invoke 'jekyll serve'"
    echo ""
    echo "options:"
    echo "  -n             Do not open an editor"
}

# Args:
#   $1  String to slugify
slugify() {
    echo "$1" | iconv -t ascii//TRANSLIT | sed -r s/[^a-zA-Z0-9]+/-/g \
        | sed -r s/^-+\|-+$//g | tr A-Z a-z
}

post_create() {
    echo "Please tell me the title of the new post."
    read -r TITLE

    if [ -z "$TITLE" ]; then
        echo "Error: Title is empty!"
        exit 1
    fi

    SLUG=$(slugify "$TITLE")
    FILENAME="_posts/$(date +%F)-${SLUG}.adoc"

    echo "= $TITLE" >  "$FILENAME"
    echo ""         >> "$FILENAME"
    echo ""         >> "$FILENAME"

    if [ -z "$NOEDITOR" ]; then
        exec "$EDITOR" "$EDITORARGS" "$FILENAME"
    fi
}

# Args:
#   $1: CONNECTIONSTR: user@server:loc
#   $2: rsyncflags
upload() {
    SITEDIR="./_site"
    CONNECTIONSTR="$1"
    RSYNCFLAGS=${2:--e ssh -azzP --delete}  # ignore quoting hell...

    if [ -z "$CONNECTIONSTR" ]; then
        echo "Please supply a connection string!"
        exit 1
    fi

    if [ ! -d "$SITEDIR" ]; then
        echo "$SITEDIR does not exist!"
        echo "Consider doing a './manage.sh build'!"
        exit 1
    fi

    rsync $RSYNCFLAGS ${SITEDIR}/* "$CONNECTIONSTR"
}

build() {
    jekyll build
}

serve() {
    jekyll serve
}

while getopts "h" opt; do
    case $opt in
        n)    shift && NOEDITOR=1;;
        h)    usage && exit 0;;
        *)    usage && exit 1;;
    esac
done

shift $((OPTIND - 1))

case $1 in
    new-post)   shift && post_create "$@" && exit 0;;
    upload)     shift && upload      "$@" && exit 0;;
    build)      shift && build            && exit 0;;
    serve)      shift && serve            && exit 0;;
    *)          usage                     && exit 1;;
esac
