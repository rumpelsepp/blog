#!/bin/sh

SCRIPTNAME=$(basename "$0")
EDITOR=${EDITOR:-nvim}
EDITORARGS="+3"

usage() {
    echo "usage: $SCRIPTNAME [OPTS] OPERATION [ARGS] [-h]"
    echo ""
    echo "operations:"
    echo "  new-post       Create a new post file and open \$EDITOR"
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
        "$EDITOR" "$EDITORARGS" "$FILENAME"
    fi
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
    *)          usage                     && exit 1;;
esac
