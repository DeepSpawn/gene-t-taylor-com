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



...monkey patch image with python + cli
gtaylor@gtaylor ~: docker commit 5c25592a82e1 gtt-blog:custom
sha256:01008c81b90c8a52a4c05a2d12843d60cc106659c443991d5c6269cef5bb049c
gtaylor@gtaylor ~:  docker tag 01008c81b90c8a52a4c05a2d12843d60cc106659c443991d5c6269cef5bb049c deepspawn/gtt-blog-exec