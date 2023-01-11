# Bash Script Collection

## How to install command

1. Set variable `filename` in Terminal. Choose the one you want.

```sh
filename=backup.sh
filename=command-keep-alive.sh
filename=downloader.sh
filename=reset-mtime.sh
filename=tester.sh
filename=ttw.sh
filename=ssh-command-generator.sh
filename=rotate-ffmpeg.sh
filename=gpl-nginx-static.sh
```

2. Download then put command in `$PATH`.

```
wget https://raw.githubusercontent.com/ijortengab/bash/master/commands/$filename
chmod a+x $filename
mv $filename -t /usr/local/bin
```

... or ...

```
curl -O https://raw.githubusercontent.com/ijortengab/bash/master/commands/$filename
chmod a+x $filename
mv $filename -t /usr/local/bin
```

## How to show code function in Terminal

1. Set variable `filename` in Terminal. Choose the one you want.

```
filename=array-diff.function.sh
filename=array-remove-all.function.sh
filename=array-remove.function.sh
filename=array-search.function.sh
filename=array-shift.function.sh
filename=array-unique.function.sh
filename=array-unset.function.sh
filename=var-dump.function.sh
```

2. Execute code below.

```
wget -qO- https://raw.githubusercontent.com/ijortengab/bash/master/functions/$filename
```

... or ...

```
curl https://raw.githubusercontent.com/ijortengab/bash/master/functions/$filename
```

3. Alternative, send to Clipboard (for Cygwin or WSL users).

```
wget -qO- https://raw.githubusercontent.com/ijortengab/bash/master/functions/$filename | clip.exe
```

... or ...

```
curl https://raw.githubusercontent.com/ijortengab/bash/master/functions/array-shift.function.sh | clip.exe
```

## List Commands

### backup.sh

Provide fast way to save backup of file.

```sh
filename=backup.sh
```

### command-keep-alive.sh

Keep command keep alive even it destroyed because of something.

```sh
filename=command-keep-alive.sh
```

### downloader.sh

Quick download just save information in a feed file.

```sh
filename=downloader.sh
```

### reset-mtime.sh

Reset the modification time of file if there is date information in filename.

```sh
filename=reset-mtime.sh
```

### tester.sh

Test the command then set the expected.

```sh
filename=tester.sh
```

### ttw.sh

Bulk trim trailing whitespace of files.

```sh
filename=ttw.sh
```

### ssh-command-generator.sh

Auto create symbolic link for your daily of ssh tunneling.

```sh
filename=ssh-command-generator.sh
```

### rotate-ffmpeg.sh

Rotate mp4 file with ffmpeg without re-encoding.

```sh
filename=rotate-ffmpeg.sh
```

## List Functions

### ArrayDiff

Computes the difference of arrays.

```sh
filename=array-diff.function.sh
```

### ArrayRemoveAll

Shift all element from the array.

```sh
filename=array-remove-all.function.sh
```

### ArrayRemove

Shift an element from the array, only first match.

```sh
filename=array-remove.function.sh
```

### ArraySearch

Find element in Array. Searches the array for a given value and returns the first corresponding key if successful.

```sh
filename=array-search.function.sh
```

### ArrayShift

Shift an element off the beginning of array.

```sh
filename=array-shift.function.sh
```

### ArrayUnique

Removes duplicate values from an array.

```sh
filename=array-unique.function.sh
```

### ArrayUnset

Shift an element from the array by its key/index number.

```sh
filename=array-unset.function.sh
```

### VarDump

Variable Dump for Debugging.

```sh
filename=var-dump.function.sh
```
