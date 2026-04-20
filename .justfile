default:
    just --list

compile-mks backend:
    mkdir -p target
    kast mini compile \
        --target c \
        --prepend $KAST_PATH/mini/backends/c/runtime.c \
        --prepend src/backends/{{backend}}.c \
        $KAST_PATH/mini/backends/c/runtime.mks \
        $(fd --extension mks --exclude '**/backends/*') \
        src/backends/{{backend}}.mks \
        > target/main.c

compile-c:
    gcc target/main.c \
        -lm \
        -lraylib \
        -o target/main

compile-emscripten:
    mkdir -p target/web
    emcc target/main.c \
        $RAYLIB_WEB \
        -o target/web/index.html \
        -I. -I $RAYLIB/include \
        -Os \
        -s USE_GLFW=3 \
        --preload-file assets \
        -s TOTAL_STACK=64MB \
        -s INITIAL_MEMORY=128MB \
        -s ASSERTIONS \
        --shell-file shell.html \
        -DPLATFORM_WEB
    # -sMAX_WEBGL_VERSION=2 \
    # -s ASYNCIFY \

serve-web:
    caddy file-server \
        --listen 127.0.0.1:8081 \
        --root target/web

build:
    just compile-mks native
    just compile-c

build-web:
    just compile-mks emscripten
    just compile-emscripten

run:
    just build
    ./target/main

web:
    just build-web
    just serve-web

publish:
    just build-web
    butler push target/web kuviman/megahonk:html5

