default:
    just --list

compile-mks:
    mkdir -p target
    kast mini compile \
        --target c \
        --prepend $KAST_PATH/mini/backends/c/runtime.c \
        $KAST_PATH/mini/backends/c/runtime.mks \
        $(fd --extension mks) \
        > target/main.c

compile-c:
    gcc target/main.c \
        -lm \
        -lraylib \
        -o target/main

compile-emscripten:
    emcc target/main.c \
        $RAYLIB_WEB \
        -o target/index.html \
        -I. -I $RAYLIB/include \
        -Os \
        -s USE_GLFW=3 \
        -s ASYNCIFY \
        --preload-file assets \
        -s TOTAL_STACK=64MB \
        -s INITIAL_MEMORY=128MB \
        -s ASSERTIONS \
        -DPLATFORM_WEB

serve-web:
    caddy file-server \
        --listen 127.0.0.1:8081 \
        --root target

build:
    just compile-mks
    just compile-c

build-web:
    just compile-mks
    just compile-emscripten

build-and-run:
    just build
    ./target/main

build-and-run-web:
    just build-web
    just serve-web

