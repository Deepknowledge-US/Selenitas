[ `uname` = Linux ] && export X=x86_64-apple-darwin11-
P=osx64 D=cjson.so A=libcjson.a C="-arch x86_64" \
	L="-arch x86_64 -undefined dynamic_lookup -Wno-static-in-inline" ./build.sh
