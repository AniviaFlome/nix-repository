#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>

__attribute__((constructor)) static void load_bass_plugins(void) {
    const char *appdir = getenv("APPDIR");
    if (!appdir || appdir[0] == '\0') {
        return;
    }

    char bass_path[4096];
    snprintf(bass_path, sizeof(bass_path), "%s/usr/bin/libbass.so", appdir);

    void *bass = dlopen(bass_path, RTLD_NOW | RTLD_GLOBAL);
    if (!bass) {
        bass = dlopen("libbass.so", RTLD_NOW | RTLD_GLOBAL);
    }
    if (!bass) {
        return;
    }

    unsigned int (*plugin_load)(const char *, unsigned int) =
        (unsigned int (*)(const char *, unsigned int))dlsym(bass, "BASS_PluginLoad");
    if (!plugin_load) {
        return;
    }

    const char *plugins[] = {
        "libbassflac.so",
        "libbassopus.so",
        "libbass_aac.so",
        "libbassalac.so",
        NULL,
    };

    for (int i = 0; plugins[i] != NULL; i++) {
        char path[4096];
        snprintf(path, sizeof(path), "%s/usr/bin/%s", appdir, plugins[i]);
        plugin_load(path, 0);
    }
}
