# Backup File

Provide fast way to save backup of file.

## Setup

Download and save file as `backup` name.

Curl:
```
curl -L https://raw.githubusercontent.com/ijortengab/bash/master/commands/backup/dev/backup.sh -o backup
```

Wget:
```
wget https://raw.githubusercontent.com/ijortengab/bash/master/commands/backup/dev/backup.sh -O backup
```

Put file in your $PATH.

```
chmod +x backup
sudo mv backup -t /usr/local/bin
# or
[ -d ~/bin ] && mv backup -t ~/bin
```

## Getting Started

Example 1.

```
touch myfile
backup myfile
```

Command above will move `myfile` to `myfile~1`.

Example 2.

```
echo 'bla bla' > mynote.txt
backup mynote.txt -c
echo 'wow wow' >> mynote.txt
backup mynote.txt -c
```

Command above will copy the origin `mynote.txt` to `mynote~1.txt` then copy the modified of `mynote.txt` to `mynote~2.txt`.

The contents of `mynote~1.txt` is

```
bla bla
```

The contents of `mynote~2.txt` is

```
bla bla
wow wow
```

Example 3.

```
touch myimage.jpg \
      myimage~1.jpg \
      myimage~2.jpg
backup myimage.jpg
```

Command above will move `myimage.jpg` to `myimage~3.jpg`.

## Options

Use flag option `-c` or `--copy` to copy the original source instead of moving it.

## Bulk Process

Works well with asterix.

```
backup *.mp4
```

or standard input.

```
ls *.jpg | backup
```
