#!/usr/bin/env bash
# Installs (or uninstalls) the M0Rf30 EasyEffects presets.
#
# It detects the EasyEffects data directory (native or Flatpak), downloads the
# presets and impulse responses listed in the manifest below and removes them
# again on request.  Run with --help for the non-interactive usage.

set -u
set -o pipefail

REPO_SLUG="M0Rf30/easyeffects-presets"
FLATPAK_ID="com.github.wwmm.easyeffects"

REF="${EASYEFFECTS_PRESETS_REF:-main}"
BASE_URL="${EASYEFFECTS_PRESETS_BASE_URL:-}"

# Manifest: <group>|<repo-relative path>. Paths are literal (not URL-encoded).
# Root *.json are output presets, input/*.json are microphone presets and
# irs/* are impulse responses / HRTF datasets.
manifest() {
    cat <<'MANIFEST_EOF'
# BEGIN MANIFEST
hesuvi|HeSuVi Atmos.json
hesuvi|irs/HeSuVi Atmos (True Stereo, 48kHz).irs
hesuvi|HeSuVi DTS Headphone X.json
hesuvi|irs/HeSuVi DTS Headphone X (True Stereo, 48kHz).irs
hesuvi|HeSuVi GSX.json
hesuvi|irs/HeSuVi GSX (True Stereo, 48kHz).irs
hesuvi|HeSuVi CMSS-3D Entertainment.json
hesuvi|irs/HeSuVi CMSS-3D Entertainment (True Stereo, 48kHz).irs
hesuvi|HeSuVi CMSS-3D Game.json
hesuvi|irs/HeSuVi CMSS-3D Game (True Stereo, 48kHz).irs
hesuvi|HeSuVi CMSS-3D RX+.json
hesuvi|irs/HeSuVi CMSS-3D RX+ (True Stereo, 48kHz).irs
hesuvi|HeSuVi Dolby Headphone.json
hesuvi|irs/HeSuVi Dolby Headphone (True Stereo, 48kHz).irs
hesuvi|HeSuVi Dolby Home Theater.json
hesuvi|irs/HeSuVi Dolby Home Theater (True Stereo, 48kHz).irs
hesuvi|HeSuVi DS3D.json
hesuvi|irs/HeSuVi DS3D (True Stereo, 48kHz).irs
hesuvi|HeSuVi DVS.json
hesuvi|irs/HeSuVi DVS (True Stereo, 48kHz).irs
hesuvi|HeSuVi Nahimic.json
hesuvi|irs/HeSuVi Nahimic (True Stereo, 48kHz).irs
hesuvi|HeSuVi Windows Sonic.json
hesuvi|irs/HeSuVi Windows Sonic (True Stereo, 48kHz).irs
hesuvi|HeSuVi Out Of Your Head.json
hesuvi|irs/HeSuVi Out Of Your Head (True Stereo, 48kHz).irs
hesuvi|HeSuVi Waves.json
hesuvi|irs/HeSuVi Waves (True Stereo, 48kHz).irs
hesuvi|HeSuVi Sound Blaster SBX.json
hesuvi|irs/HeSuVi Sound Blaster SBX (True Stereo, 48kHz).irs
hesuvi|HeSuVi Dolby Headphone ++.json
hesuvi|irs/HeSuVi Dolby Headphone ++ (True Stereo, 48kHz).irs
hesuvi|HeSuVi DS3D ++.json
hesuvi|irs/HeSuVi DS3D ++ (True Stereo, 48kHz).irs
hesuvi|HeSuVi DS3D +++.json
hesuvi|irs/HeSuVi DS3D +++ (True Stereo, 48kHz).irs
hesuvi|HeSuVi GSX +.json
hesuvi|irs/HeSuVi GSX + (True Stereo, 48kHz).irs
hesuvi|HeSuVi GSX ++.json
hesuvi|irs/HeSuVi GSX ++ (True Stereo, 48kHz).irs
hesuvi|HeSuVi DVS +.json
hesuvi|irs/HeSuVi DVS + (True Stereo, 48kHz).irs
hesuvi|HeSuVi Sound Blaster SBX 33.json
hesuvi|irs/HeSuVi Sound Blaster SBX 33 (True Stereo, 48kHz).irs
hesuvi|HeSuVi Sound Blaster SBX 67.json
hesuvi|irs/HeSuVi Sound Blaster SBX 67 (True Stereo, 48kHz).irs
hesuvi|HeSuVi Windows Sonic +.json
hesuvi|irs/HeSuVi Windows Sonic + (True Stereo, 48kHz).irs
hesuvi|HeSuVi Out Of Your Head 2.json
hesuvi|irs/HeSuVi Out Of Your Head 2 (True Stereo, 48kHz).irs
hesuvi|HeSuVi SSC Dublin.json
hesuvi|irs/HeSuVi SSC Dublin (True Stereo, 48kHz).irs
hesuvi|HeSuVi SSC New York.json
hesuvi|irs/HeSuVi SSC New York (True Stereo, 48kHz).irs
hesuvi|HeSuVi SSC New York +.json
hesuvi|irs/HeSuVi SSC New York + (True Stereo, 48kHz).irs
hesuvi|HeSuVi SSC Sydney.json
hesuvi|irs/HeSuVi SSC Sydney (True Stereo, 48kHz).irs
hesuvi|HeSuVi SSC Sydney +.json
hesuvi|irs/HeSuVi SSC Sydney + (True Stereo, 48kHz).irs
hesuvi|HeSuVi SSC Hù.json
hesuvi|irs/HeSuVi SSC Hù (True Stereo, 48kHz).irs
hesuvi|HeSuVi SSC Hù+.json
hesuvi|irs/HeSuVi SSC Hù+ (True Stereo, 48kHz).irs
hesuvi|HeSuVi OpenAL +.json
hesuvi|irs/HeSuVi OpenAL + (True Stereo, 48kHz).irs
hesuvi|HeSuVi OpenAL ++.json
hesuvi|irs/HeSuVi OpenAL ++ (True Stereo, 48kHz).irs
hesuvi|HeSuVi OpenAL +++.json
hesuvi|irs/HeSuVi OpenAL +++ (True Stereo, 48kHz).irs
hesuvi|HeSuVi Flux HEar.json
hesuvi|irs/HeSuVi Flux HEar (True Stereo, 48kHz).irs
hesuvi|HeSuVi Razer Surround.json
hesuvi|irs/HeSuVi Razer Surround (True Stereo, 48kHz).irs
hesuvi|HeSuVi Razer Surround Bass Fix.json
hesuvi|irs/HeSuVi Razer Surround Bass Fix (True Stereo, 48kHz).irs
hesuvi|HeSuVi OpenAL CIAIR.json
hesuvi|irs/HeSuVi OpenAL CIAIR (True Stereo, 48kHz).irs
hesuvi|HeSuVi OpenAL CIAIR Wide.json
hesuvi|irs/HeSuVi OpenAL CIAIR Wide (True Stereo, 48kHz).irs
hesuvi|HeSuVi OpenAL Default.json
hesuvi|irs/HeSuVi OpenAL Default (True Stereo, 48kHz).irs
crossfeed|Synthetic Spherical Crossfeed.json
crossfeed|irs/Synthetic Spherical-Head Crossfeed (48kHz).irs
efotech|EFOtech MLV 00256.json
efotech|irs/EFOtech MLV 00256 (True Stereo, 48kHz).irs
efotech|EFOtech MLV 00512.json
efotech|irs/EFOtech MLV 00512 (True Stereo, 48kHz).irs
efotech|EFOtech MLV 01024.json
efotech|irs/EFOtech MLV 01024 (True Stereo, 48kHz).irs
efotech|EFOtech MLV 02048.json
efotech|irs/EFOtech MLV 02048 (True Stereo, 48kHz).irs
efotech|EFOtech MLV 04096.json
efotech|irs/EFOtech MLV 04096 (True Stereo, 48kHz).irs
efotech|EFOtech MLV 22000.json
efotech|irs/EFOtech MLV 22000 (True Stereo, 48kHz).irs
kemar|MIT KEMAR HRTF (SOFA).json
kemar|irs/MIT KEMAR HRTF (Normal Pinna).sofa
ari|ARI HRTF (SOFA).json
ari|irs/ARI HRTF (Subject NH2, DTF).sofa
gentledynamics|GentleDynamics.json
gentledynamics|GentleDynamics Feather Loudness.json
gentledynamics|GentleDynamics Dialogue Clarity Engine.json
aurora|Aurora Immersive.json
cupertino|Cupertino Laptop Speakers.json
ircam|IRCAM LISTEN HRTF (Subject 1002).json
ircam|irs/IRCAM LISTEN HRTF (Subject 1002, True Stereo, 48kHz).irs
utility|Night Listening.json
utility|Levelizer (EBU R128).json
utility|Mono Sum (Accessibility).json
utility|Tiny Speaker Rescue.json
utility|Analog Warmth.json
utility|Concert Hall.json
utility|Movie Dialogue Boost.json
utility|Reference Transparency.json
binaural|Synthetic Binaural Room.json
binaural|irs/Synthetic Binaural Room (Structural HRTF, 48kHz).irs
libreatmos|LibreAtmos.json
libreatmos|irs/LibreAtmos (Stereo, 48kHz).irs
libreatmos|LibreAtmos Dynamic.json
libreatmos|irs/LibreAtmos Dynamic (True Stereo, 48kHz).irs
libreatmos|LibreAtmos Dynamic + Spatial.json
libreatmos|irs/LibreAtmos Dynamic + Spatial (True Stereo, 48kHz).irs
libreatmos|LibreAtmos Game.json
libreatmos|irs/LibreAtmos Game (True Stereo, 48kHz).irs
libreatmos|LibreAtmos Game + Spatial.json
libreatmos|irs/LibreAtmos Game + Spatial (True Stereo, 48kHz).irs
libreatmos|LibreAtmos Default.json
libreatmos|irs/LibreAtmos Default (True Stereo, 48kHz).irs
libreatmos|LibreAtmos Default + Spatial.json
libreatmos|irs/LibreAtmos Default + Spatial (True Stereo, 48kHz).irs
libreatmos|LibreAtmos On The Go.json
libreatmos|irs/LibreAtmos On The Go (True Stereo, 48kHz).irs
libreatmos|LibreAtmos On The Go + Spatial.json
libreatmos|irs/LibreAtmos On The Go + Spatial (True Stereo, 48kHz).irs
libreatmos|LibreAtmos Movie.json
libreatmos|irs/LibreAtmos Movie (True Stereo, 48kHz).irs
libreatmos|LibreAtmos Movie + Spatial.json
libreatmos|irs/LibreAtmos Movie + Spatial (True Stereo, 48kHz).irs
libreatmos|LibreAtmos Music.json
libreatmos|irs/LibreAtmos Music (Stereo, 48kHz).irs
libreatmos|LibreAtmos Music + Spatial.json
libreatmos|irs/LibreAtmos Music + Spatial (Stereo, 48kHz).irs
flora|FLORA Cinema.json
flora|irs/FLORA Cinema (True Stereo, 48kHz).irs
flora|FLORA Music.json
flora|irs/FLORA Music (True Stereo, 48kHz).irs
orchard|ORCHARD Game Dry.json
orchard|irs/ORCHARD Game Dry (True Stereo, 48kHz).irs
orchard|ORCHARD Game.json
orchard|irs/ORCHARD Game (True Stereo, 48kHz).irs
orchard|ORCHARD General Dry.json
orchard|irs/ORCHARD General Dry (True Stereo, 48kHz).irs
orchard|ORCHARD General.json
orchard|irs/ORCHARD General (True Stereo, 48kHz).irs
orchard|ORCHARD Movie Dry.json
orchard|irs/ORCHARD Movie Dry (True Stereo, 48kHz).irs
orchard|ORCHARD Movie.json
orchard|irs/ORCHARD Movie (True Stereo, 48kHz).irs
orchard|ORCHARD General Upmix.json
orchard|irs/ORCHARD General Upmix (True Stereo, 48kHz).irs
orchard|ORCHARD Movie Upmix.json
orchard|irs/ORCHARD Movie Upmix (True Stereo, 48kHz).irs
aquila|AQUILA Default.json
aquila|irs/AQUILA Default (True Stereo, 48kHz).irs
aquila|AQUILA Game 1.json
aquila|irs/AQUILA Game 1 (True Stereo, 48kHz).irs
aquila|AQUILA Game 2.json
aquila|irs/AQUILA Game 2 (True Stereo, 48kHz).irs
aquila|AQUILA Movie.json
aquila|irs/AQUILA Movie (True Stereo, 48kHz).irs
aquila|AQUILA Music.json
aquila|irs/AQUILA Music (True Stereo, 48kHz).irs
delta|DELTA HD Earbud.json
delta|irs/DELTA HD Earbud (Stereo, 48kHz).irs
delta|DELTA Surround.json
delta|irs/DELTA Surround (True Stereo, 48kHz).irs
delta|DELTA Crossfeed.json
delta|irs/DELTA Crossfeed (True Stereo, 48kHz).irs
libreholo|LibreHolo Movie.json
libreholo|irs/LibreHolo Movie (True Stereo, 48kHz).irs
libreholo|LibreHolo Movie Quiet.json
libreholo|irs/LibreHolo Movie Quiet (True Stereo, 48kHz).irs
libreholo|LibreHolo Music.json
libreholo|irs/LibreHolo Music (True Stereo, 48kHz).irs
librespatial|LibreSpatial.json
librespatial|irs/LibreSpatial (Stereo, 48kHz).irs
libredecibel|LibreDecibel.json
libredecibel|irs/LibreDecibel (True Stereo, 48kHz).irs
rice|RICE Spatial.json
rice|irs/RICE Spatial (True Stereo, 48kHz).irs
measured|TH Koeln KU100 HRTF.json
measured|irs/TH Koeln KU100 HRTF (True Stereo, 48kHz).irs
measured|FABIAN HRTF (TU Berlin).json
measured|irs/FABIAN HRTF (HATO 0, True Stereo, 48kHz).irs
measured|WDR Control Room BRIR (KU100).json
measured|irs/WDR Control Room 1 BRIR (KU100, True Stereo, 48kHz).irs
headphone-eq|Austrian Audio Hi-X15.json
headphone-eq|KZ ZS10 Pro.json
input|input/Voice Noise Suppression.json
input|input/Voice Broadcast.json
# END MANIFEST
MANIFEST_EOF
}

