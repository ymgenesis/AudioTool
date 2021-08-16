# AudioTool

A macOS/UNIX bash script to automate management of audio streams in MKV files using FFmpeg & FFprobe. Ability to create EAC3 7.1 from TrueHD & DTS, EAC3 or AC3 5.1 and below from anything, and strip audio streams from MKV files. Tested with macOS 10.14. Script will fail to set FFmpeg libraries on non-darwin OSs (Linux, Windows).

NOTE: You must build the proper folder structure and gather dependencies before the script can execute properly. [See below](https://github.com/ymgenesis/AudioTool#dependencies-and-folder-structure).

## Usage

`./audiotool.sh [/path/to/input.mkv] [/path/to/output.mkv]`

Requires 2 arguments. input.mkv must exist, and will be the source path & file, while output.mkv cannot exist, and will be the output path & file.

The script will check to make sure proper initial input/output arguments are passed before reaching the main menu.

After a summary of the audio in the input file is displayed, the following options are presented to the user:

1. a:0 TrueHD 7.1 to a:1 EAC3 7.1
2. a:0 DTS 7.1 to a:1 EAC3 7.1
3. a:0 Any to a:1 EAC3 5.1 and below
4. a:0 Any to a:1 AC3 5.1 and below
5. Strip Audio Stream
6. Change Input & Output Paths & Files
7. Quit

## 1. 

Checks if a TrueHD 7.1 audio stream exists at a:0, then creates an EAC3 7.1 audio stream at a:1 from a:0 in the output file.

A summary of the audio in the newly-created output file is displayed before returning to the main menu.

## 2. 

Checks if a DTS 7.1 audio stream exists at a:0, then creates an EAC3 7.1 audio stream at a:1 from a:0.

A summary of the audio in the newly-created output file is displayed before returning to the main menu.

## 3. 

Creates an EAC3 5.1 or below audio stream at a:1 from a:0. a:0 format can be anything FFmpeg can handle, and channel layout in a:1 is inherited by a:0.

A summary of the audio in the newly-created output file is displayed before returning to the main menu.

## 4. 

Creates an AC3 5.1 or below audio stream at a:1 from a:0. a:0 format can be anything FFmpeg can handle, and channel layout in a:1 is inherited by a:0.

A summary of the audio in the newly-created output file is displayed before returning to the main menu.

## 5. 

Prompts user to select an audio stream to strip from an MKV file.

A summary of the audio in the newly-created output file is displayed before returning to the main menu.

## 6. 

Prompts user to change input and output paths & files. Absolute paths must be used, and tab completion is enabled.

A summary of active input and output paths & files is given before returning to the main menu.

## 7. Quit

Quits the script.

## Dependencies and Folder Structure

All options rely on up-to-date FFmpeg and FFprobe. Options 1 & 2 rely on the existence of Plex Transcoder and it's dependancies, and EasyAudioEncoder, a decoder/encoder packaged with Plex to decode/encode .mlp-based 7.1 audio streams (TrueHD & DTS).

You must gather (copy, don't move or your Plex installation may break) the dependancies from your Plex installation on your machine and create the following folder structure exactly for successful execution: 

```
AudioTool/
├─ Codecs/
│  ├─ x-x-darwin-x86_64/
│  │  ├─ *.dylib (several .dylib files)
├─ Encoder/
│  ├─ Frameworks/
│  │  ├─ *.dylib (several .dylib files)
│  ├─ MacOS/
│  │  ├─ Plex Transcoder
│  ├─ eae-license.txt
│  ├─ EasyAudioEncoder
├─ audiotool.sh
├─ README.md
```

On macOS, `EasyAudioEncoder`, `eae-license.txt`, and `x-x-darwin-x86_64/` are found starting at `~/Library/Application\ Support/Plex\ Media\ Server/Codecs/`. x's will be replaced by version numbers. `EasyAudioEncoder` and `eae-license.txt` will be in the `EasyAudioEncoder` folder. 

On macOS, `Frameworks` and `MacOS` are found at `/Applications/Plex\ Media\ Server.app/Contents/`. You only need `Plex Transcoder` in your `AudioTool/Encoder/MacOS/` folder.

Upon succesful execution of option 1 or 2 (if you gathered everything according to the above folder structure), 6 folders will be created in `AudioTool/Encoder/` to facilitate EasyAudioEncoder's decoding/encoding.

The script will check to make sure the folder structure and files are in place before reaching the main menu.

## Glossary

> a:0, a:1, a:2, a:3, etc.

FFmpeg's vernacular for indexing audio streams. To FFmpeg, track one is a:0, track two is a:1, track three is a:2, etc. Similarly, a prefix of s refers to subtitle streams (s:0, s:1, s:2, etc.). FFmpeg supports only 1 video stream in a file at a time (v:0). 

> TrueHD / Atmos

Dolby TrueHD is a lossless, multi-channel audio codec. The Dolby TrueHD specification provides for up to 16 discrete audio channels, each with a sampling rate of up to 192kHz and sample depth of up to 24 bits. Dolby TrueHD metadata may include, for example, audio normalization or dynamic range compression. In addition, Dolby Atmos, a multi-dimensional surround format encoded using Dolby TrueHD, can embed more advanced metadata to spatially place sound objects in an Atmos-compatible speaker system.

> DTS / DTS-HD Master Audio

DTS-HD Master Audio is a multi-channel, lossless audio codec. DTS-HD MA encodes an audio master in lossy DTS first, then stores a concurrent stream of supplementary data representing whatever the DTS encoder discarded. DTS-HD MA has enjoyed the greater share of this market since 2010, with the notable exception of the TrueHD-encoded Dolby Atmos spatial surround format, which is more popular than DTS's competing DTS:X (encoded with DTS-HD MA).

> EAC3 (Dolby Digital Plus)

E-AC-3 (Enhanced AC-3), also known as Dolby Digital Plus (and commonly abbreviated as DD+ or E-AC-3, or EC-3) is a digital audio compression scheme developed by Dolby Labs for transport and storage of multi-channel digital audio. It is a successor to Dolby Digital (AC-3), and has a number of improvements including support for a wider range of data rates, increased channel count and multi-program support, and additional tools for representing compressed data and counteracting artifacts. E-AC-3 supports up to 15 full-bandwidth audio channels at a maximum bitrate of 6.144 Mbit/s.

> AC3 (Dolby Digital)

AC3, also known as Dolby Digital, contains up to six discrete channels of sound. The most elaborate mode in common use involves five channels for normal range speakers–right, center, left, right surround, left surround–and one channel for the subwoofer driven low-frequency effects (LFE).

## To Do

- [x] Add time until finished to encode options 
- [x] Add ability to change input.mkv & output.mkv from main menu, so quitting and re-executing isn't required.
- [x] Add channel layout condition check for options 3 & 4 to warn of 5.1 mixdown if input is 7.1.
- [x] Check existence of subtitles in options 3 & 4 with `-map 0:s?`. Currently they fail if there are no subtitles present. 
- [x] Add `Proceed? [y/n]: ` step just before executing conversions.
- [x] Add conditional check for proper folder/file structure before script gets to main menu. Ensures proper execution.
- [x] Add a print of file's duration before beginning encoding. Helpful to gauge encode length by comparing with FFmpeg's `time=` filed in progress output.