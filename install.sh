#!/usr/bin/env bash
# This script automatically detect the EasyEffects presets directory and installs the presets

GIT_REPOSITORY="https://raw.githubusercontent.com/M0Rf30/easyeffects-presets/main"

check_installation() {
    if command -v flatpak &>/dev/null && flatpak list | grep -q "com.github.wwmm.easyeffects"; then
        PRESETS_DIRECTORY="$HOME/.var/app/com.github.wwmm.easyeffects/data/easyeffects"
    elif command -v easyeffects >/dev/null; then
        PRESETS_DIRECTORY="${XDG_DATA_HOME:-$HOME/.local/share}/easyeffects"
    else
        echo "Error! Couldn't find EasyEffects presets directory!"
        exit 1
    fi
    mkdir -p "$PRESETS_DIRECTORY"
}

check_impulse_response_directory() {
    if [ ! -d "$PRESETS_DIRECTORY/irs" ]; then
        mkdir "$PRESETS_DIRECTORY/irs"
    fi
    if [ ! -d "$PRESETS_DIRECTORY/output" ]; then
        mkdir "$PRESETS_DIRECTORY/output"
    fi
}

read_choice() {
    while :; do
        read -r CHOICE
        if [ -z "$CHOICE" ]; then
            CHOICE=1 #default
        fi
        if [[ $CHOICE =~ ^([1-9]|1[0-3])$ ]]; then
            break
        fi
        echo "Invalid option! Please input a value between 1 and 13!"
    done
}

install_menu() {
    echo "Please select an option for presets installation (Default=1)"
    echo "1) Install all presets"
    echo "2) Install all HeSuVi virtualization presets"
    echo "3) Install Synthetic Spherical Crossfeed preset"
    echo "4) Install all EFOtech MLV headphone virtualization presets"
    echo "5) Install MIT KEMAR HRTF (SOFA) preset"
    echo "6) Install ARI HRTF (SOFA) preset"
    echo "7) Install all GentleDynamics presets"
    echo "8) Install Aurora Immersive preset"
    echo "9) Install Cupertino Laptop Speakers preset"
    echo "10) Install IRCAM LISTEN HRTF (Subject 1002) preset"
    echo "11) Install all Utility & Effects presets (Night Listening, Levelizer, Mono Sum, Tiny Speaker Rescue, Analog Warmth, Concert Hall, Movie Dialogue Boost)"
    echo "12) Install Synthetic Binaural Room preset"
    echo "13) Install LibreAtmos preset"
}