# Menu: entry N is MENU_GROUPS[N-1] / MENU_LABELS[N-1]. "all" selects every
# manifest entry, "uninstall" removes them, anything else is a manifest group.
MENU_GROUPS=(
    all hesuvi crossfeed efotech kemar ari gentledynamics aurora cupertino
    ircam utility binaural libreatmos flora orchard aquila delta libreholo
    librespatial libredecibel rice measured headphone-eq input uninstall
)
MENU_LABELS=(
    "Install all presets (output and input)"
    "Install all HeSuVi virtualization presets"
    "Install Synthetic Spherical Crossfeed preset"
    "Install all EFOtech MLV headphone virtualization presets"
    "Install MIT KEMAR HRTF (SOFA) preset"
    "Install ARI HRTF (SOFA) preset"
    "Install all GentleDynamics presets"
    "Install Aurora Immersive preset"
    "Install Cupertino Laptop Speakers preset"
    "Install IRCAM LISTEN HRTF (Subject 1002) preset"
    "Install all Utility & Effects presets (Night Listening, Levelizer, Mono Sum, Tiny Speaker Rescue, Analog Warmth, Concert Hall, Movie Dialogue Boost, Reference Transparency)"
    "Install Synthetic Binaural Room preset"
    "Install all LibreAtmos presets (LibreAtmos + 12 profile variants)"
    "Install FLORA presets (Cinema/Music)"
    "Install all ORCHARD presets (8 presets)"
    "Install all AQUILA presets (5 presets)"
    "Install all DELTA presets (HD Earbud, Surround, Crossfeed)"
    "Install all LibreHolo presets (Movie, Movie Quiet, Music)"
    "Install LibreSpatial preset"
    "Install LibreDecibel preset"
    "Install RICE Spatial preset"
    "Install measured HRTF/BRIR presets (TH Koeln KU100, FABIAN, WDR Control Room)"
    "Install headphone EQ presets (Austrian Audio Hi-X15, KZ ZS10 Pro)"
    "Install microphone (input) presets (Voice Noise Suppression, Voice Broadcast)"
    "Uninstall all presets installed by this script"
)

