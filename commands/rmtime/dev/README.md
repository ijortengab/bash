# Reset MTime Command

Reset MTime is command in shell to reset the modification time of file.

The date information must be provided in filename consisting of 14 digits represents of YYYY-MM-DD-HH-MM-SS.

## Setup

Download with curl.

```
curl -L https://git.io/rmtime.sh -o rmtime
```

or wget.

```
wget https://git.io/rmtime.sh -O rmtime
```

Save file as `rmtime` name, then put in your $PATH variable.

```
chmod +x rmtime
sudo mv rmtime -t /usr/local/bin
# or
[ -d ~/bin ] && mv rmtime -t ~/bin
```

## Getting Started

Just execute it.

```
rmtime IMG_20201202_143554.jpg
```

```
rmtime Screenshot_2020-12-04-07-27-06-328_com.whatsapp.png
```

For file video, add the duration of video only if there are not `ffmpeg` in your system.

```
rmtime VID_20200714_141207.mp4
```

```
rmtime VID_20200715_141207.mp4 --duration 30
```

```
rmtime VID_20200716_141207.mp4 --duration 6:30
```

```
rmtime VID_20200717_141207.mp4 --duration 5:06:30
```

If there are not `ffmpeg` and you omitted the --duration option, the file will not process.

## Bulk Process

Works well with asterix.

```
rmtime *.mp4
```

or standard input.

```
ls *.jpg | rmtime
```
