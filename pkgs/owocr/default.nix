{
  lib,
  python3Packages,
  fetchFromGitHub,
  nix-update-script,
  wrapGAppsHook4,
  gobject-introspection,
  gst_all_1,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "owocr";
  version = "1.26.8";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "AuroraWright";
    repo = "owocr";
    tag = finalAttrs.version;
    fetchSubmodules = true;
    hash = "sha256-xAGIxA1W2pr3/mhpJZC2jv85CtsjbuU4XXljj4KYS+E=";
  };

  # we use pystray directly to avoid making a new package
  # that only carries a single patch for windows double click support.
  # pythonRelaxDeps was not successful in patching
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "pystrayfix>=0.19.8" "pystray"
  '';

  build-system = [ python3Packages.setuptools ];

  nativeBuildInputs = [
    wrapGAppsHook4
    gobject-introspection
  ];

  buildInputs = with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-bad
  ];

  dependencies = with python3Packages; [
    fire
    jaconv
    loguru
    numpy
    pillow
    pyperclipfix
    pynput
    websockets
    desktop-notifier
    mss
    pysbd
    langid
    psutil
    pywinctl
    # extra optional libs for OCR engines
    azure-ai-documentintelligence # Azure Document Intelligence
    easyocr
    protobuf # Google Lens + Chrome Screen AI
    google-cloud-vision
    manga-ocr
    # manga-ocr segmented deps
    scipy
    opencv4
    torchvision
    torchsummary # comic_text_detector
    pyclipper
    shapely
    # rapidocr excluded: crashes trying to download models into the read-only nix store
    onnxruntime # NDLOCR-Lite
    # ndlocr-lite deps (submodule included via fetchSubmodules)
    lxml
    pyyaml
    networkx
    tqdm
    requests # winRT OCR
    python3Packages.obsws-python
    python3Packages.pystray
    python3Packages.pynputfix
    curl-cffi
    pygobject3
    gst-python
    dbus-python
    pywayland
  ];

  doCheck = false; # no tests

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Optical character recognition for Japanese text";
    homepage = "https://github.com/AuroraWright/owocr";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