install_presets() {
    case $CHOICE in
        1)
            echo "Installing Synthetic Spherical Crossfeed preset..."
            curl --fail "$GIT_REPOSITORY/Synthetic%20Spherical%20Crossfeed.json" --output "$PRESETS_DIRECTORY/output/Synthetic Spherical Crossfeed.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/Synthetic%20Spherical-Head%20Crossfeed%20(48kHz).irs" --output "$PRESETS_DIRECTORY/irs/Synthetic Spherical-Head Crossfeed (48kHz).irs" --silent
            echo "Installing Synthetic Binaural Room preset..."
            curl --fail "$GIT_REPOSITORY/Synthetic%20Binaural%20Room.json" --output "$PRESETS_DIRECTORY/output/Synthetic Binaural Room.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/Synthetic%20Binaural%20Room%20(Structural%20HRTF%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/Synthetic Binaural Room (Structural HRTF, 48kHz).irs" --silent
            echo "Installing LibreAtmos preset..."
            curl --fail "$GIT_REPOSITORY/LibreAtmos.json" --output "$PRESETS_DIRECTORY/output/LibreAtmos.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/LibreAtmos%20(Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/LibreAtmos (Stereo, 48kHz).irs" --silent
            echo "Installing HeSuVi Atmos preset..."
            curl --fail "$GIT_REPOSITORY/HeSuVi%20Atmos.json" --output "$PRESETS_DIRECTORY/output/HeSuVi Atmos.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20Atmos%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi Atmos (True Stereo, 48kHz).irs" --silent
            echo "Installing HeSuVi DTS Headphone X preset..."
            curl --fail "$GIT_REPOSITORY/HeSuVi%20DTS%20Headphone%20X.json" --output "$PRESETS_DIRECTORY/output/HeSuVi DTS Headphone X.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20DTS%20Headphone%20X%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi DTS Headphone X (True Stereo, 48kHz).irs" --silent
            echo "Installing HeSuVi GSX preset..."
            curl --fail "$GIT_REPOSITORY/HeSuVi%20GSX.json" --output "$PRESETS_DIRECTORY/output/HeSuVi GSX.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20GSX%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi GSX (True Stereo, 48kHz).irs" --silent
            echo "Installing HeSuVi CMSS-3D Entertainment preset..."
            curl --fail "$GIT_REPOSITORY/HeSuVi%20CMSS-3D%20Entertainment.json" --output "$PRESETS_DIRECTORY/output/HeSuVi CMSS-3D Entertainment.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20CMSS-3D%20Entertainment%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi CMSS-3D Entertainment (True Stereo, 48kHz).irs" --silent
            echo "Installing HeSuVi CMSS-3D Game preset..."
            curl --fail "$GIT_REPOSITORY/HeSuVi%20CMSS-3D%20Game.json" --output "$PRESETS_DIRECTORY/output/HeSuVi CMSS-3D Game.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20CMSS-3D%20Game%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi CMSS-3D Game (True Stereo, 48kHz).irs" --silent
            echo "Installing HeSuVi CMSS-3D RX+ preset..."
            curl --fail "$GIT_REPOSITORY/HeSuVi%20CMSS-3D%20RX%2B.json" --output "$PRESETS_DIRECTORY/output/HeSuVi CMSS-3D RX+.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20CMSS-3D%20RX%2B%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi CMSS-3D RX+ (True Stereo, 48kHz).irs" --silent
            echo "Installing HeSuVi Dolby Headphone preset..."
            curl --fail "$GIT_REPOSITORY/HeSuVi%20Dolby%20Headphone.json" --output "$PRESETS_DIRECTORY/output/HeSuVi Dolby Headphone.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20Dolby%20Headphone%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi Dolby Headphone (True Stereo, 48kHz).irs" --silent
            echo "Installing HeSuVi Dolby Home Theater preset..."
            curl --fail "$GIT_REPOSITORY/HeSuVi%20Dolby%20Home%20Theater.json" --output "$PRESETS_DIRECTORY/output/HeSuVi Dolby Home Theater.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20Dolby%20Home%20Theater%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi Dolby Home Theater (True Stereo, 48kHz).irs" --silent
            echo "Installing HeSuVi DS3D preset..."
            curl --fail "$GIT_REPOSITORY/HeSuVi%20DS3D.json" --output "$PRESETS_DIRECTORY/output/HeSuVi DS3D.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20DS3D%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi DS3D (True Stereo, 48kHz).irs" --silent
            echo "Installing HeSuVi DVS preset..."
            curl --fail "$GIT_REPOSITORY/HeSuVi%20DVS.json" --output "$PRESETS_DIRECTORY/output/HeSuVi DVS.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20DVS%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi DVS (True Stereo, 48kHz).irs" --silent
            echo "Installing HeSuVi Nahimic preset..."
            curl --fail "$GIT_REPOSITORY/HeSuVi%20Nahimic.json" --output "$PRESETS_DIRECTORY/output/HeSuVi Nahimic.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20Nahimic%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi Nahimic (True Stereo, 48kHz).irs" --silent
            echo "Installing HeSuVi Windows Sonic preset..."
            curl --fail "$GIT_REPOSITORY/HeSuVi%20Windows%20Sonic.json" --output "$PRESETS_DIRECTORY/output/HeSuVi Windows Sonic.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20Windows%20Sonic%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi Windows Sonic (True Stereo, 48kHz).irs" --silent
            echo "Installing HeSuVi Out Of Your Head preset..."
            curl --fail "$GIT_REPOSITORY/HeSuVi%20Out%20Of%20Your%20Head.json" --output "$PRESETS_DIRECTORY/output/HeSuVi Out Of Your Head.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20Out%20Of%20Your%20Head%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi Out Of Your Head (True Stereo, 48kHz).irs" --silent
            echo "Installing HeSuVi Waves preset..."
            curl --fail "$GIT_REPOSITORY/HeSuVi%20Waves.json" --output "$PRESETS_DIRECTORY/output/HeSuVi Waves.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20Waves%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi Waves (True Stereo, 48kHz).irs" --silent
            echo "Installing HeSuVi Sound Blaster SBX preset..."
            curl --fail "$GIT_REPOSITORY/HeSuVi%20Sound%20Blaster%20SBX.json" --output "$PRESETS_DIRECTORY/output/HeSuVi Sound Blaster SBX.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20Sound%20Blaster%20SBX%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi Sound Blaster SBX (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20Dolby%20Headphone%20%2B%2B.json" --output "$PRESETS_DIRECTORY/output/HeSuVi Dolby Headphone ++.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20Dolby%20Headphone%20%2B%2B%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi Dolby Headphone ++ (True Stereo, 48kHz).irs" --silent
            echo "Installing HeSuVi DS3D + preset..."
            curl --fail "$GIT_REPOSITORY/HeSuVi%20DS3D%20%2B.json" --output "$PRESETS_DIRECTORY/output/HeSuVi DS3D +.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20DS3D%20%2B%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi DS3D + (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20DS3D%20%2B%2B.json" --output "$PRESETS_DIRECTORY/output/HeSuVi DS3D ++.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20DS3D%20%2B%2B%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi DS3D ++ (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20DS3D%20%2B%2B%2B.json" --output "$PRESETS_DIRECTORY/output/HeSuVi DS3D +++.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20DS3D%20%2B%2B%2B%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi DS3D +++ (True Stereo, 48kHz).irs" --silent
            echo "Installing HeSuVi GSX + preset..."
            curl --fail "$GIT_REPOSITORY/HeSuVi%20GSX%20%2B.json" --output "$PRESETS_DIRECTORY/output/HeSuVi GSX +.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20GSX%20%2B%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi GSX + (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20GSX%20%2B%2B.json" --output "$PRESETS_DIRECTORY/output/HeSuVi GSX ++.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20GSX%20%2B%2B%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi GSX ++ (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20DVS%20%2B.json" --output "$PRESETS_DIRECTORY/output/HeSuVi DVS +.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20DVS%20%2B%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi DVS + (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20Sound%20Blaster%20SBX%2033.json" --output "$PRESETS_DIRECTORY/output/HeSuVi Sound Blaster SBX 33.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20Sound%20Blaster%20SBX%2033%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi Sound Blaster SBX 33 (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20Sound%20Blaster%20SBX%2067.json" --output "$PRESETS_DIRECTORY/output/HeSuVi Sound Blaster SBX 67.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20Sound%20Blaster%20SBX%2067%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi Sound Blaster SBX 67 (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20Windows%20Sonic%20%2B.json" --output "$PRESETS_DIRECTORY/output/HeSuVi Windows Sonic +.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20Windows%20Sonic%20%2B%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi Windows Sonic + (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20Out%20Of%20Your%20Head%202.json" --output "$PRESETS_DIRECTORY/output/HeSuVi Out Of Your Head 2.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20Out%20Of%20Your%20Head%202%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi Out Of Your Head 2 (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20SSC%20Dublin.json" --output "$PRESETS_DIRECTORY/output/HeSuVi SSC Dublin.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20SSC%20Dublin%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi SSC Dublin (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20SSC%20New%20York.json" --output "$PRESETS_DIRECTORY/output/HeSuVi SSC New York.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20SSC%20New%20York%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi SSC New York (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20SSC%20New%20York%20%2B.json" --output "$PRESETS_DIRECTORY/output/HeSuVi SSC New York +.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20SSC%20New%20York%20%2B%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi SSC New York + (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20SSC%20Sydney.json" --output "$PRESETS_DIRECTORY/output/HeSuVi SSC Sydney.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20SSC%20Sydney%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi SSC Sydney (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20SSC%20Sydney%20%2B.json" --output "$PRESETS_DIRECTORY/output/HeSuVi SSC Sydney +.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20SSC%20Sydney%20%2B%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi SSC Sydney + (True Stereo, 48kHz).irs" --silent
            echo "Installing HeSuVi SSC Hù preset..."
            curl --fail "$GIT_REPOSITORY/HeSuVi%20SSC%20H%C3%B9.json" --output "$PRESETS_DIRECTORY/output/HeSuVi SSC Hù.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20SSC%20H%C3%B9%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi SSC Hù (True Stereo, 48kHz).irs" --silent
            echo "Installing HeSuVi SSC Hù+ preset..."
            curl --fail "$GIT_REPOSITORY/HeSuVi%20SSC%20H%C3%B9%2B.json" --output "$PRESETS_DIRECTORY/output/HeSuVi SSC Hù+.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20SSC%20H%C3%B9%2B%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi SSC Hù+ (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20OpenAL%20%2B.json" --output "$PRESETS_DIRECTORY/output/HeSuVi OpenAL +.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20OpenAL%20%2B%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi OpenAL + (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20OpenAL%20%2B%2B.json" --output "$PRESETS_DIRECTORY/output/HeSuVi OpenAL ++.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20OpenAL%20%2B%2B%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi OpenAL ++ (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20OpenAL%20%2B%2B%2B.json" --output "$PRESETS_DIRECTORY/output/HeSuVi OpenAL +++.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20OpenAL%20%2B%2B%2B%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi OpenAL +++ (True Stereo, 48kHz).irs" --silent
            echo "Installing EFOtech MLV 00256 preset..."
            curl --fail "$GIT_REPOSITORY/EFOtech%20MLV%2000256.json" --output "$PRESETS_DIRECTORY/output/EFOtech MLV 00256.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/EFOtech%20MLV%2000256%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/EFOtech MLV 00256 (True Stereo, 48kHz).irs" --silent
            echo "Installing EFOtech MLV 00512 preset..."
            curl --fail "$GIT_REPOSITORY/EFOtech%20MLV%2000512.json" --output "$PRESETS_DIRECTORY/output/EFOtech MLV 00512.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/EFOtech%20MLV%2000512%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/EFOtech MLV 00512 (True Stereo, 48kHz).irs" --silent
            echo "Installing EFOtech MLV 01024 preset..."
            curl --fail "$GIT_REPOSITORY/EFOtech%20MLV%2001024.json" --output "$PRESETS_DIRECTORY/output/EFOtech MLV 01024.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/EFOtech%20MLV%2001024%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/EFOtech MLV 01024 (True Stereo, 48kHz).irs" --silent
            echo "Installing EFOtech MLV 02048 preset..."
            curl --fail "$GIT_REPOSITORY/EFOtech%20MLV%2002048.json" --output "$PRESETS_DIRECTORY/output/EFOtech MLV 02048.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/EFOtech%20MLV%2002048%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/EFOtech MLV 02048 (True Stereo, 48kHz).irs" --silent
            echo "Installing EFOtech MLV 04096 preset..."
            curl --fail "$GIT_REPOSITORY/EFOtech%20MLV%2004096.json" --output "$PRESETS_DIRECTORY/output/EFOtech MLV 04096.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/EFOtech%20MLV%2004096%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/EFOtech MLV 04096 (True Stereo, 48kHz).irs" --silent
            echo "Installing EFOtech MLV 22000 preset..."
            curl --fail "$GIT_REPOSITORY/EFOtech%20MLV%2022000.json" --output "$PRESETS_DIRECTORY/output/EFOtech MLV 22000.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/EFOtech%20MLV%2022000%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/EFOtech MLV 22000 (True Stereo, 48kHz).irs" --silent
            echo "Installing MIT KEMAR HRTF (SOFA) preset..."
            curl --fail "$GIT_REPOSITORY/MIT%20KEMAR%20HRTF%20(SOFA).json" --output "$PRESETS_DIRECTORY/output/MIT KEMAR HRTF (SOFA).json" --silent
            curl --fail "$GIT_REPOSITORY/irs/MIT%20KEMAR%20HRTF%20(Normal%20Pinna).sofa" --output "$PRESETS_DIRECTORY/irs/MIT KEMAR HRTF (Normal Pinna).sofa" --silent
            echo "Installing ARI HRTF (SOFA) preset..."
            curl --fail "$GIT_REPOSITORY/ARI%20HRTF%20(SOFA).json" --output "$PRESETS_DIRECTORY/output/ARI HRTF (SOFA).json" --silent
            curl --fail "$GIT_REPOSITORY/irs/ARI%20HRTF%20(Subject%20NH2%2C%20DTF).sofa" --output "$PRESETS_DIRECTORY/irs/ARI HRTF (Subject NH2, DTF).sofa" --silent
            echo "Installing GentleDynamics preset..."
            curl --fail "$GIT_REPOSITORY/GentleDynamics.json" --output "$PRESETS_DIRECTORY/output/GentleDynamics.json" --silent
            echo "Installing GentleDynamics Feather Loudness preset..."
            curl --fail "$GIT_REPOSITORY/GentleDynamics%20Feather%20Loudness.json" --output "$PRESETS_DIRECTORY/output/GentleDynamics Feather Loudness.json" --silent
            echo "Installing GentleDynamics Dialogue Clarity Engine preset..."
            curl --fail "$GIT_REPOSITORY/GentleDynamics%20Dialogue%20Clarity%20Engine.json" --output "$PRESETS_DIRECTORY/output/GentleDynamics Dialogue Clarity Engine.json" --silent
            echo "Installing Aurora Immersive preset..."
            curl --fail "$GIT_REPOSITORY/Aurora%20Immersive.json" --output "$PRESETS_DIRECTORY/output/Aurora Immersive.json" --silent
            echo "Installing Cupertino Laptop Speakers preset..."
            curl --fail "$GIT_REPOSITORY/Cupertino%20Laptop%20Speakers.json" --output "$PRESETS_DIRECTORY/output/Cupertino Laptop Speakers.json" --silent
            echo "Installing new HeSuVi virtualization presets (Flux HEar, Razer, OpenAL, SBX 100)..."
            curl --fail "$GIT_REPOSITORY/HeSuVi%20Flux%20HEar.json" --output "$PRESETS_DIRECTORY/output/HeSuVi Flux HEar.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20Flux%20HEar%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi Flux HEar (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20Razer%20Surround.json" --output "$PRESETS_DIRECTORY/output/HeSuVi Razer Surround.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20Razer%20Surround%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi Razer Surround (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20Razer%20Surround%20Bass%20Fix.json" --output "$PRESETS_DIRECTORY/output/HeSuVi Razer Surround Bass Fix.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20Razer%20Surround%20Bass%20Fix%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi Razer Surround Bass Fix (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20OpenAL%20CIAIR.json" --output "$PRESETS_DIRECTORY/output/HeSuVi OpenAL CIAIR.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20OpenAL%20CIAIR%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi OpenAL CIAIR (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20OpenAL%20CIAIR%20Wide.json" --output "$PRESETS_DIRECTORY/output/HeSuVi OpenAL CIAIR Wide.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20OpenAL%20CIAIR%20Wide%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi OpenAL CIAIR Wide (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20OpenAL%20Default.json" --output "$PRESETS_DIRECTORY/output/HeSuVi OpenAL Default.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20OpenAL%20Default%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi OpenAL Default (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20Sound%20Blaster%20SBX%20100.json" --output "$PRESETS_DIRECTORY/output/HeSuVi Sound Blaster SBX 100.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20Sound%20Blaster%20SBX%20100%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi Sound Blaster SBX 100 (True Stereo, 48kHz).irs" --silent
            echo "Installing IRCAM LISTEN HRTF (Subject 1002) preset..."
            curl --fail "$GIT_REPOSITORY/IRCAM%20LISTEN%20HRTF%20(Subject%201002).json" --output "$PRESETS_DIRECTORY/output/IRCAM LISTEN HRTF (Subject 1002).json" --silent
            curl --fail "$GIT_REPOSITORY/irs/IRCAM%20LISTEN%20HRTF%20(Subject%201002%2C%20True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/IRCAM LISTEN HRTF (Subject 1002, True Stereo, 48kHz).irs" --silent
            echo "Installing Utility & Effects presets (Night Listening, Levelizer, Mono Sum, Tiny Speaker Rescue, Analog Warmth, Concert Hall, Movie Dialogue Boost)..."
            curl --fail "$GIT_REPOSITORY/Night%20Listening.json" --output "$PRESETS_DIRECTORY/output/Night Listening.json" --silent
            curl --fail "$GIT_REPOSITORY/Levelizer%20(EBU%20R128).json" --output "$PRESETS_DIRECTORY/output/Levelizer (EBU R128).json" --silent
            curl --fail "$GIT_REPOSITORY/Mono%20Sum%20(Accessibility).json" --output "$PRESETS_DIRECTORY/output/Mono Sum (Accessibility).json" --silent
            curl --fail "$GIT_REPOSITORY/Tiny%20Speaker%20Rescue.json" --output "$PRESETS_DIRECTORY/output/Tiny Speaker Rescue.json" --silent
            curl --fail "$GIT_REPOSITORY/Analog%20Warmth.json" --output "$PRESETS_DIRECTORY/output/Analog Warmth.json" --silent
            curl --fail "$GIT_REPOSITORY/Concert%20Hall.json" --output "$PRESETS_DIRECTORY/output/Concert Hall.json" --silent
            curl --fail "$GIT_REPOSITORY/Movie%20Dialogue%20Boost.json" --output "$PRESETS_DIRECTORY/output/Movie Dialogue Boost.json" --silent
            ;;
        2)
            echo "Installing all HeSuVi virtualization presets..."
            echo "Installing HeSuVi Atmos preset..."
            curl --fail "$GIT_REPOSITORY/HeSuVi%20Atmos.json" --output "$PRESETS_DIRECTORY/output/HeSuVi Atmos.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20Atmos%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi Atmos (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20DTS%20Headphone%20X.json" --output "$PRESETS_DIRECTORY/output/HeSuVi DTS Headphone X.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20DTS%20Headphone%20X%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi DTS Headphone X (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20GSX.json" --output "$PRESETS_DIRECTORY/output/HeSuVi GSX.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20GSX%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi GSX (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20CMSS-3D%20Entertainment.json" --output "$PRESETS_DIRECTORY/output/HeSuVi CMSS-3D Entertainment.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20CMSS-3D%20Entertainment%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi CMSS-3D Entertainment (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20CMSS-3D%20Game.json" --output "$PRESETS_DIRECTORY/output/HeSuVi CMSS-3D Game.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20CMSS-3D%20Game%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi CMSS-3D Game (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20CMSS-3D%20RX%2B.json" --output "$PRESETS_DIRECTORY/output/HeSuVi CMSS-3D RX+.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20CMSS-3D%20RX%2B%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi CMSS-3D RX+ (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20Dolby%20Headphone.json" --output "$PRESETS_DIRECTORY/output/HeSuVi Dolby Headphone.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20Dolby%20Headphone%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi Dolby Headphone (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20Dolby%20Home%20Theater.json" --output "$PRESETS_DIRECTORY/output/HeSuVi Dolby Home Theater.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20Dolby%20Home%20Theater%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi Dolby Home Theater (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20DS3D.json" --output "$PRESETS_DIRECTORY/output/HeSuVi DS3D.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20DS3D%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi DS3D (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20DVS.json" --output "$PRESETS_DIRECTORY/output/HeSuVi DVS.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20DVS%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi DVS (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20Nahimic.json" --output "$PRESETS_DIRECTORY/output/HeSuVi Nahimic.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20Nahimic%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi Nahimic (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20Windows%20Sonic.json" --output "$PRESETS_DIRECTORY/output/HeSuVi Windows Sonic.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20Windows%20Sonic%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi Windows Sonic (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20Out%20Of%20Your%20Head.json" --output "$PRESETS_DIRECTORY/output/HeSuVi Out Of Your Head.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20Out%20Of%20Your%20Head%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi Out Of Your Head (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20Waves.json" --output "$PRESETS_DIRECTORY/output/HeSuVi Waves.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20Waves%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi Waves (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20Sound%20Blaster%20SBX.json" --output "$PRESETS_DIRECTORY/output/HeSuVi Sound Blaster SBX.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20Sound%20Blaster%20SBX%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi Sound Blaster SBX (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20Dolby%20Headphone%20%2B%2B.json" --output "$PRESETS_DIRECTORY/output/HeSuVi Dolby Headphone ++.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20Dolby%20Headphone%20%2B%2B%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi Dolby Headphone ++ (True Stereo, 48kHz).irs" --silent
            echo "Installing HeSuVi DS3D + preset..."
            curl --fail "$GIT_REPOSITORY/HeSuVi%20DS3D%20%2B.json" --output "$PRESETS_DIRECTORY/output/HeSuVi DS3D +.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20DS3D%20%2B%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi DS3D + (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20DS3D%20%2B%2B.json" --output "$PRESETS_DIRECTORY/output/HeSuVi DS3D ++.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20DS3D%20%2B%2B%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi DS3D ++ (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20DS3D%20%2B%2B%2B.json" --output "$PRESETS_DIRECTORY/output/HeSuVi DS3D +++.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20DS3D%20%2B%2B%2B%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi DS3D +++ (True Stereo, 48kHz).irs" --silent
            echo "Installing HeSuVi GSX + preset..."
            curl --fail "$GIT_REPOSITORY/HeSuVi%20GSX%20%2B.json" --output "$PRESETS_DIRECTORY/output/HeSuVi GSX +.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20GSX%20%2B%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi GSX + (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20GSX%20%2B%2B.json" --output "$PRESETS_DIRECTORY/output/HeSuVi GSX ++.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20GSX%20%2B%2B%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi GSX ++ (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20DVS%20%2B.json" --output "$PRESETS_DIRECTORY/output/HeSuVi DVS +.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20DVS%20%2B%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi DVS + (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20Sound%20Blaster%20SBX%2033.json" --output "$PRESETS_DIRECTORY/output/HeSuVi Sound Blaster SBX 33.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20Sound%20Blaster%20SBX%2033%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi Sound Blaster SBX 33 (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20Sound%20Blaster%20SBX%2067.json" --output "$PRESETS_DIRECTORY/output/HeSuVi Sound Blaster SBX 67.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20Sound%20Blaster%20SBX%2067%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi Sound Blaster SBX 67 (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20Windows%20Sonic%20%2B.json" --output "$PRESETS_DIRECTORY/output/HeSuVi Windows Sonic +.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20Windows%20Sonic%20%2B%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi Windows Sonic + (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20Out%20Of%20Your%20Head%202.json" --output "$PRESETS_DIRECTORY/output/HeSuVi Out Of Your Head 2.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20Out%20Of%20Your%20Head%202%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi Out Of Your Head 2 (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20SSC%20Dublin.json" --output "$PRESETS_DIRECTORY/output/HeSuVi SSC Dublin.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20SSC%20Dublin%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi SSC Dublin (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20SSC%20New%20York.json" --output "$PRESETS_DIRECTORY/output/HeSuVi SSC New York.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20SSC%20New%20York%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi SSC New York (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20SSC%20New%20York%20%2B.json" --output "$PRESETS_DIRECTORY/output/HeSuVi SSC New York +.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20SSC%20New%20York%20%2B%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi SSC New York + (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20SSC%20Sydney.json" --output "$PRESETS_DIRECTORY/output/HeSuVi SSC Sydney.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20SSC%20Sydney%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi SSC Sydney (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20SSC%20Sydney%20%2B.json" --output "$PRESETS_DIRECTORY/output/HeSuVi SSC Sydney +.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20SSC%20Sydney%20%2B%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi SSC Sydney + (True Stereo, 48kHz).irs" --silent
            echo "Installing HeSuVi SSC Hù preset..."
            curl --fail "$GIT_REPOSITORY/HeSuVi%20SSC%20H%C3%B9.json" --output "$PRESETS_DIRECTORY/output/HeSuVi SSC Hù.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20SSC%20H%C3%B9%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi SSC Hù (True Stereo, 48kHz).irs" --silent
            echo "Installing HeSuVi SSC Hù+ preset..."
            curl --fail "$GIT_REPOSITORY/HeSuVi%20SSC%20H%C3%B9%2B.json" --output "$PRESETS_DIRECTORY/output/HeSuVi SSC Hù+.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20SSC%20H%C3%B9%2B%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi SSC Hù+ (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20OpenAL%20%2B.json" --output "$PRESETS_DIRECTORY/output/HeSuVi OpenAL +.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20OpenAL%20%2B%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi OpenAL + (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20OpenAL%20%2B%2B.json" --output "$PRESETS_DIRECTORY/output/HeSuVi OpenAL ++.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20OpenAL%20%2B%2B%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi OpenAL ++ (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20OpenAL%20%2B%2B%2B.json" --output "$PRESETS_DIRECTORY/output/HeSuVi OpenAL +++.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20OpenAL%20%2B%2B%2B%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi OpenAL +++ (True Stereo, 48kHz).irs" --silent
            echo "Installing new HeSuVi virtualization presets (Flux HEar, Razer, OpenAL, SBX 100)..."
            curl --fail "$GIT_REPOSITORY/HeSuVi%20Flux%20HEar.json" --output "$PRESETS_DIRECTORY/output/HeSuVi Flux HEar.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20Flux%20HEar%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi Flux HEar (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20Razer%20Surround.json" --output "$PRESETS_DIRECTORY/output/HeSuVi Razer Surround.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20Razer%20Surround%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi Razer Surround (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20Razer%20Surround%20Bass%20Fix.json" --output "$PRESETS_DIRECTORY/output/HeSuVi Razer Surround Bass Fix.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20Razer%20Surround%20Bass%20Fix%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi Razer Surround Bass Fix (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20OpenAL%20CIAIR.json" --output "$PRESETS_DIRECTORY/output/HeSuVi OpenAL CIAIR.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20OpenAL%20CIAIR%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi OpenAL CIAIR (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20OpenAL%20CIAIR%20Wide.json" --output "$PRESETS_DIRECTORY/output/HeSuVi OpenAL CIAIR Wide.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20OpenAL%20CIAIR%20Wide%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi OpenAL CIAIR Wide (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20OpenAL%20Default.json" --output "$PRESETS_DIRECTORY/output/HeSuVi OpenAL Default.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20OpenAL%20Default%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi OpenAL Default (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/HeSuVi%20Sound%20Blaster%20SBX%20100.json" --output "$PRESETS_DIRECTORY/output/HeSuVi Sound Blaster SBX 100.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/HeSuVi%20Sound%20Blaster%20SBX%20100%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/HeSuVi Sound Blaster SBX 100 (True Stereo, 48kHz).irs" --silent
            ;;

        3)
            echo "Installing Synthetic Spherical Crossfeed preset..."
            curl --fail "$GIT_REPOSITORY/Synthetic%20Spherical%20Crossfeed.json" --output "$PRESETS_DIRECTORY/output/Synthetic Spherical Crossfeed.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/Synthetic%20Spherical-Head%20Crossfeed%20(48kHz).irs" --output "$PRESETS_DIRECTORY/irs/Synthetic Spherical-Head Crossfeed (48kHz).irs" --silent
            ;;

        4)
            echo "Installing all EFOtech MLV headphone virtualization presets..."
            curl --fail "$GIT_REPOSITORY/EFOtech%20MLV%2000256.json" --output "$PRESETS_DIRECTORY/output/EFOtech MLV 00256.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/EFOtech%20MLV%2000256%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/EFOtech MLV 00256 (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/EFOtech%20MLV%2000512.json" --output "$PRESETS_DIRECTORY/output/EFOtech MLV 00512.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/EFOtech%20MLV%2000512%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/EFOtech MLV 00512 (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/EFOtech%20MLV%2001024.json" --output "$PRESETS_DIRECTORY/output/EFOtech MLV 01024.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/EFOtech%20MLV%2001024%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/EFOtech MLV 01024 (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/EFOtech%20MLV%2002048.json" --output "$PRESETS_DIRECTORY/output/EFOtech MLV 02048.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/EFOtech%20MLV%2002048%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/EFOtech MLV 02048 (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/EFOtech%20MLV%2004096.json" --output "$PRESETS_DIRECTORY/output/EFOtech MLV 04096.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/EFOtech%20MLV%2004096%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/EFOtech MLV 04096 (True Stereo, 48kHz).irs" --silent
            curl --fail "$GIT_REPOSITORY/EFOtech%20MLV%2022000.json" --output "$PRESETS_DIRECTORY/output/EFOtech MLV 22000.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/EFOtech%20MLV%2022000%20(True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/EFOtech MLV 22000 (True Stereo, 48kHz).irs" --silent
            ;;

        5)
            echo "Installing MIT KEMAR HRTF (SOFA) preset..."
            curl --fail "$GIT_REPOSITORY/MIT%20KEMAR%20HRTF%20(SOFA).json" --output "$PRESETS_DIRECTORY/output/MIT KEMAR HRTF (SOFA).json" --silent
            curl --fail "$GIT_REPOSITORY/irs/MIT%20KEMAR%20HRTF%20(Normal%20Pinna).sofa" --output "$PRESETS_DIRECTORY/irs/MIT KEMAR HRTF (Normal Pinna).sofa" --silent
            ;;

        6)
            echo "Installing ARI HRTF (SOFA) preset..."
            curl --fail "$GIT_REPOSITORY/ARI%20HRTF%20(SOFA).json" --output "$PRESETS_DIRECTORY/output/ARI HRTF (SOFA).json" --silent
            curl --fail "$GIT_REPOSITORY/irs/ARI%20HRTF%20(Subject%20NH2%2C%20DTF).sofa" --output "$PRESETS_DIRECTORY/irs/ARI HRTF (Subject NH2, DTF).sofa" --silent
            ;;

        7)
            echo "Installing all GentleDynamics presets..."
            curl --fail "$GIT_REPOSITORY/GentleDynamics.json" --output "$PRESETS_DIRECTORY/output/GentleDynamics.json" --silent
            curl --fail "$GIT_REPOSITORY/GentleDynamics%20Feather%20Loudness.json" --output "$PRESETS_DIRECTORY/output/GentleDynamics Feather Loudness.json" --silent
            curl --fail "$GIT_REPOSITORY/GentleDynamics%20Dialogue%20Clarity%20Engine.json" --output "$PRESETS_DIRECTORY/output/GentleDynamics Dialogue Clarity Engine.json" --silent
            ;;

        8)
            echo "Installing Aurora Immersive preset..."
            curl --fail "$GIT_REPOSITORY/Aurora%20Immersive.json" --output "$PRESETS_DIRECTORY/output/Aurora Immersive.json" --silent
            ;;

        9)
            echo "Installing Cupertino Laptop Speakers preset..."
            curl --fail "$GIT_REPOSITORY/Cupertino%20Laptop%20Speakers.json" --output "$PRESETS_DIRECTORY/output/Cupertino Laptop Speakers.json" --silent
            ;;

        10)
            echo "Installing IRCAM LISTEN HRTF (Subject 1002) preset..."
            curl --fail "$GIT_REPOSITORY/IRCAM%20LISTEN%20HRTF%20(Subject%201002).json" --output "$PRESETS_DIRECTORY/output/IRCAM LISTEN HRTF (Subject 1002).json" --silent
            curl --fail "$GIT_REPOSITORY/irs/IRCAM%20LISTEN%20HRTF%20(Subject%201002%2C%20True%20Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/IRCAM LISTEN HRTF (Subject 1002, True Stereo, 48kHz).irs" --silent
            ;;

        11)
            echo "Installing all Utility & Effects presets..."
            curl --fail "$GIT_REPOSITORY/Night%20Listening.json" --output "$PRESETS_DIRECTORY/output/Night Listening.json" --silent
            curl --fail "$GIT_REPOSITORY/Levelizer%20(EBU%20R128).json" --output "$PRESETS_DIRECTORY/output/Levelizer (EBU R128).json" --silent
            curl --fail "$GIT_REPOSITORY/Mono%20Sum%20(Accessibility).json" --output "$PRESETS_DIRECTORY/output/Mono Sum (Accessibility).json" --silent
            curl --fail "$GIT_REPOSITORY/Tiny%20Speaker%20Rescue.json" --output "$PRESETS_DIRECTORY/output/Tiny Speaker Rescue.json" --silent
            curl --fail "$GIT_REPOSITORY/Analog%20Warmth.json" --output "$PRESETS_DIRECTORY/output/Analog Warmth.json" --silent
            curl --fail "$GIT_REPOSITORY/Concert%20Hall.json" --output "$PRESETS_DIRECTORY/output/Concert Hall.json" --silent
            curl --fail "$GIT_REPOSITORY/Movie%20Dialogue%20Boost.json" --output "$PRESETS_DIRECTORY/output/Movie Dialogue Boost.json" --silent
            ;;

        12)
            echo "Installing Synthetic Binaural Room preset..."
            curl --fail "$GIT_REPOSITORY/Synthetic%20Binaural%20Room.json" --output "$PRESETS_DIRECTORY/output/Synthetic Binaural Room.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/Synthetic%20Binaural%20Room%20(Structural%20HRTF%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/Synthetic Binaural Room (Structural HRTF, 48kHz).irs" --silent
            ;;

        13)
            echo "Installing LibreAtmos preset..."
            curl --fail "$GIT_REPOSITORY/LibreAtmos.json" --output "$PRESETS_DIRECTORY/output/LibreAtmos.json" --silent
            curl --fail "$GIT_REPOSITORY/irs/LibreAtmos%20(Stereo%2C%2048kHz).irs" --output "$PRESETS_DIRECTORY/irs/LibreAtmos (Stereo, 48kHz).irs" --silent
            ;;

    esac

}

check_installation
check_impulse_response_directory
install_menu
read_choice
install_presets