ACTION=""
ASSUME_YES=0
FORCE_FLATPAK=0
PRESETS_DIRECTORY=""
TMP_FILE=""
FAILED=()

usage() {
    local i
    cat <<EOF
Usage: ${0##*/} [options] [choice]

Choice (omit it for the interactive menu; required when stdin is not a TTY):
EOF
    for i in "${!MENU_LABELS[@]}"; do
        printf '  %2d  %-15s %s\n' "$((i + 1))" "${MENU_GROUPS[i]}" "${MENU_LABELS[i]}"
    done
    cat <<EOF

Options:
  --ref <tag|branch>  Git ref to download from (default: main,
                      or \$EASYEFFECTS_PRESETS_REF)
  --flatpak           Use the Flatpak data directory even if native
                      EasyEffects is installed too
  -y, --yes           Do not ask for confirmation when uninstalling
  -h, --help          Show this help

Environment:
  EASYEFFECTS_PRESETS_REF       same as --ref
  EASYEFFECTS_PRESETS_BASE_URL  override the whole base URL
                                (default: https://raw.githubusercontent.com/${REPO_SLUG}/<ref>)

Examples:
  ${0##*/} all
  ${0##*/} 3
  ${0##*/} --ref v1.0 hesuvi
  ${0##*/} --yes uninstall
EOF
}

die() {
    echo "Error! $*" >&2
    exit 1
}

cleanup() {
    if [ -n "$TMP_FILE" ]; then
        rm -f -- "$TMP_FILE"
    fi
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

# Percent-encode a repo-relative path (keeps "/" as is), pure bash.
urlencode() {
    local LC_ALL=C
    local s="$1" out="" c i
    for ((i = 0; i < ${#s}; i++)); do
        c="${s:i:1}"
        case "$c" in
            [a-zA-Z0-9._~/-]) out+="$c" ;;
            *)
                printf -v c '%%%02X' "'$c"
                out+="$c"
                ;;
        esac
    done
    printf '%s' "$out"
}

# Manifest paths of one group ("all" = every group), one per line.
manifest_paths() {
    local group="$1" g p
    while IFS='|' read -r g p; do
        case "$g" in '' | '#'*) continue ;; esac
        if [ "$group" = all ] || [ "$g" = "$group" ]; then
            printf '%s\n' "$p"
        fi
    done < <(manifest)
}

# Map a repo-relative path to its destination below $PRESETS_DIRECTORY.
dest_for() {
    case "$1" in
        irs/* | input/*) printf '%s/%s' "$PRESETS_DIRECTORY" "$1" ;;
        *) printf '%s/output/%s' "$PRESETS_DIRECTORY" "$1" ;;
    esac
}

check_installation() {
    local flatpak_dir="$HOME/.var/app/$FLATPAK_ID/data/easyeffects"
    local native_dir="${XDG_DATA_HOME:-$HOME/.local/share}/easyeffects"
    local have_flatpak=0 have_native=0

    if command -v flatpak >/dev/null 2>&1 && flatpak info "$FLATPAK_ID" >/dev/null 2>&1; then
        have_flatpak=1
    fi
    if command -v easyeffects >/dev/null 2>&1; then
        have_native=1
    fi

    if [ "$FORCE_FLATPAK" -eq 1 ]; then
        [ "$have_flatpak" -eq 1 ] || die "--flatpak given but the Flatpak $FLATPAK_ID is not installed."
        PRESETS_DIRECTORY="$flatpak_dir"
        echo "Using Flatpak EasyEffects: $PRESETS_DIRECTORY"
    elif [ "$have_native" -eq 1 ]; then
        PRESETS_DIRECTORY="$native_dir"
        if [ "$have_flatpak" -eq 1 ]; then
            echo "Both native and Flatpak EasyEffects found; using native (pass --flatpak for Flatpak): $PRESETS_DIRECTORY"
        else
            echo "Using native EasyEffects: $PRESETS_DIRECTORY"
        fi
    elif [ "$have_flatpak" -eq 1 ]; then
        PRESETS_DIRECTORY="$flatpak_dir"
        echo "Using Flatpak EasyEffects: $PRESETS_DIRECTORY"
    else
        die "Couldn't find EasyEffects (native or Flatpak)!"
    fi
}

# Number of menu entries; read_choice and argument parsing derive from it.
menu_size() {
    printf '%s' "${#MENU_LABELS[@]}"
}

install_menu() {
    local i
    echo "Please select an option (Default=1)"
    for i in "${!MENU_LABELS[@]}"; do
        echo "$((i + 1))) ${MENU_LABELS[i]}"
    done
}

read_choice() {
    local max choice
    max="$(menu_size)"
    while :; do
        if ! read -r -p "> " choice; then
            echo >&2
            die "No input (EOF)."
        fi
        choice="${choice:-1}"
        if [[ $choice =~ ^[0-9]+$ ]] && [ "$((10#$choice))" -ge 1 ] && [ "$((10#$choice))" -le "$max" ]; then
            ACTION="${MENU_GROUPS[$((10#$choice - 1))]}"
            return 0
        fi
        echo "Invalid option! Please input a value between 1 and $max!"
    done
}

# Resolve a command line choice (number, "all", "uninstall" or group name).
resolve_choice() {
    local arg="$1" max g
    max="$(menu_size)"
    if [[ $arg =~ ^[0-9]+$ ]]; then
        if [ "$((10#$arg))" -ge 1 ] && [ "$((10#$arg))" -le "$max" ]; then
            ACTION="${MENU_GROUPS[$((10#$arg - 1))]}"
            return 0
        fi
        echo "Invalid option '$arg'! Please use a value between 1 and $max." >&2
        return 1
    fi
    for g in "${MENU_GROUPS[@]}"; do
        if [ "$arg" = "$g" ]; then
            ACTION="$g"
            return 0
        fi
    done
    echo "Unknown choice '$arg'." >&2
    return 1
}

# Download one repo-relative path to its destination (atomically).
fetch() {
    local path="$1" dest dir
    dest="$(dest_for "$path")"
    dir="${dest%/*}"
    if ! mkdir -p -- "$dir"; then
        echo "FAILED: $path (cannot create $dir)" >&2
        FAILED+=("$path")
        return 1
    fi
    if ! TMP_FILE="$(mktemp -- "$dir/.easyeffects-presets.XXXXXX")"; then
        TMP_FILE=""
        echo "FAILED: $path (cannot create temporary file in $dir)" >&2
        FAILED+=("$path")
        return 1
    fi
    if curl --fail --silent --show-error --location --retry 3 \
        --output "$TMP_FILE" -- "$BASE_URL/$(urlencode "$path")" &&
        chmod 644 -- "$TMP_FILE" &&
        mv -f -- "$TMP_FILE" "$dest"; then
        TMP_FILE=""
        return 0
    fi
    rm -f -- "$TMP_FILE"
    TMP_FILE=""
    echo "FAILED: $path" >&2
    FAILED+=("$path")
    return 1
}

install_presets() {
    local group="$1" path total=0 ok=0
    while IFS= read -r path; do
        total=$((total + 1))
        if fetch "$path"; then
            ok=$((ok + 1))
        fi
    done < <(manifest_paths "$group")

    if [ "$total" -eq 0 ]; then
        die "Nothing to install for '$group'."
    fi
    echo "Installed $ok of $total file(s) into $PRESETS_DIRECTORY"
    if [ "${#FAILED[@]}" -gt 0 ]; then
        echo "Summary: ${#FAILED[@]} file(s) failed to download:" >&2
        printf '  %s\n' "${FAILED[@]}" >&2
        return 1
    fi
    return 0
}

uninstall_presets() {
    local path dest answer removed=0 failed=0

    if [ "$ASSUME_YES" -ne 1 ]; then
        if [ ! -t 0 ]; then
            echo "Refusing to uninstall non-interactively without --yes." >&2
            exit 2
        fi
        read -r -p "Remove all presets listed in the manifest from $PRESETS_DIRECTORY? [y/N] " answer || answer=""
        case "$answer" in
            y | Y | yes | YES | Yes) ;;
            *)
                echo "Aborted."
                return 0
                ;;
        esac
    fi

    while IFS= read -r path; do
        dest="$(dest_for "$path")"
        if [ -e "$dest" ] || [ -L "$dest" ]; then
            if rm -f -- "$dest"; then
                removed=$((removed + 1))
            else
                echo "FAILED: could not remove $dest" >&2
                failed=$((failed + 1))
            fi
        fi
    done < <(manifest_paths all)

    echo "Removed $removed file(s) from $PRESETS_DIRECTORY"
    if [ "$failed" -gt 0 ]; then
        echo "Summary: $failed file(s) could not be removed." >&2
        return 1
    fi
    return 0
}

main() {
    local choice_arg=""

    while [ "$#" -gt 0 ]; do
        case "$1" in
            -h | --help)
                usage
                exit 0
                ;;
            --ref)
                if [ "$#" -lt 2 ]; then
                    echo "--ref needs an argument." >&2
                    exit 2
                fi
                REF="$2"
                shift
                ;;
            --ref=*) REF="${1#--ref=}" ;;
            --flatpak) FORCE_FLATPAK=1 ;;
            -y | --yes) ASSUME_YES=1 ;;
            --)
                shift
                if [ "$#" -gt 0 ]; then
                    choice_arg="$1"
                    shift
                fi
                break
                ;;
            -*)
                echo "Unknown option '$1'." >&2
                usage >&2
                exit 2
                ;;
            *)
                if [ -n "$choice_arg" ]; then
                    echo "Only one choice may be given." >&2
                    usage >&2
                    exit 2
                fi
                choice_arg="$1"
                ;;
        esac
        shift
    done
    if [ "$#" -gt 0 ]; then
        echo "Only one choice may be given." >&2
        usage >&2
        exit 2
    fi

    if [[ ! $REF =~ ^[A-Za-z0-9._/-]+$ ]]; then
        echo "Invalid ref '$REF'." >&2
        exit 2
    fi
    BASE_URL="${BASE_URL:-https://raw.githubusercontent.com/$REPO_SLUG/$REF}"
    BASE_URL="${BASE_URL%/}"

    if [ -n "$choice_arg" ]; then
        resolve_choice "$choice_arg" || {
            usage >&2
            exit 2
        }
    elif [ ! -t 0 ]; then
        usage >&2
        exit 2
    fi

    command -v curl >/dev/null 2>&1 || die "curl is required."
    check_installation

    if [ -z "$ACTION" ]; then
        install_menu
        read_choice
    fi

    if [ "$ACTION" = uninstall ]; then
        uninstall_presets
        return
    fi
    echo "Downloading from $BASE_URL"
    install_presets "$ACTION"
}

main "$@"
