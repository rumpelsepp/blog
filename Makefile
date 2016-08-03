build:
	jekyll build

upload:
	rsync -e ssh -azzP --delete _site/* stefan@tatooine.sevenbyte.org:/home/stefan/htdocs/blog/

.PHONY : build upload
