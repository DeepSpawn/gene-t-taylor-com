# gtt-blog

blog setup
stack new hakyll-template
stack init
stack install hakyll-sass
add hakyll-sass to extra deps


* stack build
Builds the executable, required if you make changes to site.hs

* stack exec gtt-blog rebuild
rebuilds the entire site

* stack exec gtt-blog watch
builds the site, serves it on localhost:8000, and watches it for changes to automatically rebuild it

* stack image container
build the docker image with the exe to deploy

* docker tag $image deepspawn/gtt-blog-exec
tag the image with correct tag

* docker push deepspawn/gtt-blog-exec
push it up for use with pipelines