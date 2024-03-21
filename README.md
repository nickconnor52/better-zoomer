# Description

A basic bash script that accepts a URL or CSV list of URLs to attempt to download via dezoomify-rs ([docs here](https://github.com/lovasoa/dezoomify-rs))

## Usage

1. Make sure you have dezoomify-rs installed:

```bash
brew install dezoomify-rs
```

2. Via terminal, navigate to the root of this folder: e.g. if you've downloaded and moved this to `/Documents/better-zoomer`

```bash
cd ~/Documents/better-zoomer
```

3. Call `./better-zoomer.sh` plus your arguments!

Valid options include:
- `-f <FILE_LOCATION>`
- `-u <IMAGE_URL>`
